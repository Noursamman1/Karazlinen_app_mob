export type SessionRecord = {
  sessionId: string;
  customerId: string;
  deviceId?: string;
  customerEmail?: string;
  magentoCustomerToken?: string;
  refreshTokenHash: string;
  refreshExpiresAt: string;
  createdAt: string;
  lastSeenAt?: string;
  revokedAt?: string;
  revokedReason?: string;
};
