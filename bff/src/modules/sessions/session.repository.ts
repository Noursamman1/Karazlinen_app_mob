import { Injectable, OnModuleDestroy } from '@nestjs/common';
import Redis from 'ioredis';
import { createHash } from 'crypto';

export interface SessionRecord {
  sessionId: string;
  customerId: string;
  refreshTokenHash: string;
  deviceId?: string;
  refreshExpiresAt: string;
  revokedAt?: string;
}

@Injectable()
export class SessionRepository implements OnModuleDestroy {
  private readonly redis: Redis;

  constructor() {
    this.redis = new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379', {
      lazyConnect: true,
      maxRetriesPerRequest: 1
    });
  }

  async onModuleDestroy(): Promise<void> {
    if (this.redis.status !== 'end') {
      await this.redis.quit();
    }
  }

  async save(record: SessionRecord): Promise<void> {
    await this.redis.connect().catch(() => undefined);
    await this.redis.set(this.sessionKey(record.sessionId), JSON.stringify(record));
    await this.redis.set(this.refreshKey(record.refreshTokenHash), record.sessionId);
  }

  async findByRefreshToken(refreshToken: string): Promise<SessionRecord | null> {
    await this.redis.connect().catch(() => undefined);
    const refreshHash = this.hashRefreshToken(refreshToken);
    const sessionId = await this.redis.get(this.refreshKey(refreshHash));
    if (!sessionId) {
      return null;
    }
    const raw = await this.redis.get(this.sessionKey(sessionId));
    return raw ? (JSON.parse(raw) as SessionRecord) : null;
  }

  async revokeSession(sessionId: string): Promise<void> {
    await this.redis.connect().catch(() => undefined);
    const raw = await this.redis.get(this.sessionKey(sessionId));
    if (!raw) {
      return;
    }
    const record = JSON.parse(raw) as SessionRecord;
    const revoked: SessionRecord = { ...record, revokedAt: new Date().toISOString() };
    await this.redis.set(this.sessionKey(sessionId), JSON.stringify(revoked));
  }

  async incrementRateLimit(key: string, ttlSeconds: number): Promise<number> {
    await this.redis.connect().catch(() => undefined);
    const count = await this.redis.incr(key);
    if (count === 1) {
      await this.redis.expire(key, ttlSeconds);
    }
    return count;
  }

  hashRefreshToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  private sessionKey(sessionId: string): string {
    return `session:${sessionId}`;
  }

  private refreshKey(refreshTokenHash: string): string {
    return `refresh:${refreshTokenHash}`;
  }
}
