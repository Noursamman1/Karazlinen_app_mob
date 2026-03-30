import { Injectable } from '@nestjs/common';

import { SessionRepository } from './session.repository';

// The active session repository already uses Redis directly. This adapter keeps
// a Redis-specific implementation symbol available for future refactors without
// duplicating a second storage contract today.
@Injectable()
export class RedisSessionRepository extends SessionRepository {}
