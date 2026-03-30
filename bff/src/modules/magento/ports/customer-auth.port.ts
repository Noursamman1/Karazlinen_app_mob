export interface MagentoCustomerSummary {
  customerId: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
}

export interface MagentoCustomerSessionContext {
  customerId: string;
  magentoCustomerToken: string;
}

export interface MagentoAuthenticationResult extends MagentoCustomerSessionContext {
  customerEmail: string;
}

export abstract class CustomerAuthPort {
  abstract authenticateCustomer(email: string, password: string): Promise<MagentoAuthenticationResult>;
  abstract fetchCustomerSummary(context: MagentoCustomerSessionContext): Promise<MagentoCustomerSummary>;
}
