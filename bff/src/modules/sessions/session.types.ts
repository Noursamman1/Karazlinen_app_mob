export type SessionRecord = {
  sessionId: string;
  customerId: string;
  deviceId?: string;
  customerEmail?: string;
  magentoCustomerToken?: string;
  magentoCartId?: string;
  refreshTokenHash: string;
  refreshExpiresAt: string;
  createdAt: string;
  lastSeenAt?: string;
  revokedAt?: string;
  revokedReason?: string;
};

export type MagentoSessionContext = {
  sessionId: string;
  customerId: string;
  customerEmail?: string;
  magentoCustomerToken: string;
  magentoCartId?: string;
};
