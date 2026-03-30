import { Injectable, ServiceUnavailableException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { createHash } from 'crypto';

import { AppLoggerService } from '../../common/logger/logger.service';
import { CustomerAuthPort, MagentoCustomerSummary } from '../magento/ports/customer-auth.port';
import { SessionService } from '../sessions/session.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly customerAuthPort: CustomerAuthPort,
    private readonly sessionService: SessionService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly logger: AppLoggerService
  ) {}

  async login(
    email: string,
    password: string,
    deviceId?: string
  ): Promise<{ accessToken: string; refreshToken: string; expiresInSeconds: number }> {
    const customer = await this.customerAuthPort.authenticateCustomer(email, password);
    const customerEmail = customer.customerEmail ?? email;
    const refreshTtlDays = this.configService.get<number>('REFRESH_TOKEN_TTL_DAYS', 30);
    const accessTtl = this.configService.get<number>('ACCESS_TOKEN_TTL_SECONDS', 300);
    const session = await this.sessionService.createSession(customer.customerId, refreshTtlDays, {
      deviceId,
      customerEmail,
      magentoCustomerToken: customer.magentoCustomerToken
    });
    const accessToken = await this.jwtService.signAsync({
      sub: customer.customerId,
      sid: session.sessionId,
      scope: ['customer']
    });
    this.logger.info('auth_login_succeeded', {
      customer_id: customer.customerId,
      customer_email_sha256: this.hashEmail(customerEmail),
      session_id: session.sessionId,
      device_id: deviceId ?? 'unbound'
    });
    return {
      accessToken,
      refreshToken: session.refreshToken,
      expiresInSeconds: accessTtl
    };
  }

  async refresh(
    refreshToken: string,
    deviceId?: string
  ): Promise<{ accessToken: string; refreshToken: string; expiresInSeconds: number }> {
    const refreshTtlDays = this.configService.get<number>('REFRESH_TOKEN_TTL_DAYS', 30);
    const accessTtl = this.configService.get<number>('ACCESS_TOKEN_TTL_SECONDS', 300);
    const rotated = await this.sessionService.rotateRefreshToken(refreshToken, refreshTtlDays, deviceId);
    const accessToken = await this.jwtService.signAsync({
      sub: rotated.session.customerId,
      sid: rotated.session.sessionId,
      scope: ['customer']
    });
    this.logger.info('auth_refresh_succeeded', {
      customer_id: rotated.session.customerId,
      session_id: rotated.session.sessionId,
      device_id: rotated.session.deviceId ?? 'unbound'
    });
    return {
      accessToken,
      refreshToken: rotated.refreshToken,
      expiresInSeconds: accessTtl
    };
  }

  async logout(customerId: string, sessionId: string): Promise<void> {
    await this.sessionService.revokeOwnedSession(customerId, sessionId);
    this.logger.info('auth_logout_succeeded', {
      customer_id: customerId,
      session_id: sessionId
    });
  }

  async me(customerId: string, sessionId: string): Promise<{ authenticated: true; profile: MagentoCustomerSummary }> {
    const session = await this.sessionService.findActiveSession(sessionId);
    if (session.customerId !== customerId) {
      throw new UnauthorizedException({
        message: 'Session does not belong to this customer',
        code: 'AUTH_SESSION_EXPIRED'
      });
    }
    if (!session.magentoCustomerToken) {
      throw new ServiceUnavailableException({
        message: 'Magento session context is unavailable',
        code: 'UPSTREAM_MAGENTO_UNAVAILABLE'
      });
    }
    const profile = await this.customerAuthPort.fetchCustomerSummary({
      customerId,
      magentoCustomerToken: session.magentoCustomerToken
    });
    this.logger.info('auth_me_succeeded', {
      customer_id: customerId,
      session_id: sessionId
    });
    return {
      authenticated: true,
      profile
    };
  }

  private hashEmail(email: string): string {
    return createHash('sha256').update(email.trim().toLowerCase()).digest('hex');
  }
}
