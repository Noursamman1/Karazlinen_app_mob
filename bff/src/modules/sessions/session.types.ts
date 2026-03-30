export type SessionRecord = {
  sessionId: string;
  customerId: string;
  deviceId: string;
  customerEmail?: string;
  refreshTokenHash: string;
  expiresAt: string;
  createdAt: string;
  revokedAt?: string;
};
