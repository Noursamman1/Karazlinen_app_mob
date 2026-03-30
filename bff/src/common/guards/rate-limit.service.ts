import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

type HitResult = {
  allowed: boolean;
  remaining: number;
  retryAfterSeconds: number;
};

@Injectable()
export class RateLimitService {
  private readonly redis: Redis;

  constructor(private readonly configService: ConfigService) {
    this.redis = new Redis(this.configService.getOrThrow<string>('redis.url'), {
      lazyConnect: true,
      maxRetriesPerRequest: 1,
    });
  }

  async hit(key: string): Promise<HitResult> {
    const windowSeconds = this.configService.getOrThrow<number>('rateLimit.windowSeconds');
    const maxRequests = this.configService.getOrThrow<number>('rateLimit.maxRequests');
    const redisKey = `rate_limit:${key}`;
    await this.redis.connect().catch(() => undefined);
    const current = await this.redis.incr(redisKey);

    if (current === 1) {
      await this.redis.expire(redisKey, windowSeconds);
    }

    const ttl = await this.redis.ttl(redisKey);

    return {
      allowed: current <= maxRequests,
      remaining: Math.max(maxRequests - current, 0),
      retryAfterSeconds: Math.max(ttl, 0),
    };
  }

  async ping(): Promise<boolean> {
    try {
      await this.redis.connect().catch(() => undefined);
      return (await this.redis.ping()) === 'PONG';
    } catch {
      return false;
    }
  }
}
