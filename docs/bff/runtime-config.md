# Runtime Configuration

Required environment variables are validated at startup through `src/config/env.schema.ts`.

Key groups:
- application: `APP_NAME`, `NODE_ENV`, `PORT`, `LOG_LEVEL`
- auth: `ACCESS_TOKEN_PRIVATE_KEY`, `ACCESS_TOKEN_PUBLIC_KEY`, `ACCESS_TOKEN_TTL_SECONDS`, `REFRESH_TOKEN_TTL_DAYS`, `MAX_ACTIVE_SESSIONS_PER_CUSTOMER`
- request lifecycle: `REQUEST_TIMEOUT_MS`
- redis: `REDIS_URL`
- magento: `MAGENTO_BASE_URL`, `MAGENTO_STORE_CODE`, `MAGENTO_TIMEOUT_MS`, `MAGENTO_GRAPHQL_PATH`, `MAGENTO_CUSTOMER_TOKEN_PATH`, `MAGENTO_RETRY_ATTEMPTS`, `MAGENTO_RETRY_BACKOFF_MS`, `MAGENTO_CIRCUIT_BREAKER_THRESHOLD`, `MAGENTO_CIRCUIT_BREAKER_RESET_MS`
- rate limiting: `RATE_LIMIT_WINDOW_SECONDS`, `RATE_LIMIT_MAX_REQUESTS`, `RATE_LIMIT_AUTH_WINDOW_SECONDS`, `RATE_LIMIT_AUTH_LOGIN_MAX_REQUESTS`, `RATE_LIMIT_AUTH_REFRESH_MAX_REQUESTS`, `RATE_LIMIT_AUTH_ME_MAX_REQUESTS`

Sandbox notes:
- `MAGENTO_BASE_URL` must point to the sandbox storefront host.
- `MAGENTO_STORE_CODE` must match the sandbox store view used for mobile.
- Magento credentials are user-provided at runtime; no admin or integration secrets are stored in the repository.
- In `staging` and `production`, JWT keys must not be placeholder values and Magento base URL must use `https`.
