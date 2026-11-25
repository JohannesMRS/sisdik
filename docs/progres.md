# SISDIK — Progress

> **Cara memperbarui (wajib untuk developer dan AI agent):** setelah menyelesaikan tugas, (1) centang di file fase terkait, (2) perbarui tabel di bawah, (3) tambah satu baris di "Log Perubahan". Fase dianggap selesai hanya jika **semua Goals** di file fasenya terpenuhi.

**Fase aktif:** Phase 1 — Foundation
**Terakhir diperbarui:** 2026-11-25

## Status Fase
| # | Fase | Status | File |
|---|---|---|---|
| 1 | Foundation | ✅ Selesai | [phase-1](phases/phase-1-foundation.md) |
| 2 | Authentication & Security | ⬜ Belum | [phase-2](phases/phase-2-auth-security.md) |
| 3 | Student Module | ⬜ Belum | [phase-3](phases/phase-3-student-module.md) |
| 4 | Lecturer Module | ⬜ Belum | [phase-4](phases/phase-4-lecturer-module.md) |
| 5 | Biometric Security | ⬜ Belum | [phase-5](phases/phase-5-biometric.md) |
| 6 | Testing & Security Validation | ⬜ Belum | [phase-6](phases/phase-6-testing-validation.md) |

Legenda: ⬜ belum, 🟡 berjalan, ✅ selesai (semua goals terpenuhi).

## Checklist Fase
- [x] Phase 1 — Foundation
- [ ] Phase 2 — Authentication & Security
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
- Belum ada fase aktif. Phase 1 selesai; pengerjaan berikutnya belum dimulai.

## Hambatan / Keputusan Terbuka
Lihat bagian B di `prd-addendum.md` (Q-01 s.d. Q-05).

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