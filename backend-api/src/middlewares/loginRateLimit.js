const attempts = new Map();

function loginRateLimit(req, res, next) {
  if (process.env.LOGIN_RATE_LIMIT_ENABLED !== 'true') return next();

  const key = req.ip || 'unknown';
  const now = Date.now();
  const entry = attempts.get(key);
  if (!entry || entry.resetAt <= now) {
    attempts.set(key, { count: 1, resetAt: now + 60 * 1000 });
    return next();
  }

  if (entry.count >= 5) {
    return res.status(429).json({
      error: {
        code: 'RATE_LIMITED',
        message: 'Terlalu banyak percobaan login. Coba lagi sebentar lagi.',
        details: [],
      },
    });
  }

  entry.count += 1;
  next();
}

module.exports = { loginRateLimit };
