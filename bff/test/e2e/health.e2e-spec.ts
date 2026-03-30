import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';

import { HealthModule } from '../../src/modules/health/health.module';
import { CatalogReadPort } from '../../src/modules/magento/ports/catalog-read.port';
import { SessionRepository } from '../../src/modules/sessions/session.repository';
import { ConfigModule } from '@nestjs/config';

describe('HealthController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [ConfigModule.forRoot({ isGlobal: true }), HealthModule]
    })
      .overrideProvider(CatalogReadPort)
      .useValue({ healthcheck: jest.fn().mockResolvedValue(true) })
      .overrideProvider(SessionRepository)
      .useValue({})
      .compile();

    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('/health/live', async () => {
    await request(app.getHttpServer()).get('/health/live').expect(200);
  });
});
