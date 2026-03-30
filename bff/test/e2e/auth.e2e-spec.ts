import { Test } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';

import { AuthModule } from '../../src/modules/auth/auth.module';
import { CustomerAuthPort } from '../../src/modules/magento/ports/customer-auth.port';
import { SessionService } from '../../src/modules/sessions/session.service';
import { ConfigModule } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';

describe('AuthController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    process.env.ACCESS_TOKEN_PRIVATE_KEY = 'test-secret';
    process.env.ACCESS_TOKEN_PUBLIC_KEY = 'test-secret';
    process.env.REDIS_URL = 'redis://localhost:6379';
    process.env.MAGENTO_BASE_URL = 'https://example.com';
    process.env.MAGENTO_STORE_CODE = 'default';

    const moduleRef = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({ isGlobal: true }),
        JwtModule.register({ secret: 'test-secret' }),
        AuthModule
      ]
    })
      .overrideProvider(CustomerAuthPort)
      .useValue({
        authenticateCustomer: jest.fn().mockResolvedValue({ customerId: 'cust-1' }),
        fetchCustomerSummary: jest.fn().mockResolvedValue({
          customerId: 'cust-1',
          firstName: 'Noura',
          lastName: 'Al Tamimi',
          email: 'noura@example.com'
        })
      })
      .overrideProvider(SessionService)
      .useValue({
        createSession: jest.fn().mockResolvedValue({ sessionId: 'sid-1', refreshToken: 'refresh-token' }),
        rotateRefreshToken: jest.fn().mockResolvedValue({
          session: { customerId: 'cust-1', sessionId: 'sid-2' },
          refreshToken: 'refresh-token-2'
        }),
        revoke: jest.fn().mockResolvedValue(undefined)
      })
      .compile();

    app = moduleRef.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();
  });

  afterAll(async () => {
    if (app != null) {
      await app.close();
    }
  });

  it('/auth/login', async () => {
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'noura@example.com', password: 'password123' })
      .expect(201);
  });
});
