import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class MagentoConfig {
  constructor(private readonly configService: ConfigService) {}

  get baseUrl(): string {
    return this.configService.getOrThrow<string>('MAGENTO_BASE_URL');
  }

  get graphQlPath(): string {
    return this.configService.get<string>('MAGENTO_GRAPHQL_PATH', '/graphql');
  }
}
