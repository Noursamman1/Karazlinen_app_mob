# Integration and E2E Readiness

This hardening phase prepares the BFF for safer sandbox verification, but full integration checks still require external environment access.

Server readiness checklist:
- Redis reachable from the BFF runtime
- Magento sandbox storefront URL configured in `MAGENTO_BASE_URL`
- Correct sandbox store view code configured in `MAGENTO_STORE_CODE`
- Non-placeholder JWT keys configured for any shared or hosted environment
- Rate-limit and timeout values reviewed for the target environment

Magento sandbox readiness:
- At least one customer test account with known credentials
- Customer account enabled and able to receive storefront tokens
- GraphQL storefront endpoint reachable from the BFF
- No admin credentials or integration secrets stored in repository files

Suggested verification flow:
1. Boot Redis and BFF with sandbox runtime variables.
2. Verify `GET /health/live` and `GET /health/ready`.
3. Execute `POST /v1/auth/login` with a sandbox customer.
4. Execute `GET /v1/auth/me` with the returned BFF access token.
5. Execute `POST /v1/auth/refresh` using the same `x-device-id` when the session is device-bound.
6. Execute `POST /v1/auth/logout` and verify the revoked session cannot be refreshed.

Blocked by environment when missing:
- sandbox URL
- sandbox customer account
- Redis endpoint aligned with the sandbox runtime
