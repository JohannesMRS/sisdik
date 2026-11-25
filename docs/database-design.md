# SISDIK — Rancangan Database (Draft Awal)

PostgreSQL. Draf ini menjadi dasar file migrasi di `backend-api/db/migrations/`. Prototipe tabel `users(name,email)` dari tahap setup awal **dibuang** dan diganti skema ini.

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid()

CREATE TYPE user_role AS ENUM ('student', 'lecturer');

CREATE TABLE users (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  identifier            VARCHAR(30) NOT NULL UNIQUE,         -- NIM / NIP
  role                  user_role NOT NULL,
  password_hash         TEXT NOT NULL,                       -- Argon2id
  must_change_password  BOOLEAN NOT NULL DEFAULT TRUE,
  is_active             BOOLEAN NOT NULL DEFAULT TRUE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE students (
  user_id        UUID PRIMARY KEY REFERENCES users(id),
  full_name      VARCHAR(150) NOT NULL,
  study_program  VARCHAR(100),
  gpa            NUMERIC(3,2) NOT NULL DEFAULT 0 CHECK (gpa >= 0 AND gpa <= 4)
);

CREATE TABLE lecturers (
  user_id    UUID PRIMARY KEY REFERENCES users(id),
  full_name  VARCHAR(150) NOT NULL
);

CREATE TABLE courses (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code      VARCHAR(20) NOT NULL UNIQUE,
  name      VARCHAR(150) NOT NULL,
  credits   SMALLINT NOT NULL CHECK (credits BETWEEN 1 AND 6),
  semester  SMALLINT NOT NULL CHECK (semester BETWEEN 1 AND 8)
);

CREATE TABLE course_schedules (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id    UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  day_of_week  SMALLINT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),  -- 1 = Senin
  start_time   TIME NOT NULL,
  end_time     TIME NOT NULL,
  room         VARCHAR(50),
  CHECK (end_time > start_time)
);

CREATE TABLE student_courses (
  student_id     UUID NOT NULL REFERENCES students(user_id),
  course_id      UUID NOT NULL REFERENCES courses(id),
  academic_term  VARCHAR(20) NOT NULL,            -- contoh: '2025/2026 Ganjil'
  PRIMARY KEY (student_id, course_id)
);

CREATE TABLE lecturer_courses (
  lecturer_id  UUID NOT NULL REFERENCES lecturers(user_id),
  course_id    UUID NOT NULL REFERENCES courses(id),
  PRIMARY KEY (lecturer_id, course_id)
);

CREATE TABLE assignments (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id    UUID NOT NULL REFERENCES courses(id),
  created_by   UUID NOT NULL REFERENCES lecturers(user_id),
  title        VARCHAR(200) NOT NULL,
  description  TEXT NOT NULL DEFAULT '',
  deadline     TIMESTAMPTZ NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_assignments_course ON assignments(course_id);

CREATE TABLE assignment_submissions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id     UUID NOT NULL REFERENCES assignments(id),
  student_id        UUID NOT NULL REFERENCES students(user_id),
  original_filename VARCHAR(255) NOT NULL,
  stored_filename   VARCHAR(100) NOT NULL UNIQUE,   -- UUID + ekstensi
  mime_type         VARCHAR(100) NOT NULL,
  size_bytes        INTEGER NOT NULL CHECK (size_bytes > 0),
  sha256            CHAR(64) NOT NULL,              -- bukti integritas file
  is_latest         BOOLEAN NOT NULL DEFAULT TRUE,
  submitted_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_submission_latest
  ON assignment_submissions(assignment_id, student_id) WHERE is_latest;

CREATE TABLE password_histories (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES users(id),
  change_type  VARCHAR(20) NOT NULL CHECK (change_type IN ('self_change','forced_change','admin_reset')),
  changed_at   TIMESTAMPTZ NOT NULL DEFAULT now()   -- TIDAK menyimpan password/hash
);

CREATE TABLE sessions (
  id          UUID PRIMARY KEY,                     -- = jti pada JWT
  user_id     UUID NOT NULL REFERENCES users(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at  TIMESTAMPTZ NOT NULL,
  revoked_at  TIMESTAMPTZ
);
CREATE INDEX idx_sessions_user ON sessions(user_id);

CREATE TABLE biometric_credentials (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id),
  device_id     VARCHAR(100) NOT NULL,
  token_hash    CHAR(64) NOT NULL,                  -- SHA-256 dari token acak 32 byte
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at    TIMESTAMPTZ NOT NULL,
  last_used_at  TIMESTAMPTZ,
  revoked_at    TIMESTAMPTZ
);
CREATE UNIQUE INDEX uq_biometric_active
  ON biometric_credentials(user_id, device_id) WHERE revoked_at IS NULL;

CREATE TABLE password_reset_requests (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id),
  status        VARCHAR(10) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','done')),
  requested_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  handled_at    TIMESTAMPTZ
);

CREATE TABLE audit_logs (
  id           BIGSERIAL PRIMARY KEY,
  user_id      UUID REFERENCES users(id),           -- boleh NULL (login gagal)
  action       VARCHAR(50) NOT NULL,
  entity_type  VARCHAR(50),
  entity_id    VARCHAR(100),
  ip_address   VARCHAR(45),
  metadata     JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_audit_user_time ON audit_logs(user_id, created_at DESC);
```

## Catatan
- `users.identifier` adalah NIM (student) atau NIP (lecturer); profil tampil dengan join ke `students`/`lecturers`.
- Kolom role-spesifik tidak dipaku di `users` agar mudah diperluas.
- Semua waktu `TIMESTAMPTZ`. Trigger `updated_at` opsional (boleh di-set dari aplikasi).
- Seed data demo: minimal 2 mahasiswa, 1 dosen, 3 mata kuliah, jadwal, relasi, 2 tugas, ditaruh di `backend-api/db/seeds/demo.sql`.

---

## Migrasi

Skema di atas hanya **rancangan**. Yang dijalankan adalah file migrasi di `backend-api/db/migrations/`. Setelah file migrasi dibuat dan dijalankan, **migrasi menjadi sumber kebenaran skema**, dan dokumen ini wajib diperbarui agar tetap sinkron.

### Persiapan
1. Buat database kosong (migrasi membuat tabel, bukan databasenya):
   ```bash
   psql -U postgres -c "CREATE DATABASE sisdik;"
   psql -U postgres -c "CREATE DATABASE sisdik_test;"
   ```
   Extension `pgcrypto` dibuat oleh migrasi pertama (`CREATE EXTENSION IF NOT EXISTS pgcrypto`).
2. Instal tool:
   ```bash
   cd backend-api
   npm install node-pg-migrate pg dotenv
   ```
3. Tambahkan `DATABASE_URL` di `backend-api/.env` dan contoh nilainya di `.env.example`:
   ```env
   DATABASE_URL=postgres://postgres:PASSWORD@localhost:5432/sisdik
   ```
   - `node-pg-migrate` membaca satu variabel `DATABASE_URL`, jadi `config/db.js` aplikasi juga memakai variabel yang sama (`new Pool({ connectionString: process.env.DATABASE_URL })`) agar tidak ada dua sumber konfigurasi.
   - Karakter khusus pada password (`@`, `#`, `/`) harus di-URL-encode.
   - Jika `DATABASE_URL` tidak terbaca dari `.env`, cek `npx node-pg-migrate --help` untuk opsi path `.env` pada versi yang terpasang.
4. Buat folder:
   ```bash
   mkdir -p db/migrations db/seeds
   ```

### Script `package.json`
```json
"scripts": {
  "migrate": "node-pg-migrate --migrations-dir db/migrations --migration-file-language sql",
  "migrate:up": "npm run migrate -- up",
  "migrate:down": "npm run migrate -- down",
  "migrate:create": "npm run migrate -- create"
}
```

### Format file migrasi
Buat file dengan `npm run migrate:create -- nama_migrasi`. Hasilnya berawalan timestamp, isinya dipisah dua penanda komentar:

```sql
-- Up Migration
CREATE TABLE contoh (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

-- Down Migration
DROP TABLE IF EXISTS contoh;
```

Bagian **Down** harus membalik Up dengan urutan terbalik (tabel yang bergantung pada tabel lain dihapus lebih dulu, tipe `ENUM` dihapus setelah tabel yang memakainya).

### Pembagian file migrasi awal
| Urutan | Nama (saran) | Isi |
|---|---|---|
| 1 | `init_users_and_profiles` | extension, enum `user_role`, `users`, `students`, `lecturers` |
| 2 | `courses_and_relations` | `courses`, `course_schedules`, `student_courses`, `lecturer_courses` |
| 3 | `assignments_and_submissions` | `assignments`, `assignment_submissions` (termasuk index parsial) |
| 4 | `security_and_audit_tables` | `sessions`, `biometric_credentials`, `password_histories`, `password_reset_requests`, `audit_logs` |

Perubahan skema di fase berikutnya = **file migrasi baru**, bukan mengedit file lama.

### Perintah dan verifikasi
```bash
npm run migrate:up                          # jalankan semua migrasi yang belum jalan
npm run migrate:down                        # turun satu migrasi (ulangi untuk menurunkan semuanya)
psql -U postgres -d sisdik -c "\dt"         # semua tabel + tabel pgmigrations
```
Tabel `pgmigrations` dibuat tool untuk mencatat migrasi yang sudah jalan. Jangan dihapus atau diedit manual.

Uji bolak-balik sebelum lanjut: `migrate:down` sampai habis, lalu `migrate:up` lagi, harus bersih tanpa error.

Database test dimigrasi dengan menimpa variabel saat menjalankan:
```bash
DATABASE_URL=postgres://postgres:PASSWORD@localhost:5432/sisdik_test npm run migrate:up
```

### Aturan main
1. **Jangan mengedit file migrasi yang sudah dijalankan.** Kalau salah atau skema perlu berubah, buat file migrasi baru. Pengecualian: selama masih Phase 1 dan belum ada data berharga, boleh `migrate:down` sampai habis, edit file, lalu `up` lagi.
2. **Jangan mengubah struktur tabel langsung lewat `psql` atau GUI.** Semua perubahan skema lewat file migrasi supaya bisa direproduksi.
3. **Seed data bukan migrasi.** Data demo (mata kuliah, jadwal, tugas) ada di `db/seeds/demo.sql` dan dijalankan terpisah. Akun user dibuat lewat script `create-user` karena butuh hash Argon2id.
4. Setiap migrasi harus punya bagian Down yang berfungsi.
5. Setelah migrasi berubah, perbarui bagian skema dan catatan di dokumen ini.