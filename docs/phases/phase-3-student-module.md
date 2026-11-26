# Phase 3 — Student Module

**Tujuan:** mahasiswa dapat melihat mata kuliah dan tugas, mengumpulkan tugas, dan melihat profilnya.
**Prasyarat:** Phase 2 ✅, seed demo tersedia. Rujukan: addendum D-09 s.d. D-12, D-14, D-16.

## Tugas
### Backend
- [x] `modules/courses`, `modules/assignments`, `modules/students` sesuai tabel API "Mahasiswa".
- [x] Semua query memfilter berdasarkan `req.user.id` (join `student_courses`); resource milik orang lain → 404 + audit `ACCESS_DENIED`.
- [x] `GET /student/home/assignments` sesuai D-12, dengan status terhitung di server.
- [x] Daftar dan detail MK (dengan jadwal; daftar per semester).
- [x] Upload tugas: `multer` memory/disk storage, validasi ekstensi + MIME + magic bytes, batas 10 MB, nama UUID, hitung SHA-256, simpan di `uploads/`, tolak setelah deadline, tandai versi lama `is_latest=false` dalam satu transaksi.
- [x] Riwayat pengumpulan; path file tidak dikirim ke klien.
- [x] `GET /me` untuk mahasiswa menyertakan nama, NIM, IPK. Tidak ada endpoint tulis untuk IPK/NIM.

### Mobile
- [x] Tinjau bagian Mahasiswa (S1–S7) di `docs/ui-screens.md`; perbaiki bila ada yang tidak cocok **sebelum** menulis kode.
- [x] Home (S1): kartu tugas (MK, judul, deskripsi singkat, deadline, status teks), skeleton, error, empty state "Tidak ada tugas untuk saat ini."
- [x] Courses: daftar per semester, kartu MK; layar Detail MK (kode, dosen, SKS, jadwal, daftar tugas).
- [x] Detail Tugas: deskripsi, deadline, status, riwayat pengumpulan, tombol pilih file dan kirim (validasi tipe/ukuran di klien hanya untuk kenyamanan), konfirmasi sebelum kirim, progres upload.
- [x] Profile: nama, NIM, IPK, riwayat perubahan password, ganti password, logout (dengan confirmation dialog). Bagian biometric disiapkan sebagai placeholder.

## Goals
- [x] Mahasiswa A hanya melihat MK dan tugas miliknya; mengganti ID di URL ke resource mahasiswa B atau MK yang tidak diambil → 404.
- [ ] Upload `pdf/docx/zip` ≤ 10 MB berhasil; `.exe`, file > 10 MB, atau file berekstensi `.pdf` tetapi isinya bukan PDF → ditolak dengan kode error yang tepat.
- [ ] Kirim ulang sebelum deadline menghasilkan versi baru, versi lama tetap di riwayat; setelah deadline → `DEADLINE_PASSED`.
- [ ] File di `uploads/` bernama UUID, tidak bisa diakses lewat URL statis.
- [ ] Tidak ada cara mengubah IPK/NIM lewat API (uji dengan mengirim field `gpa` pada request apa pun).
- [x] Setiap layar punya state loading (skeleton), error (dengan coba lagi), dan empty.
- [ ] Alur lengkap di HP: login → lihat Home → buka MK → buka tugas → upload → status berubah menjadi "Sudah dikumpulkan".
- [x] UI sesuai design system dan `docs/ui-screens.md` (S1–S7): urutan komponen, teks empty/error, status berupa teks tanpa badge.

## Di luar scope
Fitur dosen, biometric, nilai.