# Phase 4 — Lecturer Module

**Tujuan:** dosen dapat melihat MK yang diampu, mengelola tugas, dan melihat pengumpulan mahasiswa.
**Prasyarat:** Phase 3 ✅. Rujukan: addendum D-10, D-12, D-14.

## Tugas
### Backend
- [ ] Endpoint dosen sesuai tabel API "Dosen"; semua query memfilter lewat `lecturer_courses` berdasarkan `req.user.id`.
- [ ] Buat/ubah/hapus tugas dengan validasi (judul wajib, deadline valid dan di masa depan saat pembuatan); hapus ditolak bila sudah ada pengumpulan (`409`).
- [ ] Daftar pengumpulan per tugas: nama, NIM, waktu kirim, status (hanya mahasiswa yang mengambil MK tersebut).
- [ ] Unduh file pengumpulan lewat endpoint terautentikasi (cek MK diampu), `Content-Disposition` memakai nama asli, catat audit `SUBMISSION_DOWNLOADED`.
- [ ] Audit log untuk create/update/delete tugas.

### Mobile
- [ ] Tinjau bagian Dosen (L1–L5) di `docs/ui-screens.md`; perbaiki bila ada yang tidak cocok **sebelum** menulis kode.
- [ ] Home dosen (L1): tugas buatannya + jumlah pengumpulan; empty state.
- [ ] Courses dosen: nama, kode, SKS, jadwal; detail MK dengan daftar tugas.
- [ ] Form buat/ubah tugas (judul, deskripsi, deadline dengan date-time picker), konfirmasi sebelum hapus.
- [ ] Layar daftar pengumpulan dan unduh/buka file.
- [ ] Profile dosen: nama, NIP, riwayat password, ganti password, logout.

## Goals
- [ ] Dosen hanya melihat/mengelola MK yang diampu; MK atau tugas dosen lain → 404.
- [ ] Mahasiswa tidak dapat memanggil endpoint dosen (403) dan dosen tidak dapat memanggil endpoint mahasiswa.
- [ ] Tugas yang dibuat dosen langsung muncul di Home mahasiswa pada MK terkait, dan tidak muncul untuk mahasiswa yang tidak mengambil MK itu.
- [ ] Dosen dapat mengunduh file mahasiswa yang benar; isi file identik dengan yang diunggah (SHA-256 cocok).
- [ ] Hapus tugas yang sudah punya pengumpulan ditolak.
- [ ] Alur lengkap di HP: dosen login → buat tugas → mahasiswa upload → dosen melihat dan membuka file.
- [ ] Empty/skeleton/error state ada di semua layar dosen.
- [ ] Layar L1–L5 sesuai `docs/ui-screens.md`.

## Di luar scope
Penilaian tugas, komentar/feedback ke mahasiswa.