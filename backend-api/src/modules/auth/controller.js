const { loginSchema, changePasswordSchema, forgotPasswordSchema } = require('./schema');
const service = require('./service');
const { publicError } = require('../../middlewares/authenticate');

function validate(schema, body) {
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    const details = parsed.error.issues.map((issue) => ({
      field: issue.path.join('.'),
      message: issue.message,
    }));
    throw publicError(400, 'VALIDATION_ERROR', 'Data permintaan tidak valid.', details);
  }
  return parsed.data;
}

async function login(req, res, next) {
  try {
    const body = validate(loginSchema, req.body);
    const data = await service.login({ ...body, ipAddress: req.ip });
    res.json({ data });
  } catch (error) { next(error); }
}

async function logout(req, res, next) {
  try {
    await service.logout(req.user.id, req.user.jti, req.ip);
    res.json({ data: null });
  } catch (error) { next(error); }
}

async function changePassword(req, res, next) {
  try {
    const body = validate(changePasswordSchema, req.body);
    await service.changePassword({
      userId: req.user.id,
      identifier: req.user.identifier,
      ...body,
      ipAddress: req.ip,
    });
    res.json({ data: null });
  } catch (error) { next(error); }
}

async function forgotPassword(req, res, next) {
  try {
    const body = validate(forgotPasswordSchema, req.body);
    await service.forgotPassword(body.identifier, req.ip);
    res.json({ data: {} });
  } catch (error) { next(error); }
}

async function getMe(req, res, next) {
  try {
    const data = await service.getProfile(req.user.id, req.query.deviceId);
    res.json({ data });
  } catch (error) { next(error); }
}

async function getPasswordHistories(req, res, next) {
  try {
    const data = await service.getPasswordHistories(req.user.id);
    res.json({ data });
  } catch (error) { next(error); }
}

module.exports = { login, logout, changePassword, forgotPassword, getMe, getPasswordHistories };
