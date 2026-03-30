import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { SessionRepository } from './session.repository';
import { SessionService } from './session.service';

@Module({
  imports: [ConfigModule],
  providers: [SessionRepository, SessionService],
  exports: [SessionRepository, SessionService]
})
export class SessionModule {}
