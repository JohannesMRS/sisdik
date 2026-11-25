# Phase 1 — Foundation

**Tujuan:** fondasi teknis yang rapi sehingga fase berikutnya hanya menambah fitur: backend berjalan, database ter-migrasi, Flutter terhubung ke backend di HP fisik.
**Prasyarat:** PRD + addendum selesai, Flutter/Node/PostgreSQL terpasang.

## Tugas
### Repo dan dokumentasi
- [x] Salin PRD ke `docs/requirements.md`.
- [x] Rapikan `.gitignore` (node_modules, `.env`, `build/`, `.dart_tool/`, `backend-api/uploads/*` kecuali `.gitkeep`, backup).
- [x] `README.md`: cara setup dari nol (backend, DB, mobile, adb reverse).
- [x] Buat `docs/security-design.md` dilengkapi seiring fase berjalan.

### Backend (`backend-api/`)
- [x] Inisialisasi proyek dan dependensi: `express pg dotenv cors helmet argon2 jsonwebtoken zod multer morgan node-pg-migrate`, dev: `nodemon jest supertest`.
- [x] Struktur folder `src/{config,middlewares,modules,utils}`, `app.js` terpisah dari `server.js`.
- [x] `config/env.js`: validasi `.env` dengan zod (gagal start bila `JWT_SECRET` < 32 karakter). Sediakan `.env.example`.
- [x] Buat database `sisdik` dan `sisdik_test` di PostgreSQL (perintah di bagian "Migrasi", `docs/database-design.md`).
- [x] Tambahkan `DATABASE_URL` ke `.env` dan `.env.example` (nilai contoh tanpa password asli); wajib ada di validasi `config/env.js`.
- [x] `config/db.js`: pool `pg` memakai `DATABASE_URL`, dengan timeout; helper `query()`.
- [x] Middleware dasar: `helmet`, batas body JSON, error handler global (format error sesuai konteks), 404 handler, logger tanpa data sensitif.
- [x] Endpoint `GET /api/v1/health` (cek koneksi DB).
- [x] Pasang `node-pg-migrate`, tambahkan script `migrate`, `migrate:up`, `migrate:down`, `migrate:create` ke `package.json`, dan buat folder `db/migrations` dan `db/seeds`.
- [x] Buat 4 file migrasi SQL sesuai pembagian di bagian "Migrasi" pada `docs/database-design.md`, masing-masing dengan bagian Down yang berfungsi. Hapus tabel prototipe.
- [x] Seed demo `db/seeds/demo.sql` (setelah user dibuat lewat script).
- [x] Script `create-user` dan `import-users` (Argon2id, `must_change_password=true`).

### Mobile (`mobile_app/`)
- [x] Tambah paket: `provider go_router dio flutter_secure_storage local_auth file_picker shimmer intl`.
- [x] Struktur `lib/{core,config,data,models,services,providers,routes,features}` sesuai PRD.
- [x] Bundle font Manrope dan IBM Plex Sans di `assets/fonts`, daftarkan di `pubspec.yaml`.
- [x] `core/theme`: ThemeData Light memakai token di `docs/ui-screens.md` bagian 0.1–0.2, tanpa Dark Mode.
- [x] `config/app_config.dart`: `API_URL` dari `String.fromEnvironment`.
- [x] `core/api_client.dart`: instance Dio (timeout, base URL, error mapper ke pesan Indonesia).
- [x] Widget bersama di `lib/core/widgets/` sesuai `docs/ui-screens.md` bagian 0.3: `AppCard`, `PrimaryButton`, `SecondaryButton`, `AppTextField`, `StatusText`, `SkeletonBox/SkeletonCard`, `EmptyState`, `ErrorState` (dengan tombol coba lagi), `ConfirmDialog`, `AppBottomSheet`.
- [x] Layar sementara yang memanggil `/health` dan menampilkan hasil (dibuang di Phase 2).

## Goals (Phase 1 dinyatakan berhasil jika)
- [x] `npm run dev` menjalankan server tanpa error, dan server **menolak start** jika `.env` tidak valid.
- [x] `GET /api/v1/health` mengembalikan `{ "data": { "status": "ok", "db": "up" } }`; saat PostgreSQL dimatikan, mengembalikan 503 tanpa membocorkan detail error.
- [x] `npm run migrate:up` dari database kosong membuat semua tabel; `migrate:down` sampai habis lalu `up` ulang berjalan bersih tanpa error.
- [x] `migrate:up` juga berhasil pada database `sisdik_test` (dengan `DATABASE_URL` yang ditimpa), dan tabel `pgmigrations` mencatat 4 migrasi.
- [x] `npm run create-user` membuat akun, dan kolom `password_hash` di database berawalan `$argon2id$`.
- [x] Aplikasi Flutter berjalan di HP Android fisik (F5 dengan launch.json) memakai tema, font, dan warna sesuai design system, serta menampilkan hasil `/health` dari backend lokal.
- [x] `README.md` bisa diikuti orang lain untuk menjalankan semuanya dari nol.
- [x] Tidak ada rahasia (`.env`) yang ter-commit.

## Di luar scope
Login, JWT, fitur akademik apa pun.