import { Module } from '@nestjs/common';

import { SessionRepository } from './session.repository';
import { SessionService } from './session.service';

@Module({
  providers: [SessionRepository, SessionService],
  exports: [SessionRepository, SessionService]
})
export class SessionModule {}
