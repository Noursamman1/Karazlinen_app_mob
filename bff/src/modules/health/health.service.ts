import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { SessionRepository } from '../sessions/session.repository';
import { CatalogReadPort } from '../magento/ports/catalog-read.port';

@Injectable()
export class HealthService {
  constructor(
    private readonly configService: ConfigService,
    private readonly sessionRepository: SessionRepository,
    private readonly catalogReadPort: CatalogReadPort
  ) {}

  live(): { status: string } {
    return { status: 'ok' };
  }

  async ready(): Promise<{ status: string; checks: Record<string, boolean> }> {
    const redisConfigured = Boolean(this.configService.get<string>('REDIS_URL'));
    const magentoReachable = await this.catalogReadPort.healthcheck().catch(() => false);
    const checks = {
      config: true,
      redis: redisConfigured,
      magento: magentoReachable
    };
    return {
      status: Object.values(checks).every(Boolean) ? 'ready' : 'degraded',
      checks
    };
  }

  deps(): { redisUrl: string | undefined; provider: string } {
    return {
      redisUrl: this.configService.get<string>('REDIS_URL'),
      provider: 'magento'
    };
  }
}
