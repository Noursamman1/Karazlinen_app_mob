# Runtime Configuration

Required environment variables are validated at startup through `src/config/env.schema.ts`.

Key groups:
- application: `APP_NAME`, `NODE_ENV`, `PORT`, `LOG_LEVEL`
- auth: `ACCESS_TOKEN_PRIVATE_KEY`, `ACCESS_TOKEN_PUBLIC_KEY`, `ACCESS_TOKEN_TTL_SECONDS`, `REFRESH_TOKEN_TTL_DAYS`
- redis: `REDIS_URL`
- magento: `MAGENTO_BASE_URL`, `MAGENTO_STORE_CODE`, `MAGENTO_TIMEOUT_MS`, `MAGENTO_GRAPHQL_PATH`, `MAGENTO_CUSTOMER_TOKEN_PATH`
- rate limiting: `RATE_LIMIT_WINDOW_SECONDS`, `RATE_LIMIT_MAX_REQUESTS`
