# SISDIK — File Konteks

Dokumen ini adalah ringkasan konteks proyek untuk developer dan AI agent. Sumber detail: `docs/requirements.md` (PRD) dan `docs/prd-addendum.md`.

## 1. Ringkasan
Aplikasi mobile akademik untuk **mahasiswa** dan **dosen**: lihat mata kuliah, lihat dan kumpulkan tugas, profil, login password + biometric (Face Recognition native). Pendekatan MVP, berjalan lokal untuk demonstrasi. Tidak ada aplikasi/dashboard admin: data dikelola programmer lewat database dan script CLI.

Tujuan keamanan yang harus terlihat jelas: **CIA Triad, Biometric Security, Cryptography**.

## 2. Tech Stack
| Komponen | Pilihan |
|---|---|
| Mobile | Flutter (Android sebagai target utama) |
| Backend | Express.js (Node.js LTS), REST API |
| Database | PostgreSQL, driver `pg`, tanpa ORM |
| Migrasi | `node-pg-migrate` (file SQL di `backend-api/db/migrations`) |
| Auth | JWT (HS256, 30 menit) + tabel `sessions` untuk pencabutan |
| Hash password | Argon2id (`argon2`) |
| Validasi | `zod` |
| Upload | `multer` |
| Keamanan HTTP | `helmet`, `cors` |
| Test backend | `jest` + `supertest` |
| Flutter packages | `provider`, `go_router`, `dio`, `flutter_secure_storage`, `local_auth`, `file_picker`, `shimmer`, `intl` |

## 3. Struktur Repo
```
sisdik/
├── .github/copilot-instructions.md
├── .vscode/launch.json
├── backend-api/
│   ├── db/migrations/        # SQL migrasi
│   ├── scripts/              # CLI: create-user, reset-password, backup, restore
│   ├── src/{config,middlewares,modules,utils}/ , app.js, server.js
│   ├── uploads/              # file tugas (di-gitignore, tidak di-serve statis)
│   └── tests/
├── mobile_app/               # nama folder pakai underscore (aturan nama package Dart)
│   └── lib/{core,config,data,models,services,providers,routes,features}
└── docs/
```
Fitur Flutter: `auth`, `home`, `courses`, `assignments`, `profile`, `biometric`.

## 4. Environment Pengembangan
- OS Ubuntu, editor VS Code, tanpa Android Studio (SDK via command-line tools).
- Target uji: HP Android fisik via USB. Jalankan `adb reverse tcp:3000 tcp:3000` setiap kabel dicolok ulang.
- Base URL:
  - HP fisik + `adb reverse`: `http://localhost:3000/api/v1`
  - HP fisik lewat WiFi: `http://<IP-laptop>:3000/api/v1`
  - Emulator: `http://10.0.2.2:3000/api/v1`
- Dikirim lewat `--dart-define=API_URL=...` (sudah ada di `.vscode/launch.json`).
- Zona waktu: database menyimpan `TIMESTAMPTZ` (UTC), UI menampilkan WIB.

## 5. Role dan Hak Akses (ringkas)
| | Mahasiswa | Dosen |
|---|---|---|
| Login | NIM + password | NIP + password |
| Mata kuliah | Hanya yang diambil (read-only) | Hanya yang diampu (read-only) |
| Tugas | Lihat + kumpulkan untuk MK miliknya | Buat/ubah/hapus untuk MK yang diampu, lihat pengumpulan |
| Profil | Nama, NIM, IPK (read-only) | Nama, NIP |
| Nilai | Tidak ada (penilaian manual) | Tidak ada |

## 6. Konvensi API
- Prefix: `/api/v1`. Route dipisah per role: `/auth/*`, `/me/*`, `/student/*`, `/lecturer/*`.
- Sukses: `{ "data": ... }`
- Gagal: `{ "error": { "code": "UPPER_SNAKE", "message": "pesan untuk manusia", "details": [...] } }`
- Kode status: 400 validasi, 401 tidak terautentikasi/token tidak valid, 403 role salah atau data bukan miliknya (atau 404 untuk menyembunyikan keberadaan data), 404 tidak ditemukan, 409 konflik, 413 file terlalu besar, 500 error server (pesan generik, detail hanya di log).
- Kode error penting: `INVALID_CREDENTIALS`, `TOKEN_EXPIRED`, `TOKEN_REVOKED`, `PASSWORD_CHANGE_REQUIRED`, `FORBIDDEN`, `VALIDATION_ERROR`, `DEADLINE_PASSED`, `FILE_TYPE_NOT_ALLOWED`.
- Waktu dalam format ISO 8601 UTC.
- ID memakai UUID, kecuali `audit_logs`.

## 7. Desain Keamanan (ringkas)
- Login → backend verifikasi Argon2id → buat baris `sessions` (id = `jti`) → kirim JWT berisi `sub`, `role`, `jti`, `exp` (tanpa data pribadi).
- Setiap request privat: verifikasi tanda tangan, `exp`, lalu cek `sessions.revoked_at IS NULL` dan `expires_at > now()`.
- Logout: set `revoked_at`. Ganti password: cabut semua sesi dan semua kredensial biometric user.
- Argon2id: `memoryCost 19456`, `timeCost 2`, `parallelism 1` (rekomendasi minimum OWASP).
- `JWT_SECRET` minimal 32 karakter acak, algoritma dikunci HS256 saat verifikasi.
- Biometric: lihat addendum D-07 (token perangkat terpisah, bukan JWT yang diperpanjang).
- Audit log untuk event penting (login berhasil/gagal, logout, ganti/reset password, biometric on/off, upload/hapus/ubah tugas, akses ditolak).

## 8. Design System
Rancangan tiap layar: `docs/ui-screens.md`.

- Gaya: Clean & Minimalist, **Light Mode saja**.
- Warna: Background `#F8FAFC`, Surface `#FFFFFF`, Teks utama `#0F172A`, Teks sekunder `#64748B`, Accent `#2563EB`. Proporsi 60/30/10.
- Font: **Manrope** (heading/penekanan), **IBM Plex Sans** (isi). Font di-bundle di `assets/fonts` agar tidak butuh internet.
- Komponen: Bottom Navigation (Home, Courses, Profile), Card, Input, Button, Modal Dialog, Bottom Sheet, Skeleton Loading, Empty State, Confirmation Dialog, Form Validation.
- **Tidak memakai badge.** Status memakai teks dan warna halus.
- Animasi hanya transisi sederhana.
- Empty state contoh: "Tidak ada tugas untuk saat ini."

## 9. Out of Scope
Registrasi mandiri, KRS, pembayaran UKT, chat, dashboard/akun admin di aplikasi, mode offline, hitung IPK/nilai otomatis, pemilihan mata kuliah oleh mahasiswa, Dark Mode, notifikasi push, penilaian tugas.

## 10. Perintah Umum
```bash
# Backend
cd backend-api && npm run dev
npm run migrate:up
npm run create-user -- --role=student --identifier=2301001 --name="Budi" --password=Awal12345
npm run reset-password -- --identifier=2301001
npm test

# Mobile (dari root repo, di VS Code tekan F5 dengan launch.json)
adb reverse tcp:3000 tcp:3000
cd mobile_app && flutter run --dart-define=API_URL=http://localhost:3000/api/v1
```

## 11. Prinsip
Security First, Backend as Source of Truth, Separation of Concerns, Modular, Minimalist UI, MVP First (tidak menambah fitur tanpa persetujuan), Documentation.