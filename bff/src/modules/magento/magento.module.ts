import { Module } from '@nestjs/common';

import { LoggerModule } from '../../common/logger/logger.module';
import { MagentoClient } from './magento.client';
import { MagentoConfig } from './magento.config';
import { CustomerAuthPort } from './ports/customer-auth.port';
import { CatalogReadPort } from './ports/catalog-read.port';
import { OrderReadPort } from './ports/order-read.port';
import { SearchPort } from '../search/search.port';

@Module({
  imports: [LoggerModule],
  providers: [
    MagentoConfig,
    MagentoClient,
    { provide: CustomerAuthPort, useExisting: MagentoClient },
    { provide: CatalogReadPort, useExisting: MagentoClient },
    { provide: OrderReadPort, useExisting: MagentoClient },
    { provide: SearchPort, useExisting: MagentoClient }
  ],
  exports: [MagentoConfig, CustomerAuthPort, CatalogReadPort, OrderReadPort, SearchPort]
})
export class MagentoModule {}
