import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';

import { CustomerAuthPort, MagentoCustomerSummary } from '../magento/ports/customer-auth.port';
import { SessionService } from '../sessions/session.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly customerAuthPort: CustomerAuthPort,
    private readonly sessionService: SessionService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService
  ) {}

  async login(email: string, password: string): Promise<{ accessToken: string; refreshToken: string; expiresInSeconds: number }> {
    const customer = await this.customerAuthPort.authenticateCustomer(email, password);
    const refreshTtlDays = this.configService.get<number>('REFRESH_TOKEN_TTL_DAYS', 30);
    const accessTtl = this.configService.get<number>('ACCESS_TOKEN_TTL_SECONDS', 300);
    const session = await this.sessionService.createSession(customer.customerId, refreshTtlDays);
    const accessToken = await this.jwtService.signAsync({
      sub: customer.customerId,
      sid: session.sessionId,
      scope: ['customer']
    });
    return {
      accessToken,
      refreshToken: session.refreshToken,
      expiresInSeconds: accessTtl
    };
  }

  async refresh(refreshToken: string): Promise<{ accessToken: string; refreshToken: string; expiresInSeconds: number }> {
    const refreshTtlDays = this.configService.get<number>('REFRESH_TOKEN_TTL_DAYS', 30);
    const accessTtl = this.configService.get<number>('ACCESS_TOKEN_TTL_SECONDS', 300);
    const rotated = await this.sessionService.rotateRefreshToken(refreshToken, refreshTtlDays);
    const accessToken = await this.jwtService.signAsync({
      sub: rotated.session.customerId,
      sid: rotated.session.sessionId,
      scope: ['customer']
    });
    return {
      accessToken,
      refreshToken: rotated.refreshToken,
      expiresInSeconds: accessTtl
    };
  }

  async logout(sessionId: string): Promise<void> {
    await this.sessionService.revoke(sessionId);
  }

  async me(customerId: string): Promise<{ authenticated: true; profile: MagentoCustomerSummary }> {
    const profile = await this.customerAuthPort.fetchCustomerSummary(customerId);
    return {
      authenticated: true,
      profile
    };
  }
}
