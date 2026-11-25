# Phase 1 — Foundation

**Tujuan:** fondasi teknis yang rapi sehingga fase berikutnya hanya menambah fitur: backend berjalan, database ter-migrasi, Flutter terhubung ke backend di HP fisik.
**Prasyarat:** PRD + addendum selesai, Flutter/Node/PostgreSQL terpasang.

## Tugas
### Repo dan dokumentasi
- [ ] Salin PRD ke `docs/requirements.md`.
- [ ] Rapikan `.gitignore` (node_modules, `.env`, `build/`, `.dart_tool/`, `backend-api/uploads/*` kecuali `.gitkeep`, backup).
- [ ] `README.md`: cara setup dari nol (backend, DB, mobile, adb reverse).
- [ ] Buat `docs/security-design.md` dilengkapi seiring fase berjalan.

### Backend (`backend-api/`)
- [ ] Inisialisasi proyek dan dependensi: `express pg dotenv cors helmet argon2 jsonwebtoken zod multer morgan node-pg-migrate`, dev: `nodemon jest supertest`.
- [ ] Struktur folder `src/{config,middlewares,modules,utils}`, `app.js` terpisah dari `server.js`.
- [ ] `config/env.js`: validasi `.env` dengan zod (gagal start bila `JWT_SECRET` < 32 karakter). Sediakan `.env.example`.
- [ ] Buat database `sisdik` dan `sisdik_test` di PostgreSQL (perintah di bagian "Migrasi", `docs/database-design.md`).
- [ ] Tambahkan `DATABASE_URL` ke `.env` dan `.env.example` (nilai contoh tanpa password asli); wajib ada di validasi `config/env.js`.
- [ ] `config/db.js`: pool `pg` memakai `DATABASE_URL`, dengan timeout; helper `query()`.
- [ ] Middleware dasar: `helmet`, batas body JSON, error handler global (format error sesuai konteks), 404 handler, logger tanpa data sensitif.
- [ ] Endpoint `GET /api/v1/health` (cek koneksi DB).
- [ ] Pasang `node-pg-migrate`, tambahkan script `migrate`, `migrate:up`, `migrate:down`, `migrate:create` ke `package.json`, dan buat folder `db/migrations` dan `db/seeds`.
- [ ] Buat 4 file migrasi SQL sesuai pembagian di bagian "Migrasi" pada `docs/database-design.md`, masing-masing dengan bagian Down yang berfungsi. Hapus tabel prototipe.
- [ ] Seed demo `db/seeds/demo.sql` (setelah user dibuat lewat script).
- [ ] Script `create-user` dan `import-users` (Argon2id, `must_change_password=true`).

### Mobile (`mobile_app/`)
- [ ] Tambah paket: `provider go_router dio flutter_secure_storage local_auth file_picker shimmer intl`.
- [ ] Struktur `lib/{core,config,data,models,services,providers,routes,features}` sesuai PRD.
- [ ] Bundle font Manrope dan IBM Plex Sans di `assets/fonts`, daftarkan di `pubspec.yaml`.
- [ ] `core/theme`: ThemeData Light memakai token di `docs/ui-screens.md` bagian 0.1–0.2, tanpa Dark Mode.
- [ ] `config/app_config.dart`: `API_URL` dari `String.fromEnvironment`.
- [ ] `core/api_client.dart`: instance Dio (timeout, base URL, error mapper ke pesan Indonesia).
- [ ] Widget bersama di `lib/core/widgets/` sesuai `docs/ui-screens.md` bagian 0.3: `AppCard`, `PrimaryButton`, `SecondaryButton`, `AppTextField`, `StatusText`, `SkeletonBox/SkeletonCard`, `EmptyState`, `ErrorState` (dengan tombol coba lagi), `ConfirmDialog`, `AppBottomSheet`.
- [ ] Layar sementara yang memanggil `/health` dan menampilkan hasil (dibuang di Phase 2).

## Goals (Phase 1 dinyatakan berhasil jika)
- [ ] `npm run dev` menjalankan server tanpa error, dan server **menolak start** jika `.env` tidak valid.
- [ ] `GET /api/v1/health` mengembalikan `{ "data": { "status": "ok", "db": "up" } }`; saat PostgreSQL dimatikan, mengembalikan 503 tanpa membocorkan detail error.
- [ ] `npm run migrate:up` dari database kosong membuat semua tabel; `migrate:down` sampai habis lalu `up` ulang berjalan bersih tanpa error.
- [ ] `migrate:up` juga berhasil pada database `sisdik_test` (dengan `DATABASE_URL` yang ditimpa), dan tabel `pgmigrations` mencatat 4 migrasi.
- [ ] `npm run create-user` membuat akun, dan kolom `password_hash` di database berawalan `$argon2id$`.
- [ ] Aplikasi Flutter berjalan di HP Android fisik (F5 dengan launch.json) memakai tema, font, dan warna sesuai design system, serta menampilkan hasil `/health` dari backend lokal.
- [ ] `README.md` bisa diikuti orang lain untuk menjalankan semuanya dari nol.
- [ ] Tidak ada rahasia (`.env`) yang ter-commit.

## Di luar scope
Login, JWT, fitur akademik apa pun.