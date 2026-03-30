import { Injectable } from '@nestjs/common';

import { MagentoClient } from './magento.client';
import { CustomerAuthPort, type MagentoCustomerSummary } from './ports/customer-auth.port';

@Injectable()
export class MagentoCustomerAuthService extends CustomerAuthPort {
  constructor(private readonly magentoClient: MagentoClient) {
    super();
  }

  authenticateCustomer(email: string, password: string): Promise<{ customerId: string }> {
    return this.magentoClient.authenticateCustomer(email, password);
  }

  fetchCustomerSummary(customerId: string): Promise<MagentoCustomerSummary> {
    return this.magentoClient.fetchCustomerSummary(customerId);
  }
}
