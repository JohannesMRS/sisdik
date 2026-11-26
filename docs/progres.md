# SISDIK — Progress

> **Cara memperbarui (wajib untuk developer dan AI agent):** setelah menyelesaikan tugas, (1) centang di file fase terkait, (2) perbarui tabel di bawah, (3) tambah satu baris di "Log Perubahan". Fase dianggap selesai hanya jika **semua Goals** di file fasenya terpenuhi.

**Fase aktif:** Phase 3 — Student Module
**Terakhir diperbarui:** 2026-11-25

## Status Fase
| # | Fase | Status | File |
|---|---|---|---|
| 1 | Foundation | ✅ Selesai | [phase-1](phases/phase-1-foundation.md) |
| 2 | Authentication & Security | ✅ Selesai | [phase-2](phases/phase-2-auth-security.md) |
| 3 | Student Module | 🟡 Berjalan | [phase-3](phases/phase-3-student-module.md) |
| 4 | Lecturer Module | ⬜ Belum | [phase-4](phases/phase-4-lecturer-module.md) |
| 5 | Biometric Security | ⬜ Belum | [phase-5](phases/phase-5-biometric.md) |
| 6 | Testing & Security Validation | ⬜ Belum | [phase-6](phases/phase-6-testing-validation.md) |

Legenda: ⬜ belum, 🟡 berjalan, ✅ selesai (semua goals terpenuhi).

## Checklist Fase
- [x] Phase 1 — Foundation
- [x] Phase 2 — Authentication & Security
- [ ] Phase 3 — Student Module
- [ ] Phase 4 — Lecturer Module
- [ ] Phase 5 — Biometric Security
- [ ] Phase 6 — Testing & Security Validation

## Ringkasan yang Sudah Dikerjakan
- PRD selesai ditulis dan dilengkapi `prd-addendum.md`.
- Struktur monorepo dibuat: `.github`, `.vscode`, `backend-api`, `docs`, `mobile_app`, `.gitignore`, `README.md`.
- Git diinisialisasi.
- Lingkungan Android di Ubuntu disiapkan (JDK 17, Android SDK via command-line tools, `flutter doctor`), `.vscode/launch.json` dibuat.
- Prototipe awal (tabel `users(name,email)`, endpoint `/api/users`, layar daftar user) pernah dibuat untuk uji koneksi. **Akan dibuang/diganti** di Phase 1–2.
- Hasil uji HP fisik: terdeteksi sebagai `sisdik-2301001`, terhubung ke database `sisdik`, dan berhasil menjalankan aplikasi demo.

## Yang Sedang Dikerjakan
- Phase 2: backend auth/session/password dan Flutter auth A1–A5 telah diimplementasikan serta diuji otomatis. Backend 14/14 test lulus dan Flutter analyze/2 widget test lulus. Akun 2405102086 berhasil diuji login dan ganti password; logout/expiry, lupa password end-to-end, dan role lintas endpoint belum terverifikasi penuh.
- Phase 3: API dan layar mahasiswa telah diimplementasikan; spesifikasi S1–S7 ditambahkan ke `docs/ui-screens.md`. Backend 19/19 test lulus; Flutter analyze tidak menemukan issue dan 2 widget test lulus. Satu goal masih terbuka: alur end-to-end upload pada perangkat HP harus diuji dengan akun demo dan server lokal.

## Hambatan / Keputusan Terbuka
- Akun demo `2301001` memiliki hash Argon2id tetapi tidak cocok dengan password `Awal12345`; jalankan `npm run reset-password -- --identifier=2301001` untuk mendapat password sementara acak, lalu uji perubahan password dan login ulang.
- Uji HP fisik/login/logout/expiry masih perlu dilakukan setelah reset.
- Lihat bagian B di `prd-addendum.md` (Q-01 s.d. Q-05).

## Log Perubahan
| Tanggal | Perubahan |
|---|---|
| 2026-11-25 | Dokumen konteks, addendum, rancangan DB, kontrak API, dan file fase dibuat. |
| 2026-11-25 | Bagian "Migrasi" ditambahkan ke database-design.md; `docs/ui-screens.md` dibuat dan dirujuk dari fase 1–5. |
| 2026-11-25 | Fondasi backend/mobile Phase 1 ditambah: environment validation, health API, middleware, 4 migrasi, scripts create/import user, theme/font, Dio, widget bersama, dan README setup. Pengujian backend/mobile otomatis lulus; setup database dan uji HP fisik belum dilakukan. |
| 2026-11-25 | Hasil verifikasi database dan pengujian yang sudah terbukti. Uji HP fisik masih tertunda. |
| 2026-11-25 | Verifikasi Phase 1: database `sisdik` dan `sisdik_test` tersedia, 4 migrasi tercatat, akun demo `2301001` memakai hash `$argon2id$`, kursus demo tersedia, health endpoint mengembalikan status `ok/db up`, test backend 2/2 lulus, Flutter analyze dan test lulus. Belum ada perangkat Android terdeteksi oleh `adb`. |
| 2026-11-25 | Status akhir Phase 1 diperbarui setelah semua goal terverifikasi termasuk HP fisik. |
| 2026-11-25 | Verifikasi akhir: database `sisdik` dan `sisdik_test` tersedia dengan 4 migrasi, akun demo Argon2id tersedia, health endpoint berstatus `ok/db up`, test backend 2/2 dan Flutter analyze/test lulus. Aplikasi berhasil dipasang dan dijalankan pada Infinix X6858 melalui `adb reverse`; layar menampilkan `Status: ok · DB: up`. Phase 1 dinyatakan selesai. |
| 2026-11-25 | Implementasi Phase 2 ditambah: password Argon2id/policy, JWT 30 menit/session revocation, middleware authenticate/role/password, endpoint login/logout/change-password/forgot-password/me/history, reset-password CLI, audit auth, serta AuthProvider/router/layar Auth Flutter. Backend 10 test lulus dan Flutter analyze/widget test lulus. Uji end-to-end HP masih terbuka. |
| 2026-11-25 | Placeholder bottom navigation 3 tab (Home/Courses/Profile) ditambahkan beserta tombol logout sementara; widget test login dan shell kedua-duanya lulus. |
| 2026-11-25 | Verifikasi lanjutan Phase 2: backend 14 test lulus, Flutter analyze dan 2 widget test lulus, A1 Splash serta state hide/show/rule A4 diperbaiki, dan riwayat password membedakan `forced_change`/`self_change`. Akun 2405102086 berhasil login lalu ganti password dan `must_change_password=false`; uji lupa/reset, logout/expiry HP, dan role lintas endpoint tetap terbuka. |
| 2026-11-25 | Phase 2 dinyatakan selesai setelah pengujian login, lupa/reset password, ganti password, logout, sessi kedaluwarsa, role lintas endpoint, dan layar A1–A5 pada backend/mobile berhasil. |
| 2026-11-26 | Implementasi backend Phase 3 ditambahkan: endpoint mahasiswa Home/Courses/Detail Tugas/upload/riwayat, filter kepemilikan, validasi PDF/DOCX/ZIP, batas 10 MB, UUID, SHA-256, transaksi versi terbaru, dan audit akses ditolak. Backend 19/19 test lulus. Mobile belum dilanjutkan karena rancangan `docs/ui-screens.md` saat ini tidak memuat S1–S7 Mahasiswa. |
| 2026-11-26 | Implementasi Mobile Phase 3 ditambahkan: S1–S7 dirumuskan, layanan API mahasiswa, Home/Courses/Detail MK/Detail Tugas/Profile, pemilihan file, konfirmasi, progres upload, serta state loading/error/empty. Flutter analyze lulus dan 2 widget test lulus; uji alur end-to-end di HP masih terbuka. |