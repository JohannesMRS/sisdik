require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const crypto = require('crypto');
const argon2 = require('argon2');
const { Pool } = require('pg');

async function main() {
  const identifier = process.argv.find((value, index) => index > 1 && value === '--identifier')
    ? process.argv[process.argv.indexOf('--identifier') + 1]
    : null;
  if (!identifier) throw new Error('Gunakan --identifier NIM_ATAU_NIP');

  const temporaryPassword = crypto.randomBytes(6).toString('base64url') + 'A1';
  const passwordHash = await argon2.hash(temporaryPassword, {
    type: argon2.argon2id,
    memoryCost: 19456,
    timeCost: 2,
    parallelism: 1,
  });

  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await client.query('SELECT id FROM users WHERE identifier = $1', [identifier]);
    if (!result.rows[0]) throw new Error('Pengguna tidak ditemukan.');
    const userId = result.rows[0].id;

    await client.query(
      'UPDATE users SET password_hash = $1, must_change_password = true, updated_at = now() WHERE id = $2',
      [passwordHash, userId],
    );
    await client.query('UPDATE sessions SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL', [userId]);
    await client.query('UPDATE biometric_credentials SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL', [userId]);
    await client.query("UPDATE password_reset_requests SET status = 'done', handled_at = now() WHERE user_id = $1 AND status = 'pending'", [userId]);
    await client.query("INSERT INTO password_histories (user_id, change_type) VALUES ($1, 'admin_reset')", [userId]);
    await client.query(
      "INSERT INTO audit_logs (user_id, action, metadata) VALUES ($1, 'auth.password.reset', '{}'::jsonb)",
      [userId],
    );
    await client.query('COMMIT');

    console.log(`Password sementara untuk ${identifier}: ${temporaryPassword}`);
    console.log('Password ini hanya ditampilkan sekali.');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
