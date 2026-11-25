# SISDIK — Progress

> **Cara memperbarui (wajib untuk developer dan AI agent):** setelah menyelesaikan tugas, (1) centang di file fase terkait, (2) perbarui tabel di bawah, (3) tambah satu baris di "Log Perubahan". Fase dianggap selesai hanya jika **semua Goals** di file fasenya terpenuhi.

**Fase aktif:** Phase 1 — Foundation
**Terakhir diperbarui:** 2026-11-25

## Status Fase
| # | Fase | Status | File |
|---|---|---|---|
| 1 | Foundation | 🟡 Sedang dikerjakan | [phase-1](phases/phase-1-foundation.md) |
| 2 | Authentication & Security | ⬜ Belum | [phase-2](phases/phase-2-auth-security.md) |
| 3 | Student Module | ⬜ Belum | [phase-3](phases/phase-3-student-module.md) |
| 4 | Lecturer Module | ⬜ Belum | [phase-4](phases/phase-4-lecturer-module.md) |
| 5 | Biometric Security | ⬜ Belum | [phase-5](phases/phase-5-biometric.md) |
| 6 | Testing & Security Validation | ⬜ Belum | [phase-6](phases/phase-6-testing-validation.md) |

Legenda: ⬜ belum, 🟡 berjalan, ✅ selesai (semua goals terpenuhi).

## Checklist Fase
- [ ] Phase 1 — Foundation
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

## Yang Sedang Dikerjakan
- Phase 1: merapikan scaffold sesuai struktur PRD, migrasi database, script create-user.

## Hambatan / Keputusan Terbuka
Lihat bagian B di `prd-addendum.md` (Q-01 s.d. Q-05).

## Log Perubahan
| Tanggal | Perubahan |
|---|---|
| 2026-11-25 | Dokumen konteks, addendum, rancangan DB, kontrak API, dan file fase dibuat. |
| 2026-11-25 | Bagian "Migrasi" ditambahkan ke database-design.md; `docs/ui-screens.md` dibuat dan dirujuk dari fase 1–5. |