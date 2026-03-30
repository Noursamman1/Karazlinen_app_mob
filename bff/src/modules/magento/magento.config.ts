import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class MagentoConfig {
  constructor(private readonly configService: ConfigService) {}

  get baseUrl(): string {
    return this.configService.getOrThrow<string>('MAGENTO_BASE_URL');
  }

  get storeCode(): string {
    return this.configService.getOrThrow<string>('MAGENTO_STORE_CODE');
  }

  get timeoutMs(): number {
    return this.configService.get<number>('MAGENTO_TIMEOUT_MS', 5000);
  }

  get graphQlPath(): string {
    return this.configService.get<string>('MAGENTO_GRAPHQL_PATH', '/graphql');
  }

  get customerTokenPath(): string {
    return this.configService.get<string>('MAGENTO_CUSTOMER_TOKEN_PATH', '/rest/V1/integration/customer/token');
  }

  get retryAttempts(): number {
    return this.configService.get<number>('MAGENTO_RETRY_ATTEMPTS', 2);
  }

  get retryBackoffMs(): number {
    return this.configService.get<number>('MAGENTO_RETRY_BACKOFF_MS', 250);
  }

  get circuitBreakerThreshold(): number {
    return this.configService.get<number>('MAGENTO_CIRCUIT_BREAKER_THRESHOLD', 5);
  }

  get circuitBreakerResetMs(): number {
    return this.configService.get<number>('MAGENTO_CIRCUIT_BREAKER_RESET_MS', 30000);
  }
}
