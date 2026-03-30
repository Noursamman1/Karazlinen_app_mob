import { z } from 'zod';

const insecureSecretValues = new Set(['replace-me', 'test-secret', 'changeme']);

export const envSchema = z
  .object({
    APP_NAME: z.string().default('karaz-mobile-bff'),
    NODE_ENV: z.enum(['development', 'test', 'staging', 'production']).default('development'),
    PORT: z.coerce.number().int().positive().default(3000),
    LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
    ACCESS_TOKEN_PRIVATE_KEY: z.string().min(1),
    ACCESS_TOKEN_PUBLIC_KEY: z.string().min(1),
    ACCESS_TOKEN_TTL_SECONDS: z.coerce.number().int().positive().default(300),
    REFRESH_TOKEN_TTL_DAYS: z.coerce.number().int().positive().default(30),
    MAX_ACTIVE_SESSIONS_PER_CUSTOMER: z.coerce.number().int().positive().default(5),
    REQUEST_TIMEOUT_MS: z.coerce.number().int().positive().default(15000),
    REDIS_URL: z.string().url(),
    MAGENTO_BASE_URL: z.string().url(),
    MAGENTO_STORE_CODE: z.string().min(1),
    MAGENTO_TIMEOUT_MS: z.coerce.number().int().positive().default(5000),
    MAGENTO_GRAPHQL_PATH: z.string().default('/graphql'),
    MAGENTO_CUSTOMER_TOKEN_PATH: z.string().default('/rest/V1/integration/customer/token'),
    MAGENTO_RETRY_ATTEMPTS: z.coerce.number().int().min(0).max(5).default(2),
    MAGENTO_RETRY_BACKOFF_MS: z.coerce.number().int().positive().default(250),
    MAGENTO_CIRCUIT_BREAKER_THRESHOLD: z.coerce.number().int().positive().default(5),
    MAGENTO_CIRCUIT_BREAKER_RESET_MS: z.coerce.number().int().positive().default(30000),
    RATE_LIMIT_WINDOW_SECONDS: z.coerce.number().int().positive().default(60),
    RATE_LIMIT_MAX_REQUESTS: z.coerce.number().int().positive().default(120),
    RATE_LIMIT_AUTH_WINDOW_SECONDS: z.coerce.number().int().positive().default(60),
    RATE_LIMIT_AUTH_LOGIN_MAX_REQUESTS: z.coerce.number().int().positive().default(10),
    RATE_LIMIT_AUTH_REFRESH_MAX_REQUESTS: z.coerce.number().int().positive().default(20),
    RATE_LIMIT_AUTH_ME_MAX_REQUESTS: z.coerce.number().int().positive().default(60)
  })
  .superRefine((env, context) => {
    const enforceStrongSecrets = env.NODE_ENV === 'staging' || env.NODE_ENV === 'production';

    if (enforceStrongSecrets) {
      if (
        env.ACCESS_TOKEN_PRIVATE_KEY.length < 16 ||
        insecureSecretValues.has(env.ACCESS_TOKEN_PRIVATE_KEY.toLowerCase())
      ) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['ACCESS_TOKEN_PRIVATE_KEY'],
          message: 'ACCESS_TOKEN_PRIVATE_KEY must be rotated and non-placeholder outside development/test'
        });
      }

      if (
        env.ACCESS_TOKEN_PUBLIC_KEY.length < 16 ||
        insecureSecretValues.has(env.ACCESS_TOKEN_PUBLIC_KEY.toLowerCase())
      ) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['ACCESS_TOKEN_PUBLIC_KEY'],
          message: 'ACCESS_TOKEN_PUBLIC_KEY must be rotated and non-placeholder outside development/test'
        });
      }

      if (!env.MAGENTO_BASE_URL.startsWith('https://')) {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['MAGENTO_BASE_URL'],
          message: 'MAGENTO_BASE_URL must use https outside development/test'
        });
      }
    }
  });

export type EnvSchema = z.infer<typeof envSchema>;
