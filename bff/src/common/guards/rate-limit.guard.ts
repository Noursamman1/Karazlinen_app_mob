import { CanActivate, ExecutionContext, HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHash } from 'crypto';

import { SessionRepository } from '../../modules/sessions/session.repository';

@Injectable()
export class RateLimitGuard implements CanActivate {
  constructor(
    private readonly configService: ConfigService,
    private readonly sessionRepository: SessionRepository
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const response = context.switchToHttp().getResponse();
    const profile = this.resolveLimitProfile(request);
    const key = this.resolveKey(request, profile.scope);
    const count = await this.sessionRepository.incrementRateLimit(key, profile.windowSeconds);
    if (count > profile.maxRequests) {
      response?.setHeader('Retry-After', Math.max(1, profile.windowSeconds).toString());
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

  private resolveLimitProfile(request: {
    originalUrl?: string;
    route?: { path?: string };
  }): { windowSeconds: number; maxRequests: number; scope: 'login' | 'refresh' | 'me' | 'default' } {
    const path = request.originalUrl ?? request.route?.path ?? '';
    const authWindow = this.configService.get<number>('RATE_LIMIT_AUTH_WINDOW_SECONDS', 60);

    if (path.includes('/auth/login')) {
      return {
        windowSeconds: authWindow,
        maxRequests: this.configService.get<number>('RATE_LIMIT_AUTH_LOGIN_MAX_REQUESTS', 10),
        scope: 'login'
      };
    }

    if (path.includes('/auth/refresh')) {
      return {
        windowSeconds: authWindow,
        maxRequests: this.configService.get<number>('RATE_LIMIT_AUTH_REFRESH_MAX_REQUESTS', 20),
        scope: 'refresh'
      };
    }

    if (path.includes('/auth/me')) {
      return {
        windowSeconds: authWindow,
        maxRequests: this.configService.get<number>('RATE_LIMIT_AUTH_ME_MAX_REQUESTS', 60),
        scope: 'me'
      };
    }

    return {
      windowSeconds: this.configService.get<number>('RATE_LIMIT_WINDOW_SECONDS', 60),
      maxRequests: this.configService.get<number>('RATE_LIMIT_MAX_REQUESTS', 120),
      scope: 'default'
    };
  }

  private resolveKey(
    request: {
      ip?: string;
      originalUrl?: string;
      body?: { email?: string };
      user?: { sub?: string };
    },
    scope: 'login' | 'refresh' | 'me' | 'default'
  ): string {
    const ip = request.ip ?? 'unknown';
    const path = (request.originalUrl ?? 'unknown').split('?')[0];

    if (scope === 'login') {
      const email = request.body?.email?.trim().toLowerCase() ?? 'anonymous';
      return `ratelimit:${scope}:${ip}:${this.hash(email)}`;
    }

    if (scope === 'refresh' || scope === 'me') {
      return `ratelimit:${scope}:${ip}:${request.user?.sub ?? 'anonymous'}`;
    }

    return `ratelimit:${scope}:${ip}:${path}`;
  }

  private hash(value: string): string {
    return createHash('sha256').update(value).digest('hex');
  }
}
