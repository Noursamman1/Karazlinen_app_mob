import { envSchema } from '../../src/config/env.schema';

describe('env schema', () => {
  it('parses valid env', () => {
    const parsed = envSchema.parse({
      APP_NAME: 'karaz',
      NODE_ENV: 'development',
      PORT: '3000',
      LOG_LEVEL: 'info',
      ACCESS_TOKEN_PRIVATE_KEY: 'private',
      ACCESS_TOKEN_PUBLIC_KEY: 'private',
      ACCESS_TOKEN_TTL_SECONDS: '300',
      REFRESH_TOKEN_TTL_DAYS: '30',
      REDIS_URL: 'redis://localhost:6379',
      MAGENTO_BASE_URL: 'https://example.com',
      MAGENTO_STORE_CODE: 'default',
      MAGENTO_TIMEOUT_MS: '5000',
      MAGENTO_GRAPHQL_PATH: '/graphql',
      MAGENTO_CUSTOMER_TOKEN_PATH: '/rest/V1/integration/customer/token',
      RATE_LIMIT_WINDOW_SECONDS: '60',
      RATE_LIMIT_MAX_REQUESTS: '120'
    });
    expect(parsed.PORT).toBe(3000);
  });
});
