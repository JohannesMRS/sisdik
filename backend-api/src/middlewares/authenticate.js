const jwt = require('jsonwebtoken');
const { query } = require('../config/db');

function publicError(status, code, message, details = []) {
  const error = new Error(message);
  error.status = status;
  error.code = code;
  error.publicMessage = message;
  error.details = details;
  return error;
}

async function authenticate(req, res, next) {
  try {
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw publicError(401, 'TOKEN_REVOKED', 'Sesi tidak valid atau telah berakhir.');
    }

    let payload;
    try {
      payload = jwt.verify(header.slice(7), process.env.JWT_SECRET, { algorithms: ['HS256'] });
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw publicError(401, 'TOKEN_EXPIRED', 'Sesi telah berakhir.');
      }
      throw publicError(401, 'TOKEN_REVOKED', 'Sesi tidak valid atau telah berakhir.');
    }

    const sessionResult = await query(
      `SELECT s.id, s.expires_at, s.revoked_at, u.id AS user_id, u.identifier, u.role, u.is_active, u.must_change_password
       FROM sessions s
       JOIN users u ON u.id = s.user_id
       WHERE s.id = $1 AND u.id = $2`,
      [payload.jti, payload.sub],
    );

    const session = sessionResult.rows[0];
    if (!session || !session.is_active || session.revoked_at || new Date(session.expires_at) <= new Date()) {
      throw publicError(401, 'TOKEN_REVOKED', 'Sesi telah dicabut atau berakhir.');
    }

    req.user = {
      id: session.user_id,
      identifier: session.identifier,
      role: session.role,
      jti: payload.jti,
      mustChangePassword: session.must_change_password,
    };
    next();
  } catch (error) {
    next(error);
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(publicError(403, 'FORBIDDEN', 'Anda tidak memiliki hak akses untuk tindakan ini.'));
    }
    next();
  };
}

function requirePasswordChanged(req, res, next) {
  if (req.user?.mustChangePassword) {
    return next(publicError(403, 'PASSWORD_CHANGE_REQUIRED', 'Anda wajib mengganti password terlebih dahulu.'));
  }
  next();
}

module.exports = { authenticate, requireRole, requirePasswordChanged, publicError };
