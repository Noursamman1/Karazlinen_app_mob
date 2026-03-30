import { Injectable, ServiceUnavailableException } from '@nestjs/common';

import { CustomerAuthPort, MagentoCustomerSummary } from './ports/customer-auth.port';
import { CatalogReadPort } from './ports/catalog-read.port';
import { OrderReadPort } from './ports/order-read.port';
import { SearchPort } from '../search/search.port';

@Injectable()
export class MagentoClient implements CustomerAuthPort, CatalogReadPort, OrderReadPort, SearchPort {
  async authenticateCustomer(_email: string, _password: string): Promise<{ customerId: string }> {
    throw new ServiceUnavailableException({
      message: 'Magento storefront authentication is not connected yet',
      code: 'UPSTREAM_MAGENTO_UNAVAILABLE'
    });
  }

  async fetchCustomerSummary(_customerId: string): Promise<MagentoCustomerSummary> {
    throw new ServiceUnavailableException({
      message: 'Magento customer summary is not connected yet',
      code: 'UPSTREAM_MAGENTO_UNAVAILABLE'
    });
  }

  async healthcheck(): Promise<boolean> {
    return false;
  }

  providerName(): string {
    return 'magento';
  }
}
