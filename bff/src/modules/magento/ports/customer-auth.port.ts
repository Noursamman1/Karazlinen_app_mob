export interface MagentoCustomerSummary {
  customerId: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
}

export abstract class CustomerAuthPort {
  abstract authenticateCustomer(email: string, password: string): Promise<{ customerId: string }>;
  abstract fetchCustomerSummary(customerId: string): Promise<MagentoCustomerSummary>;
}
