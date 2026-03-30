import { Injectable } from '@nestjs/common';

import { MagentoClient } from './magento.client';
import {
  CustomerAuthPort,
  type MagentoAuthenticationResult,
  type MagentoCustomerSessionContext,
  type MagentoCustomerSummary
} from './ports/customer-auth.port';

@Injectable()
export class MagentoCustomerAuthService extends CustomerAuthPort {
  constructor(private readonly magentoClient: MagentoClient) {
    super();
  }

  authenticateCustomer(email: string, password: string): Promise<MagentoAuthenticationResult> {
    return this.magentoClient.authenticateCustomer(email, password);
  }

  fetchCustomerSummary(context: MagentoCustomerSessionContext): Promise<MagentoCustomerSummary> {
    return this.magentoClient.fetchCustomerSummary(context);
  }
}
