require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const fs = require('fs');
const argon2 = require('argon2');
const { Pool } = require('pg');

async function main() {
  const filePath = process.argv[2];
  if (!filePath) throw new Error('Gunakan: npm run import-users -- berkas.csv');
  const [headerLine, ...lines] = fs.readFileSync(filePath, 'utf8').split(/\r?\n/).filter(Boolean);
  const headers = headerLine.split(',').map((value) => value.trim());
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    for (const line of lines) {
      const values = line.split(',').map((value) => value.trim());
      const row = Object.fromEntries(headers.map((header, index) => [header, values[index]]));
      if (!['student', 'lecturer'].includes(row.role) || !row.identifier || !row.name || !row.password) {
        throw new Error(`Baris CSV tidak lengkap: ${line}`);
      }
      const passwordHash = await argon2.hash(row.password, {
        type: argon2.argon2id,
        memoryCost: 19456,
        timeCost: 2,
        parallelism: 1,
      });
      const result = await client.query(
        `INSERT INTO users (identifier, role, password_hash, must_change_password)
         VALUES ($1, $2, $3, true) RETURNING id`,
        [row.identifier, row.role, passwordHash],
      );
      if (row.role === 'student') {
        await client.query('INSERT INTO students (user_id, full_name) VALUES ($1, $2)', [result.rows[0].id, row.name]);
      } else {
        await client.query('INSERT INTO lecturers (user_id, full_name) VALUES ($1, $2)', [result.rows[0].id, row.name]);
      }
    }
    await client.query('COMMIT');
    console.log(`${lines.length} akun berhasil diimpor.`);
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
