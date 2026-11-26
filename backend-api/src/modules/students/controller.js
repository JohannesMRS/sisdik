const { assignmentParamsSchema, uuidParamsSchema } = require('./schema');
const service = require('./service');
const { publicError } = require('../../middlewares/authenticate');

function validate(schema, params) {
  const parsed = schema.safeParse(params);
  if (!parsed.success) {
    throw publicError(400, 'VALIDATION_ERROR', 'ID tidak valid.', parsed.error.issues.map((issue) => ({ field: issue.path.join('.'), message: issue.message })));
  }
}

async function getHomeAssignments(req, res, next) {
  try { res.json({ data: await service.getHomeAssignments(req.user.id, req.ip) }); }
  catch (error) { next(error); }
}
async function getCourses(req, res, next) {
  try { res.json({ data: await service.getCourses(req.user.id) }); }
  catch (error) { next(error); }
}
async function getCourseDetail(req, res, next) {
  try {
    validate(uuidParamsSchema, { courseId: req.params.courseId });
    res.json({ data: await service.getCourseDetail(req.user.id, req.params.courseId, req.ip) });
  } catch (error) { next(error); }
}
async function getAssignmentDetail(req, res, next) {
  try {
    validate(assignmentParamsSchema, req.params);
    res.json({ data: await service.getAssignmentDetail(req.user.id, req.params.assignmentId, req.ip) });
  } catch (error) { next(error); }
}
async function getSubmissionHistory(req, res, next) {
  try {
    validate(assignmentParamsSchema, req.params);
    res.json({ data: await service.getSubmissionHistory(req.user.id, req.params.assignmentId, req.ip) });
  } catch (error) { next(error); }
}
async function uploadSubmission(req, res, next) {
  try {
    validate(assignmentParamsSchema, req.params);
    const data = await service.uploadSubmission(req.user.id, req.params.assignmentId, req.file, req.ip);
    res.status(201).json({ data });
  } catch (error) {
    if (error.code === 'LIMIT_FILE_SIZE') return next(publicError(413, 'FILE_TOO_LARGE', 'Ukuran file maksimal 10 MB.'));
    next(error);
  }
}

module.exports = { getHomeAssignments, getCourses, getCourseDetail, getAssignmentDetail, getSubmissionHistory, uploadSubmission };
