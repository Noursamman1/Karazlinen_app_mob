import { Injectable, OnModuleDestroy } from '@nestjs/common';
import Redis from 'ioredis';
import { createHash } from 'crypto';

export interface SessionRecord {
  sessionId: string;
  customerId: string;
  refreshTokenHash: string;
  customerEmail?: string;
  magentoCustomerToken?: string;
  deviceId?: string;
  refreshExpiresAt: string;
  createdAt: string;
  lastSeenAt?: string;
  revokedAt?: string;
  revokedReason?: string;
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
    const ttlSeconds = this.ttlSeconds(record.refreshExpiresAt);
    await this.redis.set(this.sessionKey(record.sessionId), JSON.stringify(record), 'EX', ttlSeconds);
    await this.redis.set(this.refreshKey(record.refreshTokenHash), record.sessionId, 'EX', ttlSeconds);
    await this.redis.sadd(this.customerSessionsKey(record.customerId), record.sessionId);
    if (record.deviceId) {
      await this.redis.set(this.customerDeviceKey(record.customerId, record.deviceId), record.sessionId, 'EX', ttlSeconds);
    }
  }

  async findByRefreshToken(refreshToken: string): Promise<SessionRecord | null> {
    await this.redis.connect().catch(() => undefined);
    const refreshHash = this.hashRefreshToken(refreshToken);
    const sessionId = await this.redis.get(this.refreshKey(refreshHash));
    if (!sessionId) {
      return null;
    }
    return this.findBySessionId(sessionId);
  }

  async findBySessionId(sessionId: string): Promise<SessionRecord | null> {
    await this.redis.connect().catch(() => undefined);
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
    const revoked: SessionRecord = {
      ...record,
      revokedAt: new Date().toISOString(),
      revokedReason: record.revokedReason ?? 'manual'
    };
    await this.redis.set(this.sessionKey(sessionId), JSON.stringify(revoked), 'EX', this.ttlSeconds(record.refreshExpiresAt));
    await this.redis.del(this.refreshKey(record.refreshTokenHash));
    await this.redis.srem(this.customerSessionsKey(record.customerId), sessionId);
    if (record.deviceId) {
      await this.removeDeviceMappingIfOwned(record.customerId, record.deviceId, sessionId);
    }
  }

  async revokeSessionWithReason(sessionId: string, revokedReason: string): Promise<void> {
    await this.redis.connect().catch(() => undefined);
    const raw = await this.redis.get(this.sessionKey(sessionId));
    if (!raw) {
      return;
    }
    const record = JSON.parse(raw) as SessionRecord;
    const revoked: SessionRecord = { ...record, revokedAt: new Date().toISOString(), revokedReason };
    await this.redis.set(this.sessionKey(sessionId), JSON.stringify(revoked), 'EX', this.ttlSeconds(record.refreshExpiresAt));
    await this.redis.del(this.refreshKey(record.refreshTokenHash));
    await this.redis.srem(this.customerSessionsKey(record.customerId), sessionId);
    if (record.deviceId) {
      await this.removeDeviceMappingIfOwned(record.customerId, record.deviceId, sessionId);
    }
  }

  async findCurrentSessionForCustomerDevice(customerId: string, deviceId: string): Promise<SessionRecord | null> {
    await this.redis.connect().catch(() => undefined);
    const sessionId = await this.redis.get(this.customerDeviceKey(customerId, deviceId));
    if (!sessionId) {
      return null;
    }
    return this.findBySessionId(sessionId);
  }

  async findSessionsByCustomer(customerId: string): Promise<SessionRecord[]> {
    await this.redis.connect().catch(() => undefined);
    const sessionIds = await this.redis.smembers(this.customerSessionsKey(customerId));
    if (!sessionIds.length) {
      return [];
    }
    const sessions = await Promise.all(sessionIds.map((sessionId) => this.findBySessionId(sessionId)));
    return sessions.filter((session): session is SessionRecord => session != null);
  }

  async touchSession(sessionId: string): Promise<void> {
    await this.redis.connect().catch(() => undefined);
    const raw = await this.redis.get(this.sessionKey(sessionId));
    if (!raw) {
      return;
    }
    const record = JSON.parse(raw) as SessionRecord;
    const touched: SessionRecord = { ...record, lastSeenAt: new Date().toISOString() };
    await this.redis.set(this.sessionKey(sessionId), JSON.stringify(touched), 'EX', this.ttlSeconds(record.refreshExpiresAt));
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

  private customerSessionsKey(customerId: string): string {
    return `customer_sessions:${customerId}`;
  }

  private customerDeviceKey(customerId: string, deviceId: string): string {
    return `customer_device:${customerId}:${deviceId}`;
  }

  private ttlSeconds(expiresAtIso: string): number {
    return Math.max(1, Math.ceil((new Date(expiresAtIso).getTime() - Date.now()) / 1000));
  }

  private async removeDeviceMappingIfOwned(customerId: string, deviceId: string, sessionId: string): Promise<void> {
    const key = this.customerDeviceKey(customerId, deviceId);
    const currentSessionId = await this.redis.get(key);
    if (currentSessionId === sessionId) {
      await this.redis.del(key);
    }
  }
}
