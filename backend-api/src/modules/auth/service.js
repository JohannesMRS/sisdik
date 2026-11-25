const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { query } = require('../../config/db');
const { hashPassword, verifyPassword, validatePasswordPolicy } = require('../../utils/password');
const { writeAudit } = require('../../utils/audit');
const { publicError } = require('../../middlewares/authenticate');

async function findUserWithProfile(identifier) {
  const result = await query(
    `SELECT u.id, u.identifier, u.role, u.password_hash, u.must_change_password, u.is_active,
            s.full_name, s.gpa, l.full_name AS lecturer_name
     FROM users u
     LEFT JOIN students s ON s.user_id = u.id
     LEFT JOIN lecturers l ON l.user_id = u.id
     WHERE u.identifier = $1`,
    [identifier],
  );
  return result.rows[0] || null;
}

function buildUser(user) {
  const name = user.role === 'student' ? user.full_name : user.lecturer_name;
  const base = {
    id: user.id,
    identifier: user.identifier,
    role: user.role,
    name,
    mustChangePassword: user.must_change_password,
  };
  if (user.role === 'student') {
    return { ...base, nim: user.identifier, gpa: Number(user.gpa) };
  }
  return { ...base, nip: user.identifier };
}

async function login({ identifier, password, ipAddress }) {
  let validUser = null;
  const user = await findUserWithProfile(identifier);

  if (user?.is_active) {
    validUser = (await verifyPassword(user.password_hash, password)) ? user : null;
  } else {
    await hashPassword('dummy-password-for-timing-protection-123');
  }

  if (!validUser) {
    await writeAudit({ action: 'auth.login.failed', ipAddress, metadata: { identifier } });
    throw publicError(401, 'INVALID_CREDENTIALS', 'NIM/NIP atau password salah.');
  }

  const jti = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 30 * 60 * 1000);
  await query(
    'INSERT INTO sessions (id, user_id, expires_at) VALUES ($1, $2, $3)',
    [jti, validUser.id, expiresAt.toISOString()],
  );

  const token = jwt.sign(
    { sub: validUser.id, role: validUser.role, jti },
    process.env.JWT_SECRET,
    { algorithm: 'HS256', expiresIn: '30m' },
  );

  await writeAudit({ userId: validUser.id, action: 'auth.login.success', ipAddress });
  return { token, expiresAt: expiresAt.toISOString(), user: buildUser(validUser) };
}

async function logout(userId, jti, ipAddress) {
  await query('UPDATE sessions SET revoked_at = now() WHERE id = $1 AND user_id = $2', [jti, userId]);
  await writeAudit({ userId, action: 'auth.logout', ipAddress });
}

async function changePassword({ userId, identifier, currentPassword, newPassword, confirmPassword, ipAddress }) {
  if (newPassword !== confirmPassword) {
    throw publicError(400, 'VALIDATION_ERROR', 'Konfirmasi password tidak sama.', [{ field: 'confirmPassword', message: 'Konfirmasi password tidak sama.' }]);
  }

  const userResult = await query('SELECT password_hash FROM users WHERE id = $1', [userId]);
  const currentHash = userResult.rows[0]?.password_hash;
  if (!currentHash || !(await verifyPassword(currentHash, currentPassword))) {
    throw publicError(400, 'VALIDATION_ERROR', 'Password lama salah.', [{ field: 'currentPassword', message: 'Password lama salah.' }]);
  }

  const policyDetails = validatePasswordPolicy(newPassword, identifier, currentPassword);
  if (policyDetails.length) {
    throw publicError(400, 'VALIDATION_ERROR', 'Password baru tidak memenuhi kebijakan.', policyDetails);
  }

  const passwordHash = await hashPassword(newPassword);
  const { pool } = require('../../config/db');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const statusBefore = await client.query('SELECT must_change_password FROM users WHERE id = $1', [userId]);
    const changeType = statusBefore.rows[0]?.must_change_password ? 'forced_change' : 'self_change';
    await client.query('UPDATE users SET password_hash = $1, must_change_password = false, updated_at = now() WHERE id = $2', [passwordHash, userId]);
    await client.query('UPDATE sessions SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL', [userId]);
    await client.query('UPDATE biometric_credentials SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL', [userId]);
    await client.query('INSERT INTO password_histories (user_id, change_type) VALUES ($1, $2)', [userId, changeType]);

    await client.query(
      `INSERT INTO audit_logs (user_id, action, ip_address, metadata)
       VALUES ($1, 'auth.password.changed', $2, '{}'::jsonb)`,
      [userId, ipAddress],
    );
    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }

  return null;
}

async function forgotPassword(identifier, ipAddress) {
  const result = await query('SELECT id FROM users WHERE identifier = $1', [identifier]);
  if (result.rows[0]) {
    await query("INSERT INTO password_reset_requests (user_id, status) VALUES ($1, 'pending')", [result.rows[0].id]);
  }
  await writeAudit({ userId: result.rows[0]?.id || null, action: 'auth.password.forgot.requested', ipAddress, metadata: { identifier } });
  return null;
}

async function getProfile(userId, deviceId) {
  const result = await query(
    `SELECT u.id, u.identifier, u.role, u.must_change_password,
            s.full_name, s.gpa,
            l.full_name AS lecturer_name
     FROM users u
     LEFT JOIN students s ON s.user_id = u.id
     LEFT JOIN lecturers l ON l.user_id = u.id
     WHERE u.id = $1`,
    [userId],
  );
  if (!result.rows[0]) throw publicError(404, 'NOT_FOUND', 'Data tidak ditemukan.');

  const user = result.rows[0];
  const profile = buildUser(user);
  let biometricEnabled = false;
  if (deviceId) {
    const biometric = await query(
      `SELECT 1 FROM biometric_credentials
       WHERE user_id = $1 AND device_id = $2 AND revoked_at IS NULL AND expires_at > now() LIMIT 1`,
      [userId, deviceId],
    );
    biometricEnabled = biometric.rowCount > 0;
  }
  return { ...profile, biometricEnabled, gpa: profile.gpa };
}

async function getPasswordHistories(userId) {
  const result = await query(
    'SELECT changed_at, change_type FROM password_histories WHERE user_id = $1 ORDER BY changed_at DESC',
    [userId],
  );
  return result.rows.map((row) => ({ changedAt: row.changed_at, type: row.change_type }));
}

module.exports = { login, logout, changePassword, forgotPassword, getProfile, getPasswordHistories };
