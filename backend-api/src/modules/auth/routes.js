const express = require('express');
const controller = require('./controller');
const { authenticate, requirePasswordChanged } = require('../../middlewares/authenticate');
const { loginRateLimit } = require('../../middlewares/loginRateLimit');

const router = express.Router();

router.post('/auth/login', loginRateLimit, controller.login);
router.post('/auth/forgot-password', controller.forgotPassword);

router.post('/auth/logout', authenticate, controller.logout);
router.post('/auth/change-password', authenticate, controller.changePassword);

router.get('/me', authenticate, controller.getMe);
router.get('/me/password-histories', authenticate, requirePasswordChanged, controller.getPasswordHistories);

module.exports = router;
