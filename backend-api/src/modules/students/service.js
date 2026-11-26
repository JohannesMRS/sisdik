const crypto = require('crypto');
const fs = require('fs/promises');
const path = require('path');
const { pool, query } = require('../../config/db');
const { publicError } = require('../../middlewares/authenticate');
const { writeAudit } = require('../../utils/audit');

async function deniedAudit(userId, ipAddress, entityType, entityId) {
  await writeAudit({ userId, action: 'ACCESS_DENIED', entityType, entityId, ipAddress });
}

function assignmentStatus(row) {
  if (row.submitted_at) return 'Sudah dikumpulkan';
  if (new Date(row.deadline) < new Date()) return 'Lewat deadline';
  return 'Belum dikumpulkan';
}

async function getHomeAssignments(studentId, ipAddress) {
  const result = await query(`
    SELECT a.id, c.code AS course_code, c.name AS course_name, a.title, a.description,
           a.deadline, s.submitted_at
    FROM student_courses sc
    JOIN courses c ON c.id = sc.course_id
    JOIN assignments a ON a.course_id = c.id
    LEFT JOIN LATERAL (
      SELECT submitted_at FROM assignment_submissions
      WHERE assignment_id = a.id AND student_id = $1 AND is_latest = true
    ) s ON true
    WHERE sc.student_id = $1
      AND (s.submitted_at IS NOT NULL OR a.deadline >= now() - interval '30 days')
    ORDER BY (s.submitted_at IS NULL) DESC,
             CASE WHEN s.submitted_at IS NULL THEN a.deadline END ASC,
             a.deadline DESC
    LIMIT 20
  `, [studentId]);

  return result.rows.map((row) => ({
    id: row.id,
    courseCode: row.course_code,
    courseName: row.course_name,
    title: row.title,
    description: row.description,
    deadline: row.deadline,
    status: assignmentStatus(row),
  }));
}

async function getCourses(studentId) {
  const result = await query(`
    SELECT sc.academic_term, c.id, c.code, c.name, c.credits, c.semester
    FROM student_courses sc
    JOIN courses c ON c.id = sc.course_id
    WHERE sc.student_id = $1
    ORDER BY c.semester ASC, c.code ASC
  `, [studentId]);

  const semesters = new Map();
  for (const row of result.rows) {
    const key = String(row.semester);
    if (!semesters.has(key)) semesters.set(key, { semester: row.semester, academicTerm: row.academic_term, courses: [] });
    semesters.get(key).courses.push({ id: row.id, code: row.code, name: row.name, credits: row.credits });
  }
  return [...semesters.values()];
}

async function getCourseDetail(studentId, courseId, ipAddress) {
  const course = await query(`
    SELECT c.id, c.code, c.name, c.credits, c.semester
    FROM student_courses sc
    JOIN courses c ON c.id = sc.course_id
    WHERE sc.student_id = $1 AND c.id = $2
  `, [studentId, courseId]);
  if (!course.rows[0]) {
    await deniedAudit(studentId, ipAddress, 'course', courseId);
    throw publicError(404, 'NOT_FOUND', 'Mata kuliah tidak ditemukan.');
  }

  const schedules = await query(`
    SELECT day_of_week, start_time, end_time, room
    FROM course_schedules WHERE course_id = $1 ORDER BY day_of_week, start_time
  `, [courseId]);
  const assignments = await query(`
    SELECT a.id, a.title, a.deadline, s.submitted_at,
           l.full_name AS lecturer_name
    FROM assignments a
    JOIN lecturer_courses lc ON lc.course_id = a.course_id
    JOIN lecturers l ON l.user_id = lc.lecturer_id
    LEFT JOIN LATERAL (
      SELECT submitted_at FROM assignment_submissions
      WHERE assignment_id = a.id AND student_id = $2 AND is_latest = true
    ) s ON true
    WHERE a.course_id = $1 ORDER BY a.deadline ASC
  `, [courseId, studentId]);

  return {
    ...course.rows[0],
    schedules: schedules.rows,
    lecturer: assignments.rows[0]?.lecturer_name || null,
    assignments: assignments.rows.map((row) => ({ id: row.id, title: row.title, deadline: row.deadline, status: assignmentStatus(row) })),
  };
}

async function getAssignmentDetail(studentId, assignmentId, ipAddress) {
  const result = await query(`
    SELECT a.id, a.title, a.description, a.deadline,
           c.id AS course_id, c.code AS course_code, c.name AS course_name,
           s.submitted_at
    FROM assignments a
    JOIN courses c ON c.id = a.course_id
    JOIN student_courses sc ON sc.course_id = c.id AND sc.student_id = $1
    LEFT JOIN LATERAL (
      SELECT submitted_at FROM assignment_submissions
      WHERE assignment_id = a.id AND student_id = $1 AND is_latest = true
    ) s ON true
    WHERE a.id = $2
  `, [studentId, assignmentId]);
  if (!result.rows[0]) {
    await deniedAudit(studentId, ipAddress, 'assignment', assignmentId);
    throw publicError(404, 'NOT_FOUND', 'Tugas tidak ditemukan.');
  }
  const row = result.rows[0];
  return {
    id: row.id,
    courseId: row.course_id,
    courseCode: row.course_code,
    courseName: row.course_name,
    title: row.title,
    description: row.description,
    deadline: row.deadline,
    status: assignmentStatus(row),
  };
}

async function getSubmissionHistory(studentId, assignmentId, ipAddress) {
  const owned = await query(`
    SELECT 1 FROM assignments a
    JOIN student_courses sc ON sc.course_id = a.course_id AND sc.student_id = $1
    WHERE a.id = $2
  `, [studentId, assignmentId]);
  if (!owned.rows[0]) {
    await deniedAudit(studentId, ipAddress, 'assignment', assignmentId);
    throw publicError(404, 'NOT_FOUND', 'Tugas tidak ditemukan.');
  }
  const result = await query(`
    SELECT id, original_filename, mime_type, size_bytes, submitted_at, is_latest
    FROM assignment_submissions
    WHERE assignment_id = $1 AND student_id = $2
    ORDER BY submitted_at DESC
  `, [assignmentId, studentId]);
  return result.rows.map((row) => ({
    id: row.id,
    originalFilename: row.original_filename,
    mimeType: row.mime_type,
    sizeBytes: row.size_bytes,
    submittedAt: row.submitted_at,
    isLatest: row.is_latest,
  }));
}

function validateFile(file) {
  if (!file) throw publicError(400, 'VALIDATION_ERROR', 'File wajib dipilih.', [{ field: 'file', message: 'File wajib dipilih.' }]);
  if (file.size > 10 * 1024 * 1024) throw publicError(413, 'FILE_TOO_LARGE', 'Ukuran file maksimal 10 MB.');

  const lowerName = file.originalname.toLowerCase();
  const ext = path.extname(lowerName);
  const data = file.buffer;
  const pdf = data.length >= 5 && data.subarray(0, 5).toString('ascii') === '%PDF-';
  const zip = data.length >= 4 && data[0] === 0x50 && data[1] === 0x4b && (data[2] === 0x03 || data[2] === 0x05 || data[2] === 0x07);

  let allowed = false;
  if (ext === '.pdf' && pdf && ['application/pdf'].includes(file.mimetype)) allowed = true;
  if (ext === '.zip' && zip && ['application/zip', 'application/x-zip-compressed'].includes(file.mimetype)) allowed = true;
  if (ext === '.docx' && zip && ['application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/zip'].includes(file.mimetype)) allowed = true;
  if (!allowed) throw publicError(400, 'FILE_TYPE_NOT_ALLOWED', 'File harus berupa PDF, DOCX, atau ZIP yang valid.');
}

async function uploadSubmission(studentId, assignmentId, file, ipAddress) {
  validateFile(file);
  const owned = await query(`
    SELECT a.deadline FROM assignments a
    JOIN student_courses sc ON sc.course_id = a.course_id AND sc.student_id = $1
    WHERE a.id = $2
  `, [studentId, assignmentId]);
  if (!owned.rows[0]) {
    await deniedAudit(studentId, ipAddress, 'assignment', assignmentId);
    throw publicError(404, 'NOT_FOUND', 'Tugas tidak ditemukan.');
  }
  if (new Date(owned.rows[0].deadline) <= new Date()) {
    throw publicError(400, 'DEADLINE_PASSED', 'Pengumpulan ditolak karena deadline telah lewat.');
  }

  const ext = path.extname(file.originalname).toLowerCase();
  const storedFilename = `${crypto.randomUUID()}${ext}`;
  const storedPath = path.resolve(__dirname, '../../../uploads', storedFilename);
  const sha256 = crypto.createHash('sha256').update(file.buffer).digest('hex');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query('UPDATE assignment_submissions SET is_latest = false WHERE assignment_id = $1 AND student_id = $2 AND is_latest = true', [assignmentId, studentId]);
    await client.query(`
      INSERT INTO assignment_submissions
        (assignment_id, student_id, original_filename, stored_filename, mime_type, size_bytes, sha256, is_latest)
      VALUES ($1, $2, $3, $4, $5, $6, $7, true)
    `, [assignmentId, studentId, file.originalname, storedFilename, file.mimetype, file.size, sha256]);
    await fs.mkdir(path.dirname(storedPath), { recursive: true });
    await fs.writeFile(storedPath, file.buffer);
    await client.query(`INSERT INTO audit_logs (user_id, action, entity_type, entity_id, ip_address, metadata)
      VALUES ($1, 'SUBMISSION_UPLOADED', 'assignment', $2, $3, '{}'::jsonb)`, [studentId, assignmentId, ipAddress]);
    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }

  return { originalFilename: file.originalname, sizeBytes: file.size, isLatest: true, submittedAt: new Date().toISOString() };
}

module.exports = { getHomeAssignments, getCourses, getCourseDetail, getAssignmentDetail, getSubmissionHistory, uploadSubmission };
