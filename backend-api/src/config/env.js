const { z } = require('zod');

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL wajib diisi'),
  JWT_SECRET: z.string().min(32, 'JWT_SECRET minimal 32 karakter'),
  LOGIN_RATE_LIMIT_ENABLED: z
    .enum(['true', 'false'])
    .optional()
    .default('false'),
});

function validateEnv(environment = process.env) {
  const parsed = envSchema.safeParse(environment);
  if (!parsed.success) {
    const messages = parsed.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`);
    throw new Error(`Konfigurasi environment tidak valid: ${messages.join(', ')}`);
  }
  return parsed.data;
}

module.exports = { validateEnv };
