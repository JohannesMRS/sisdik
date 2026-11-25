# Phase 5 — Biometric Security

**Tujuan:** pengguna dapat login dengan Face Recognition bawaan perangkat sebagai alternatif password.
**Prasyarat:** Phase 2 ✅ (Phase 3–4 sebaiknya selesai). Rujukan: addendum D-07 dan D-08.

## Tugas
### Backend
- [ ] Migrasi/verifikasi tabel `biometric_credentials`.
- [ ] `POST /auth/biometric/enable`: token acak 32 byte (`crypto.randomBytes`), simpan hash SHA-256, kedaluwarsa 30 hari, tolak duplikat aktif per (user, device) dengan mencabut yang lama.
- [ ] `DELETE /auth/biometric`: cabut kredensial perangkat.
- [ ] `POST /auth/biometric/login`: verifikasi hash dengan perbandingan waktu konstan, cek kedaluwarsa/dicabut/akun aktif, buat sesi dan JWT baru; pesan error generik.
- [ ] Ganti/reset password mencabut semua kredensial biometric user.
- [ ] Audit: `BIOMETRIC_ENABLED/DISABLED/LOGIN`.

### Mobile
- [ ] Tinjau bagian Biometric (B1–B2) di `docs/ui-screens.md` **sebelum** menulis kode.
- [ ] Konfigurasi platform: `USE_BIOMETRIC` di `AndroidManifest`, `MainActivity` memakai `FlutterFragmentActivity`.
- [ ] `BiometricService`: cek `isDeviceSupported`, `getAvailableBiometrics` (hanya `face` yang dianggap didukung), autentikasi via `local_auth`.
- [ ] Profile: toggle aktifkan/nonaktifkan; tampil hanya bila Face didukung, lengkap dengan penjelasan bila tidak didukung.
- [ ] Penyimpanan token biometric di secure storage dengan kunci `bio_token:<identifier>`; `deviceId` acak (UUID) dibuat sekali dan disimpan.
- [ ] Layar login: tombol "Masuk dengan wajah" muncul bila ada token tersimpan untuk akun terakhir yang login; prompt biometric dulu, baru panggil API.
- [ ] Fallback ke password jika gagal/dibatalkan/tidak didukung.
- [ ] Logout tidak menghapus token biometric; nonaktifkan menghapusnya (di server dan secure storage).

## Goals
- [ ] Di HP demo, `getAvailableBiometrics` terdeteksi memuat `face` (catat hasil uji dan tipe HP di `docs/security-design.md`). Jika tidak, buat keputusan bersama (lihat Q-02).
- [ ] Aktifkan biometric → logout → login dengan wajah berhasil dan menghasilkan sesi baru.
- [ ] Wajah gagal/dibatalkan → tetap bisa login dengan password.
- [ ] Setelah dinonaktifkan, login biometric ditolak walau token lama dikirim langsung ke API.
- [ ] Setelah ganti password, token biometric lama ditolak.
- [ ] Dua akun di satu HP memiliki pengaturan biometric masing-masing.
- [ ] HP tanpa Face Recognition tidak menampilkan opsi biometric dan login password tetap normal.
- [ ] UI biometric sesuai `docs/ui-screens.md` (B1–B2), termasuk pesan saat tidak didukung atau token tidak berlaku.
- [ ] Database hanya menyimpan hash token, tidak ada data biometrik apa pun di server maupun di aplikasi.

## Di luar scope
Face recognition berbasis foto/kamera, fingerprint, liveness detection.