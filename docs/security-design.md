# SISDIK — Desain Keamanan

> Dokumen hidup: diisi bertahap, dilengkapi di Phase 6.

## 1. Pemetaan Fitur ke Prinsip
| Prinsip | Mekanisme | Fase | Bukti Uji |
|---|---|---|---|
| Confidentiality | JWT + sesi, RBAC, filter kepemilikan di query, respons 404 | 2–4 | (isi di Phase 6) |
| Integrity | Validasi zod, parameterized query, validasi upload, SHA-256 file, FK/constraint, audit log | 1–4 | |
| Availability | Backup mingguan `pg_dump`, uji restore, error handling DB | 6 | |
| Cryptography | Argon2id (password), SHA-256 (token biometric & integritas file), HS256 (JWT) | 2–5 | |
| Biometric | Native Face Recognition via `local_auth` + token perangkat | 5 | |

## 2. Contoh Jadwal Backup (cron)
```
# Setiap Minggu 02:00
0 2 * * 0 /home/USER/sisdik/backend-api/scripts/backup.sh >> /home/USER/sisdik-backups/backup.log 2>&1
```

## 3. Keterbatasan yang Diketahui (jujur untuk demo)
- Demo berjalan lokal tanpa HTTPS; di produksi wajib TLS.
- Backup mingguan berarti potensi kehilangan data hingga 7 hari; sistem nyata perlu lebih sering.
- Tidak ada refresh token; sesi 30 menit lalu login ulang.
- Rate limit login mati secara default sesuai PRD (dapat diaktifkan lewat flag).
- Secure storage melindungi token di perangkat, namun perangkat yang di-root tetap risiko.

## 4. Hasil Uji Perangkat Biometric
(Isi di Phase 5: tipe HP, versi Android, hasil `getAvailableBiometrics`.)