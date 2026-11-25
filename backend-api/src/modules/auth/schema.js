const { z } = require('zod');

const loginSchema = z.object({
  identifier: z.string().trim().min(1),
  password: z.string().min(1),
});

const changePasswordSchema = z.object({
  currentPassword: z.string().min(1),
  newPassword: z.string().min(1),
  confirmPassword: z.string().min(1),
}).refine((value) => value.newPassword === value.confirmPassword, {
  message: 'Konfirmasi password tidak sama.',
  path: ['confirmPassword'],
});

const forgotPasswordSchema = z.object({
  identifier: z.string().trim().min(1),
});

module.exports = { loginSchema, changePasswordSchema, forgotPasswordSchema };
