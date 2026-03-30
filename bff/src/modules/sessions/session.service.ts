import { Injectable, UnauthorizedException } from '@nestjs/common';
import { randomBytes, randomUUID } from 'crypto';

import { SessionRecord, SessionRepository } from './session.repository';

@Injectable()
export class SessionService {
  constructor(private readonly repository: SessionRepository) {}

  async createSession(customerId: string, refreshTtlDays: number, deviceId?: string): Promise<{ sessionId: string; refreshToken: string }> {
    const sessionId = randomUUID();
    const refreshToken = randomBytes(48).toString('hex');
    const refreshTokenHash = this.repository.hashRefreshToken(refreshToken);
    const refreshExpiresAt = new Date(Date.now() + refreshTtlDays * 24 * 60 * 60 * 1000).toISOString();
    await this.repository.save({
      sessionId,
      customerId,
      refreshTokenHash,
      refreshExpiresAt,
      deviceId
    });
    return { sessionId, refreshToken };
  }

  async rotateRefreshToken(refreshToken: string, refreshTtlDays: number): Promise<{ session: SessionRecord; refreshToken: string }> {
    const existing = await this.repository.findByRefreshToken(refreshToken);
    if (!existing || existing.revokedAt) {
      throw new UnauthorizedException({
        message: 'Refresh token is invalid or expired',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }
    await this.repository.revokeSession(existing.sessionId);
    const replacement = await this.createSession(existing.customerId, refreshTtlDays, existing.deviceId);
    return {
      session: { ...existing, sessionId: replacement.sessionId },
      refreshToken: replacement.refreshToken
    };
  }

  async revoke(sessionId: string): Promise<void> {
    await this.repository.revokeSession(sessionId);
  }
}
