# Phase 6 — Testing & Security Validation

**Tujuan:** membuktikan bahwa CIA Triad, biometric, dan kriptografi benar-benar bekerja, dan menyiapkan materi demonstrasi.
**Prasyarat:** Phase 1–5 ✅.

## Tugas
- [ ] Test otomatis backend (`jest` + `supertest`) untuk matriks di bawah (database uji terpisah `sisdik_test`).
- [ ] Skrip backup `scripts/backup.sh`, restore `scripts/restore.sh`, contoh `cron` mingguan (D-18).
- [ ] Uji restore ke `sisdik_restore_test` dan catat hasilnya.
- [ ] Lengkapi `docs/security-design.md` (pemetaan fitur ke CIA/Biometric/Cryptography, keterbatasan, hasil uji).
- [ ] Lengkapi `docs/api-documentation.md` (semua status ✅, contoh request/response).
- [ ] Skenario demo tertulis (urutan langkah + akun demo) di `README.md`.
- [ ] Pembersihan: hapus kode mati, `console.log` sisa, dan cek tidak ada rahasia di riwayat git.
- [ ] `flutter analyze` bersih dan `flutter test` minimal untuk validator dan parsing model.

## Matriks Pengujian
| Area | Skenario | Hasil yang diharapkan |
|---|---|---|
| Login | Kredensial benar / salah | Token / `INVALID_CREDENTIALS` seragam |
| JWT | Tanpa token, rusak, kedaluwarsa, `alg: none`, payload diubah | 401 |
| Revokasi | Pakai token setelah logout atau ganti password | 401 `TOKEN_REVOKED` |
| Password | Hash di DB `$argon2id$`; dua user dengan password sama punya hash berbeda | Lolos |
| Password | Kebijakan, password lama salah, force change | Sesuai D-02/D-03 |
| Role | Mahasiswa → `/lecturer/*`, dosen → `/student/*` | 403 |
| Confidentiality | Mahasiswa A akses course/assignment/submission mahasiswa B lewat ID | 404 |
| Confidentiality | Dosen A akses MK/tugas/file dosen B | 404 |
| Integrity | Kirim `gpa`, `role`, `userId`, `identifier` pada body request mana pun | Diabaikan/ditolak, data tidak berubah |
| Integrity | SQL injection pada login, parameter ID, judul tugas | Tidak berpengaruh |
| Integrity | Upload `.exe`, file palsu berekstensi pdf, > 10 MB, setelah deadline | Ditolak |
| Integrity | SHA-256 file unduhan = SHA-256 saat upload | Cocok |
| Biometric | Alur Phase 5 (aktif, login, nonaktif, ganti password) | Sesuai goals Phase 5 |
| Availability | Backup → hapus data → restore → jumlah baris cocok | Lolos |
| Availability | PostgreSQL dimatikan | 503 generik, aplikasi menampilkan error state |
| Audit | Event pada D-17 muncul di `audit_logs` tanpa data sensitif | Lolos |

## Goals
- [ ] Semua skenario matriks lulus (otomatis atau manual terdokumentasi).
- [ ] `npm test` hijau dan bisa dijalankan dari database kosong.
- [ ] Backup mingguan terjadwal, tersimpan di lokasi berbeda dari database utama, dan restore terbukti berhasil.
- [ ] `docs/security-design.md` memuat pemetaan fitur → prinsip keamanan beserta bukti uji.
- [ ] Skenario demo dijalankan penuh sekali dari awal sampai akhir di HP fisik tanpa error.
- [ ] Repo bersih: tidak ada `.env`, file upload, atau backup yang ter-commit.

## Di luar scope
Penetration test profesional, HTTPS/hosting publik, CI/CD.