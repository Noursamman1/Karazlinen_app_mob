import 'reflect-metadata';

import { RequestMethod, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';

import { AppModule } from './app.module';
import { AppLoggerService } from './common/logger/logger.service';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  const logger = app.get(AppLoggerService);
  app.useLogger(logger);
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true
    })
  );
  app.setGlobalPrefix('v1', {
    exclude: [
      { path: 'health/live', method: RequestMethod.GET },
      { path: 'health/ready', method: RequestMethod.GET },
      { path: 'health/deps', method: RequestMethod.GET }
    ]
  });
  await app.listen(process.env.PORT ? Number(process.env.PORT) : 3000);
  logger.info('bff_started', { port: process.env.PORT ?? 3000 });
}

void bootstrap();
