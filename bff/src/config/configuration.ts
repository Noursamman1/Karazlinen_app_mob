import { envSchema, type EnvSchema } from './env.schema';

export function configuration(): EnvSchema {
  return envSchema.parse(process.env);
}
