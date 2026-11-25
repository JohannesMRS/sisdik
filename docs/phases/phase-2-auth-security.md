# Phase 2 — Authentication & Security

**Tujuan:** pengguna bisa masuk dan keluar dengan aman; semua endpoint privat terlindungi oleh JWT + sesi + role.
**Prasyarat:** Phase 1 ✅. Rujukan: addendum D-02 s.d. D-06, D-14, D-17.

## Tugas
### Backend
- [ ] `utils/password.js`: `hash()` dan `verify()` Argon2id (parameter di `context.md`); validator kebijakan password (D-03).
- [ ] `modules/auth`: `POST /auth/login` (pesan error generik `INVALID_CREDENTIALS` untuk NIM salah maupun password salah; waktu respons dijaga mirip dengan menjalankan verify palsu bila user tidak ada).
- [ ] Buat baris `sessions`, terbitkan JWT (`sub, role, jti, exp` 30 menit, HS256).
- [ ] Middleware `authenticate`: verifikasi tanda tangan (algoritma dikunci), exp, lalu cek sesi tidak dicabut/kedaluwarsa dan `users.is_active`.
- [ ] Middleware `requireRole(...roles)` dan `requirePasswordChanged` (D-02).
- [ ] `POST /auth/logout` (cabut sesi).
- [ ] `POST /auth/change-password` (cek password lama, kebijakan, cabut semua sesi, isi `password_histories`, set `must_change_password=false`).
- [ ] `POST /auth/forgot-password` (D-04) dan script `reset-password`.
- [ ] `GET /me` dan `GET /me/password-histories`.
- [ ] Audit log helper + pencatatan event auth (D-17).
- [ ] Rate limit login opsional lewat flag (D-05).
- [ ] Hapus layar dan endpoint prototipe.

### Mobile
- [ ] Tinjau bagian Auth (A1–A5) dan navigasi (0.7) di `docs/ui-screens.md`; perbaiki bila ada yang tidak cocok **sebelum** menulis kode.
- [ ] `AuthProvider` (status: unknown/unauthenticated/mustChangePassword/authenticated), penyimpanan token di secure storage.
- [ ] Dio interceptor: tempel `Authorization`, tangani 401 (dialog "Sesi berakhir" lalu ke login) dan `PASSWORD_CHANGE_REQUIRED`.
- [ ] `go_router` dengan redirect berdasarkan status auth.
- [ ] Layar A2 Login, A3 Lupa Password, A4 Ganti Password Wajib, A5 Dialog Sesi Berakhir, sesuai `docs/ui-screens.md`.
- [ ] A1 Splash singkat yang memeriksa token tersimpan lewat `GET /me`.
- [ ] Placeholder bottom navigation 3 tab (Home/Courses/Profile) untuk dua role, dengan tombol logout sementara.

## Goals
- [ ] Login benar → dapat JWT; NIM/NIP atau password salah → pesan sama (`INVALID_CREDENTIALS`).
- [ ] Token tanpa/rusak/kedaluwarsa/algoritma `none` → 401. Token milik sesi yang sudah logout → 401 `TOKEN_REVOKED`.
- [ ] Akun dengan `must_change_password=true` hanya bisa mengakses 3 endpoint pada D-02; endpoint lain 403.
- [ ] Ganti password: password lama salah ditolak; password baru lemah ditolak; sukses mencabut semua sesi lama dan menambah riwayat (tanpa menyimpan password).
- [ ] Akun nonaktif tidak bisa login.
- [ ] Mahasiswa memanggil endpoint `/lecturer/*` (dan sebaliknya) → 403.
- [ ] Alur Lupa Password end-to-end: request → script reset → login password sementara → dipaksa ganti.
- [ ] Di database tidak ada password plaintext; log server tidak memuat password/hash/token.
- [ ] Di HP: login, ganti password pertama, logout, dan sesi habis (uji dengan expiry diperpendek sementara) berjalan benar. Token tersimpan di secure storage.
- [ ] Event auth tercatat di `audit_logs`.
- [ ] Layar A1–A5 sesuai `docs/ui-screens.md` (urutan komponen, teks, validasi, state loading/error).

## Di luar scope
Biometric, modul akademik.