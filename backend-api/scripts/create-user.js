require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const argon2 = require('argon2');
const { Pool } = require('pg');

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i += 2) {
    const key = argv[i];
    if (!key?.startsWith('--')) throw new Error('Format argumen tidak valid.');
    args[key.slice(2)] = argv[i + 1];
  }
  return args;
}

async function main() {
  const args = parseArgs(process.argv);
  if (!['student', 'lecturer'].includes(args.role) || !args.identifier || !args.name || !args.password) {
    throw new Error('Gunakan --role student|lecturer --identifier ID --name Nama --password Password');
  }

  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const passwordHash = await argon2.hash(args.password, {
      type: argon2.argon2id,
      memoryCost: 19456,
      timeCost: 2,
      parallelism: 1,
    });
    const userResult = await client.query(
      `INSERT INTO users (identifier, role, password_hash, must_change_password)
       VALUES ($1, $2, $3, true) RETURNING id, identifier, role`,
      [args.identifier, args.role, passwordHash],
    );
    const user = userResult.rows[0];
    if (args.role === 'student') {
      await client.query(
        'INSERT INTO students (user_id, full_name) VALUES ($1, $2)',
        [user.id, args.name],
      );
    } else {
      await client.query(
        'INSERT INTO lecturers (user_id, full_name) VALUES ($1, $2)',
        [user.id, args.name],
      );
    }
    await client.query('COMMIT');
    console.log(`Akun ${args.role} dibuat: ${user.identifier}`);
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
