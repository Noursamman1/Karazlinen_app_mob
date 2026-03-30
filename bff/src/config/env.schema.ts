import { z } from 'zod';

export const envSchema = z.object({
  APP_NAME: z.string().default('karaz-mobile-bff'),
  NODE_ENV: z.enum(['development', 'test', 'staging', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  ACCESS_TOKEN_PRIVATE_KEY: z.string().min(1),
  ACCESS_TOKEN_PUBLIC_KEY: z.string().min(1),
  ACCESS_TOKEN_TTL_SECONDS: z.coerce.number().int().positive().default(300),
  REFRESH_TOKEN_TTL_DAYS: z.coerce.number().int().positive().default(30),
  REDIS_URL: z.string().url(),
  MAGENTO_BASE_URL: z.string().url(),
  MAGENTO_STORE_CODE: z.string().min(1),
  MAGENTO_TIMEOUT_MS: z.coerce.number().int().positive().default(5000),
  MAGENTO_GRAPHQL_PATH: z.string().default('/graphql'),
  MAGENTO_CUSTOMER_TOKEN_PATH: z.string().default('/rest/V1/integration/customer/token'),
  RATE_LIMIT_WINDOW_SECONDS: z.coerce.number().int().positive().default(60),
  RATE_LIMIT_MAX_REQUESTS: z.coerce.number().int().positive().default(120)
});

export type EnvSchema = z.infer<typeof envSchema>;
