const express = require('express');
const multer = require('multer');
const { authenticate, requireRole, requirePasswordChanged } = require('../../middlewares/authenticate');
const controller = require('./controller');

const router = express.Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

const studentGuard = [authenticate, requireRole('student'), requirePasswordChanged];

router.get('/student/home/assignments', ...studentGuard, controller.getHomeAssignments);
router.get('/student/courses', ...studentGuard, controller.getCourses);
router.get('/student/courses/:courseId', ...studentGuard, controller.getCourseDetail);
router.get('/student/assignments/:assignmentId', ...studentGuard, controller.getAssignmentDetail);
router.post('/student/assignments/:assignmentId/submissions', ...studentGuard, upload.single('file'), controller.uploadSubmission);
router.get('/student/assignments/:assignmentId/submissions', ...studentGuard, controller.getSubmissionHistory);

module.exports = router;
