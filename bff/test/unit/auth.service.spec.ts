import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';

import { AuthService } from '../../src/modules/auth/auth.service';
import { CustomerAuthPort } from '../../src/modules/magento/ports/customer-auth.port';
import { SessionService } from '../../src/modules/sessions/session.service';
import { JwtService } from '@nestjs/jwt';

describe('AuthService', () => {
  it('returns BFF tokens on login', async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: CustomerAuthPort,
          useValue: {
            authenticateCustomer: jest.fn().mockResolvedValue({ customerId: 'cust-1' })
          }
        },
        {
          provide: SessionService,
          useValue: {
            createSession: jest.fn().mockResolvedValue({
              sessionId: 'sid-1',
              refreshToken: 'refresh-token'
            })
          }
        },
        {
          provide: JwtService,
          useValue: {
            signAsync: jest.fn().mockResolvedValue('access-token')
          }
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: number) => defaultValue),
            getOrThrow: jest.fn(() => 'test-secret')
          }
        }
      ]
    }).compile();

    const service = moduleRef.get(AuthService);
    const result = await service.login('customer@example.com', 'password123');
    expect(result.refreshToken).toBe('refresh-token');
    expect(result.accessToken).toBe('access-token');
  });
});
