# SISDIK — Dokumentasi API (Rencana Kontrak)

Base path: `/api/v1`. Format respons dan error: lihat `docs/context.md` bagian 6.
Kolom **Auth**: `-` publik, `JWT` butuh token, `S` mahasiswa, `L` dosen. Semua endpoint privat diblokir bila `must_change_password=true` (kecuali ditandai ★).

**Status:** perbarui kolom Status saat endpoint selesai (⬜ belum, ✅ selesai).

## Umum
| Method | Path | Auth | Fungsi | Status |
|---|---|---|---|---|
| GET | /health | - | Cek server dan koneksi DB | ⬜ |

## Auth dan Profil (Phase 2)
| Method | Path | Auth | Fungsi | Status |
|---|---|---|---|---|
| POST | /auth/login | - | Body `{identifier, password}` → `{token, expiresAt, user}` | ⬜ |
| POST | /auth/logout ★ | JWT | Cabut sesi saat ini → `{data: null}` | ⬜ |
| POST | /auth/change-password ★ | JWT | `{currentPassword, newPassword, confirmPassword}`, cabut semua sesi → `{data: null}` | ⬜ |
| POST | /auth/forgot-password | - | `{identifier}`, selalu balasan generik → `{data: {}}` | ⬜ |
| GET | /me ★ | JWT | Profil sendiri + `mustChangePassword` dan `biometricEnabled` untuk perangkat dari query `deviceId` | ⬜ |
| GET | /me/password-histories | JWT | Riwayat (tanggal, jenis) | ⬜ |

### Kontrak Auth
- `expiresAt` berupa string ISO 8601 UTC, misalnya `2026-11-25T16:59:00Z`.
- `user` pada login dan `/me` menggunakan `role: "student" | "lecturer"` dan `identifier` sebagai NIM/NIP.
- Login pada mahasiswa mengembalikan profil: `{id, identifier, role, name, nim, mustChangePassword}`. Login pada dosen mengembalikan: `{id, identifier, role, name, nip, mustChangePassword}`. IPK tidak ada pada respons login; IPK mahasiswa tersedia pada `/me`.
- `/me` mengembalikan profil berdasarkan role:
  - mahasiswa: `{id, identifier, role, name, nim, gpa, mustChangePassword, biometricEnabled}`;
  - dosen: `{id, identifier, role, name, nip, mustChangePassword, biometricEnabled}`.
- `gpa` pada mahasiswa memakai angka desimal dan ditampilkan UI dua angka di belakang koma. `biometricEnabled` bernilai boolean dan hanya dihitung untuk `deviceId` yang dikirim sebagai query, misalnya `GET /me?deviceId=<uuid>`.
- Semua sukses tetap menggunakan format `{ "data": ... }` pada `context.md`.
- `POST /auth/login` mengembalikan `INVALID_CREDENTIALS` untuk identifier atau password salah. Akun tidak aktif juga menggunakan `INVALID_CREDENTIALS` agar respons tidak membocorkan status akun.
- `POST /auth/change-password` menerima perubahan ketika `mustChangePassword=true` dan mencabut semua sesi. Password baru harus memenuhi kebijakan dari `prd-addendum.md`: min 8 karakter, mengandung huruf dan angka, tidak sama dengan password lama atau identifier, maks 72 karakter.
- `VALIDATION_ERROR` mengirim detail validasi per field. Field yang digunakan: `currentPassword`, `newPassword`, dan `confirmPassword`.
- `POST /auth/forgot-password` selalu sukses dengan respons generik untuk akun terdaftar maupun tidak terdaftar; UI tidak boleh menampilkan data dari respons backend.

## Mahasiswa (Phase 3)
| Method | Path | Auth | Fungsi | Status |
|---|---|---|---|---|
| GET | /student/home/assignments | S | Tugas terbaru sesuai D-12 | ⬜ |
| GET | /student/courses | S | Daftar MK, dikelompokkan per semester | ⬜ |
| GET | /student/courses/:courseId | S | Detail MK + jadwal + daftar tugas | ⬜ |
| GET | /student/assignments/:assignmentId | S | Detail tugas + status | ⬜ |
| POST | /student/assignments/:assignmentId/submissions | S | Upload (`multipart/form-data`, field `file`) | ⬜ |
| GET | /student/assignments/:assignmentId/submissions | S | Riwayat pengumpulan sendiri | ⬜ |

## Dosen (Phase 4)
| Method | Path | Auth | Fungsi | Status |
|---|---|---|---|---|
| GET | /lecturer/home/assignments | L | Tugas buatannya + jumlah pengumpulan | ⬜ |
| GET | /lecturer/courses | L | MK yang diampu + jadwal | ⬜ |
| GET | /lecturer/courses/:courseId/assignments | L | Tugas pada MK | ⬜ |
| POST | /lecturer/courses/:courseId/assignments | L | Buat tugas `{title, description, deadline}` | ⬜ |
| PUT | /lecturer/assignments/:assignmentId | L | Ubah tugas | ⬜ |
| DELETE | /lecturer/assignments/:assignmentId | L | Hapus (ditolak bila sudah ada pengumpulan) | ⬜ |
| GET | /lecturer/assignments/:assignmentId/submissions | L | Daftar pengumpulan (nama, NIM, waktu, status) | ⬜ |
| GET | /lecturer/submissions/:submissionId/file | L | Unduh file (cek MK diampu) | ⬜ |

## Biometric (Phase 5)
| Method | Path | Auth | Fungsi | Status |
|---|---|---|---|---|
| POST | /auth/biometric/enable | JWT | `{deviceId}` → `{token}` (sekali tampil) | ⬜ |
| DELETE | /auth/biometric | JWT | `{deviceId}`, nonaktifkan | ⬜ |
| POST | /auth/biometric/login | - | `{identifier, deviceId, token}` → seperti login | ⬜ |