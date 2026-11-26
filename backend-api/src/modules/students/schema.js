const { z } = require('zod');

const uuidParamsSchema = z.object({
  courseId: z.string().uuid('ID mata kuliah tidak valid.'),
}).partial({ courseId: true });

const assignmentParamsSchema = z.object({
  assignmentId: z.string().uuid('ID tugas tidak valid.'),
});

module.exports = { uuidParamsSchema, assignmentParamsSchema };
