# Auth and Session Notes

- Access tokens are BFF-issued JWT bearer tokens.
- Refresh tokens are opaque and rotated on every refresh.
- Magento credentials and customer tokens never leave the server.
- Session persistence and rate-limit counters use Redis-backed abstractions.
- The session record stores Magento customer token context server-side for authenticated profile reads.
- `GET /v1/auth/me` validates the JWT `sid`, loads active session state from Redis, then calls Magento with the stored token.
- If `x-device-id` is provided at login, the session becomes device-bound and refresh requests must present the same header.
- A new login on the same customer + device revokes the previous device session.
- Customer logout can revoke only sessions owned by that authenticated customer.
- Active session count is capped server-side through `MAX_ACTIVE_SESSIONS_PER_CUSTOMER`, revoking the oldest session first when needed.
