import { CanActivate, ExecutionContext, HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { SessionRepository } from '../../modules/sessions/session.repository';

@Injectable()
export class RateLimitGuard implements CanActivate {
  constructor(
    private readonly configService: ConfigService,
    private readonly sessionRepository: SessionRepository
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const windowSeconds = this.configService.get<number>('RATE_LIMIT_WINDOW_SECONDS', 60);
    const maxRequests = this.configService.get<number>('RATE_LIMIT_MAX_REQUESTS', 120);
    const key = `ratelimit:${request.ip}:${request.originalUrl}`;
    const count = await this.sessionRepository.incrementRateLimit(key, windowSeconds);
    if (count > maxRequests) {
      throw new HttpException(
        {
          message: 'Too many requests',
          code: 'RATE_LIMITED'
        },
        HttpStatus.TOO_MANY_REQUESTS
      );
    }
    return true;
  }
}
