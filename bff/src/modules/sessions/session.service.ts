import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomBytes, randomUUID } from 'crypto';

import { SessionRecord, SessionRepository } from './session.repository';
import { MagentoSessionContext } from './session.types';

type CreateSessionOptions = {
  deviceId?: string;
  customerEmail?: string;
  magentoCustomerToken?: string;
  magentoCartId?: string;
};

@Injectable()
export class SessionService {
  constructor(
    private readonly repository: SessionRepository,
    private readonly configService: ConfigService
  ) {}

  async createSession(
    customerId: string,
    refreshTtlDays: number,
    options: CreateSessionOptions = {}
  ): Promise<{ sessionId: string; refreshToken: string }> {
    const deviceId = this.normalizeDeviceId(options.deviceId);
    if (deviceId) {
      const existingDeviceSession = await this.repository.findCurrentSessionForCustomerDevice(customerId, deviceId);
      if (existingDeviceSession && !existingDeviceSession.revokedAt) {
        await this.repository.revokeSessionWithReason(existingDeviceSession.sessionId, 'device_replaced');
      }
    }

    await this.enforceCustomerSessionCap(customerId);

    const sessionId = randomUUID();
    const refreshToken = randomBytes(48).toString('hex');
    const refreshTokenHash = this.repository.hashRefreshToken(refreshToken);
    const refreshExpiresAt = new Date(Date.now() + refreshTtlDays * 24 * 60 * 60 * 1000).toISOString();
    await this.repository.save({
      sessionId,
      customerId,
      refreshTokenHash,
      refreshExpiresAt,
      createdAt: new Date().toISOString(),
      deviceId,
      customerEmail: options.customerEmail,
      magentoCustomerToken: options.magentoCustomerToken,
      magentoCartId: options.magentoCartId
    });
    return { sessionId, refreshToken };
  }

  async rotateRefreshToken(
    refreshToken: string,
    refreshTtlDays: number,
    deviceId?: string
  ): Promise<{ session: SessionRecord; refreshToken: string }> {
    const existing = await this.repository.findByRefreshToken(refreshToken);
    if (!existing || existing.revokedAt) {
      throw new UnauthorizedException({
        message: 'Refresh token is invalid or expired',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }
    if (new Date(existing.refreshExpiresAt).getTime() <= Date.now()) {
      await this.repository.revokeSession(existing.sessionId);
      throw new UnauthorizedException({
        message: 'Refresh token is invalid or expired',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }

    const normalizedDeviceId = this.normalizeDeviceId(deviceId);
    if (existing.deviceId && existing.deviceId !== normalizedDeviceId) {
      await this.repository.revokeSessionWithReason(existing.sessionId, 'device_mismatch');
      throw new UnauthorizedException({
        message: 'Refresh token cannot be used from a different device',
        code: 'AUTH_DEVICE_MISMATCH'
      });
    }

    await this.repository.revokeSessionWithReason(existing.sessionId, 'refresh_rotated');
    const replacement = await this.createSession(existing.customerId, refreshTtlDays, {
      deviceId: existing.deviceId,
      customerEmail: existing.customerEmail,
      magentoCustomerToken: existing.magentoCustomerToken,
      magentoCartId: existing.magentoCartId
    });
    return {
      session: { ...existing, sessionId: replacement.sessionId },
      refreshToken: replacement.refreshToken
    };
  }

  async findActiveSession(sessionId: string): Promise<SessionRecord> {
    const session = await this.repository.findBySessionId(sessionId);
    if (!session || session.revokedAt || new Date(session.refreshExpiresAt).getTime() <= Date.now()) {
      throw new UnauthorizedException({
        message: 'Session is invalid or expired',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }
    await this.repository.touchSession(sessionId);
    return session;
  }

  async revokeOwnedSession(customerId: string, sessionId: string): Promise<void> {
    const session = await this.repository.findBySessionId(sessionId);
    if (!session) {
      return;
    }
    if (session.customerId !== customerId) {
      throw new UnauthorizedException({
        message: 'Session does not belong to this customer',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }
    await this.repository.revokeSessionWithReason(sessionId, 'customer_logout');
  }

  async getMagentoSessionContext(customerId: string, sessionId: string): Promise<MagentoSessionContext> {
    const session = await this.findActiveSession(sessionId);
    if (session.customerId !== customerId) {
      throw new UnauthorizedException({
        message: 'Session does not belong to this customer',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }
    if (!session.magentoCustomerToken) {
      throw new UnauthorizedException({
        message: 'Session is missing Magento context',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }

    return {
      sessionId: session.sessionId,
      customerId: session.customerId,
      customerEmail: session.customerEmail,
      magentoCustomerToken: session.magentoCustomerToken,
      magentoCartId: session.magentoCartId
    };
  }

  async updateMagentoCartId(customerId: string, sessionId: string, magentoCartId?: string): Promise<SessionRecord> {
    const session = await this.findActiveSession(sessionId);
    if (session.customerId !== customerId) {
      throw new UnauthorizedException({
        message: 'Session does not belong to this customer',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }

    const updated = await this.repository.updateSession(sessionId, { magentoCartId });
    if (!updated) {
      throw new UnauthorizedException({
        message: 'Session is invalid or expired',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }

    return updated;
  }

  private async enforceCustomerSessionCap(customerId: string): Promise<void> {
    const maxSessions = this.configService.get<number>('MAX_ACTIVE_SESSIONS_PER_CUSTOMER', 5);
    const activeSessions = (await this.repository.findSessionsByCustomer(customerId))
      .filter((session) => !session.revokedAt && new Date(session.refreshExpiresAt).getTime() > Date.now())
      .sort((left, right) => new Date(left.createdAt).getTime() - new Date(right.createdAt).getTime());

    while (activeSessions.length >= maxSessions) {
      const oldest = activeSessions.shift();
      if (!oldest) {
        break;
      }
      await this.repository.revokeSessionWithReason(oldest.sessionId, 'session_cap_exceeded');
    }
  }

  private normalizeDeviceId(deviceId?: string): string | undefined {
    if (deviceId == null) {
      return undefined;
    }
    const normalized = deviceId.trim();
    if (!normalized) {
      return undefined;
    }
    if (!/^[A-Za-z0-9._:-]{8,128}$/.test(normalized)) {
      throw new BadRequestException({
        message: 'x-device-id header is invalid',
        code: 'VALIDATION_ERROR'
      });
    }
    return normalized;
  }
}
