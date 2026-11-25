# SISDIK — Rancangan Layar (UI Screens)

Dokumen ini menjelaskan **susunan setiap layar Flutter**: komponen, urutan, isi, state, dan aksi. Tujuannya agar tampilan konsisten dan Copilot tidak menebak tata letak.
Aturan gaya dasar ada di `docs/context.md` bagian 8. Kontrak data ada di `docs/api-documentation.md`.

> **Aturan:** implementasi layar mengikuti dokumen ini. Jika perlu menyimpang, tanyakan dulu, lalu perbarui dokumen ini. Setiap layar punya ID (A1, S1, L1, B1) untuk dirujuk di prompt dan commit.

---

## 0. Fondasi Visual

### 0.1 Token
| Token | Nilai |
|---|---|
| Background | `#F8FAFC` |
| Surface (kartu, sheet, dialog) | `#FFFFFF` |
| Border halus | `#E2E8F0` (Slate 200), tebal 1 |
| Teks utama | `#0F172A` |
| Teks sekunder | `#64748B` |
| Accent | `#2563EB` |
| Sukses (teks status) | `#15803D` |
| Peringatan/Error (teks status, pesan error) | `#DC2626` |
| Spasi | kelipatan 4/8: 4, 8, 12, 16, 24, 32. Padding halaman 16 |
| Radius | kartu dan tombol 12, bottom sheet atas 20 |
| Bayangan | tidak dipakai (cukup border) agar tetap datar dan minimalis |

Warna Sukses dan Error **tambahan** dari palet PRD, hanya untuk teks status dan pesan error, bukan dekorasi. Proporsi accent tetap sekitar 10%.

### 0.2 Tipografi
| Peran | Font | Ukuran / bobot |
|---|---|---|
| Judul layar | Manrope | 24 / 700 |
| Judul bagian dan kartu | Manrope | 16–18 / 600 |
| Isi dan data akademik | IBM Plex Sans | 14 / 400, baris 1.4 |
| Keterangan (caption) | IBM Plex Sans | 12 / 400, warna sekunder |
| Tombol | Manrope | 14 / 600 |

### 0.3 Komponen bersama (`lib/core/widgets/`)
| Widget | Spesifikasi |
|---|---|
| `AppCard` | Surface putih, border halus, radius 12, padding 16, bisa diketuk (ripple halus) |
| `PrimaryButton` | Tinggi 48, lebar penuh, accent, teks putih; state loading (spinner kecil) dan disabled |
| `SecondaryButton` | Tinggi 48, outline accent, teks accent |
| `AppTextField` | Label di atas, border halus, fokus berwarna accent, pesan error di bawah (warna Error) |
| `StatusText` | Ikon kecil 16 + teks, **tanpa latar/pil/badge**. Lihat 0.4 |
| `SkeletonBox` / `SkeletonCard` | `shimmer` abu muda; jumlah dan bentuk menyerupai konten asli |
| `EmptyState` | Ilustrasi sederhana (ikon besar 64, warna sekunder) + judul + keterangan |
| `ErrorState` | Ikon + pesan ramah + tombol "Coba lagi" |
| `ConfirmDialog` | Judul, isi singkat, tombol Batal dan aksi; aksi destruktif bertuliskan jelas (warna Error) |
| `AppBottomSheet` | Handle di atas, radius atas 20, judul, isi |

### 0.4 Status tugas (teks saja)
| Status | Ikon | Warna |
|---|---|---|
| Belum dikumpulkan | `schedule` | Teks sekunder |
| Sudah dikumpulkan | `check_circle_outline` | Sukses |
| Lewat deadline | `error_outline` | Error |

### 0.5 Format tampilan
- Tanggal dan jam memakai `intl` locale `id_ID`, zona WIB. Contoh: `Jum, 28 Nov 2026 · 23.59 WIB`.
- Sisa waktu sebagai teks sekunder: `2 hari lagi`, `5 jam lagi`, `Sudah lewat`.
- IPK tampil dua desimal. Jadwal: `Senin · 08.00–09.40 · Ruang A101`.

### 0.6 Pola state untuk setiap layar yang memuat data
1. **Loading:** skeleton berbentuk seperti konten (bukan spinner di tengah).
2. **Error:** `ErrorState` dengan pesan sesuai kode error, tombol "Coba lagi" memuat ulang.
3. **Empty:** `EmptyState` dengan teks khusus layar.
4. **Isi:** daftar/konten. Layar daftar mendukung tarik-untuk-muat-ulang.
5. Error 401 ditangani global (dialog A5), bukan per layar.

Pesan error (Indonesia): koneksi gagal → "Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi."; 500/503 → "Terjadi gangguan pada server. Coba lagi sebentar lagi."; 404 → "Data tidak ditemukan."

### 0.7 Navigasi
- Bottom navigation 3 tab: **Home** (`home_outlined`), **Courses** (`menu_book_outlined`), **Profile** (`person_outline`). Tab aktif memakai accent, tab lain warna sekunder, label selalu tampil.
- Struktur sama untuk mahasiswa dan dosen, isi layarnya berbeda. Dibangun dengan `go_router` (`StatefulShellRoute`) agar posisi tab tersimpan.
- Layar detail dibuka di atas shell dengan app bar dan tombol kembali. Bottom nav disembunyikan di layar detail dan form.
- Transisi: bawaan Material (sederhana). Tidak ada animasi besar.

---

## 1. Auth (Phase 2)

### A1. Splash
- Logo teks "SISDIK" (Manrope 700, accent) di tengah, di atas Background.
- Aksi: cek token tersimpan lewat `GET /me`. Berhasil → shell sesuai role (atau A4 bila wajib ganti password). Gagal/tidak ada token → A2.

### A2. Login
```
         SISDIK
   Sistem Informasi Akademik

   NIM / NIP
   [____________________]
   Password
   [______________ (mata)]

   [        Masuk        ]
   [ Masuk dengan wajah  ]   <- hanya jika B2 terpenuhi
          Lupa password?
```
- Padding atas besar (logo di sepertiga atas), form dalam satu kolom, tanpa kartu.
- Validasi: kedua field wajib. Tombol Masuk loading saat request.
- Error `INVALID_CREDENTIALS` tampil di bawah form: "NIM/NIP atau password salah." (satu pesan untuk semua kasus).
- "Lupa password?" → A3.

### A3. Lupa Password
- App bar "Lupa Password". Teks penjelas: "Masukkan NIM/NIP. Permintaan akan diteruskan, lalu kamu akan menerima password sementara."
- Field NIM/NIP, tombol "Kirim Permintaan".
- Setelah kirim: tampil state sukses di layar yang sama (ikon centang, pesan generik: "Jika NIM/NIP terdaftar, permintaan reset sudah dicatat. Hubungi pengelola untuk menerima password sementara."), tombol "Kembali ke Login". Pesan sama baik akun ada maupun tidak.

### A4. Ganti Password Wajib
- Tanpa tombol kembali dan tanpa bottom nav. Teks: "Demi keamanan, ganti password awal sebelum melanjutkan."
- Field: Password lama, Password baru, Konfirmasi password baru (masing-masing dengan tombol tampil/sembunyi).
- Di bawah field baru: daftar aturan (min 8 karakter, huruf dan angka, tidak sama dengan password lama) yang menjadi teks sekunder dan berubah warna Sukses saat terpenuhi.
- Tombol "Simpan Password". Sukses → semua sesi dicabut → dialog singkat "Password diubah. Silakan masuk kembali." → A2.

### A5. Dialog Sesi Berakhir
- `ConfirmDialog` satu tombol, tidak bisa ditutup dengan ketuk di luar. Judul "Sesi berakhir", isi "Silakan masuk kembali.", tombol "Masuk". Menghapus token lalu ke A2.

---

## 2. Mahasiswa (Phase 3)

### S1. Home
- Header: "Halo, {nama depan}" (judul layar) dan keterangan "Tugas terbaru".
- Daftar `AppCard` tugas (urutan sesuai addendum D-12), tiap kartu:
  1. Nama mata kuliah (caption sekunder)
  2. Judul tugas (judul kartu)
  3. Deskripsi singkat (maks 2 baris, elipsis)
  4. Baris bawah: deadline + sisa waktu (kiri), `StatusText` (kanan)
- Ketuk kartu → S4.
- Loading: 3 `SkeletonCard`. Empty: "Tidak ada tugas untuk saat ini." (ikon + keterangan "Tugas baru dari dosen akan muncul di sini.").

### S2. Courses
- Judul layar "Mata Kuliah". Daftar dikelompokkan per semester: header kecil "Semester 3" (caption tebal, sekunder), lalu kartu.
- Kartu MK: nama MK (judul kartu), `KODE · n SKS` (caption), nama dosen pengampu, jadwal pertama (`Senin · 08.00–09.40`) plus "+1 jadwal lagi" bila ada.
- Ketuk → S3. Empty: "Belum ada mata kuliah."

### S3. Detail Mata Kuliah
- App bar: nama MK. Bagian **Informasi** (kartu): kode, dosen pengampu, SKS.
- Bagian **Jadwal**: baris per sesi (`Hari`, `jam`, `ruang`). Jika kosong: "Jadwal belum tersedia."
- Bagian **Tugas**: kartu tugas seperti S1 (tanpa nama MK). Empty: "Belum ada tugas untuk mata kuliah ini."
- Tidak ada nilai.

### S4. Detail Tugas dan Pengumpulan
```
 <  Detail Tugas
 Algoritma dan Pemrograman           (caption)
 Tugas 3: Struktur Data              (judul)
 Jum, 28 Nov 2026 · 23.59 WIB   2 hari lagi
 (v) Sudah dikumpulkan

 Deskripsi
 ...teks lengkap...

 Pengumpulan
 laporan_v2.pdf   1,2 MB   26 Nov, 20.10  (Terbaru)
 laporan_v1.pdf   1,1 MB   25 Nov, 09.05

 [ Pilih File ]         pdf, docx, zip · maks 10 MB
 [    Kirim Tugas    ]  (nonaktif sampai file dipilih)
```
- Bagian pengumpulan kosong: "Belum ada pengumpulan."
- "Terbaru" hanya teks sekunder di samping item terbaru, bukan badge.
- Pilih file memakai `file_picker` dengan filter tipe. Setelah dipilih: tampil nama dan ukuran file, ikon hapus pilihan. Validasi tipe/ukuran di klien hanya untuk kenyamanan (validasi sebenarnya di backend).
- "Kirim Tugas" → `AppBottomSheet` konfirmasi ("Kirim tugas ini? File: nama, ukuran. Kamu bisa mengirim ulang sebelum deadline.") dengan tombol Batal / Kirim.
- Saat upload: bottom sheet berubah menjadi progres (linear indicator + persen), tombol dikunci. Sukses → snackbar "Tugas berhasil dikirim", layar dimuat ulang. Gagal → pesan di sheet sesuai kode: `FILE_TYPE_NOT_ALLOWED` ("Tipe file tidak diizinkan."), `413` ("Ukuran file melebihi 10 MB."), `DEADLINE_PASSED` ("Deadline sudah lewat, pengumpulan ditutup.").
- Jika deadline sudah lewat: bagian pilih/kirim file diganti teks sekunder "Pengumpulan sudah ditutup." (riwayat tetap tampil).

### S5. Profile
- Header: lingkaran inisial (accent muda, teks accent), nama, NIM (caption).
- Kartu **Akademik**: baris "IPK" dengan nilai. Tidak bisa diubah, tanpa ikon edit.
- Kartu **Keamanan** (daftar baris):
  - "Login dengan wajah" + switch → lihat B1 (disembunyikan bila tidak didukung)
  - "Ganti password" → S6
  - "Riwayat perubahan password" → S7
- Tombol teks "Keluar" (warna Error) di bawah → `ConfirmDialog` "Keluar dari akun?" → logout (revoke sesi) → A2.

### S6. Ganti Password (dari Profile)
- Sama dengan A4 tetapi ada tombol kembali. Sukses → semua sesi dicabut → dialog → A2 (perilaku sama dengan A4).

### S7. Riwayat Perubahan Password
- `AppBottomSheet` berisi daftar: tanggal dan jam, jenis perubahan ("Diubah sendiri", "Diubah wajib", "Direset pengelola"). Tidak pernah menampilkan password. Empty: "Belum ada riwayat perubahan."

---

## 3. Dosen (Phase 4)

Bottom nav sama dengan mahasiswa. Layar Profile dosen = S5 tanpa kartu IPK, label NIP (menggunakan S6 dan S7 yang sama).

### L1. Home
- Header "Halo, {nama depan}" dan "Tugas yang kamu berikan".
- Kartu tugas: nama MK (caption), judul, deadline + sisa waktu, dan di kanan teks "12 pengumpulan" (teks biasa, bukan badge). Urutan deadline terdekat.
- Ketuk → L5. Empty: "Belum ada tugas yang kamu buat." (keterangan: "Buat tugas dari halaman mata kuliah.")

### L2. Courses
- Daftar kartu: nama MK, `KODE · n SKS`, jadwal ringkas. Ketuk → L3. Empty: "Belum ada mata kuliah yang diampu."

### L3. Detail Mata Kuliah
- Sama dengan S3 (informasi tanpa dosen pengampu, jadwal, daftar tugas) ditambah tombol "Buat Tugas" (`PrimaryButton`) di bagian atas daftar tugas. Ketuk kartu tugas → L5.

### L4. Form Tugas (buat dan ubah)
- App bar "Buat Tugas" / "Ubah Tugas". Field: Judul (wajib, maks 200), Deskripsi (multiline, boleh kosong), Deadline (dua field baca-saja yang membuka date picker lalu time picker; wajib).
- Validasi: judul wajib; deadline wajib dan harus di masa depan saat membuat tugas baru.
- Tombol "Simpan". Mode ubah: tombol teks "Hapus tugas" (warna Error) di bawah → `ConfirmDialog`. Jika backend menjawab 409: dialog informasi "Tugas tidak bisa dihapus karena sudah ada pengumpulan."
- Sukses → kembali ke layar sebelumnya dengan snackbar.

### L5. Detail Tugas dan Daftar Pengumpulan
- Informasi tugas: MK, judul, deskripsi, deadline + sisa waktu, tombol teks "Ubah" (→ L4).
- Bagian **Pengumpulan**: ringkasan teks `8 dari 12 mahasiswa sudah mengumpulkan`, lalu daftar baris: nama, NIM (caption), waktu kirim (atau "—"), `StatusText`.
- Ketuk baris yang sudah mengumpulkan → `AppBottomSheet` berisi nama file, ukuran, waktu, tombol "Unduh / Buka" (mengunduh lewat endpoint terautentikasi lalu membuka dengan aplikasi bawaan). Baris yang belum mengumpulkan tidak bisa diketuk.
- Empty (tidak ada mahasiswa terdaftar): "Belum ada mahasiswa pada mata kuliah ini."

---

## 4. Biometric (Phase 5)

### B1. Toggle di Profile
- Baris "Login dengan wajah" + keterangan "Gunakan Face Recognition bawaan perangkat". Hanya tampil bila perangkat mendukung Face (daftar biometric memuat `face`).
- Mengaktifkan: prompt biometric sistem → `POST /auth/biometric/enable` → snackbar "Login dengan wajah diaktifkan".
- Menonaktifkan: `ConfirmDialog` → `DELETE /auth/biometric` → hapus token lokal.
- Jika perangkat tidak mendukung Face: baris disembunyikan dan diganti keterangan sekunder "Perangkat ini tidak mendukung pengenalan wajah. Gunakan password untuk masuk."

### B2. Tombol di Login (A2)
- Tombol "Masuk dengan wajah" (`SecondaryButton`) muncul bila ada token biometric tersimpan untuk akun terakhir yang login. Di atas form ditampilkan keterangan sekunder "Akun terakhir: {NIM/NIP}".
- Ketuk → prompt biometric → berhasil → `POST /auth/biometric/login` → shell. Gagal/dibatalkan → tetap di A2, field password tetap bisa dipakai. Token ditolak server (kedaluwarsa/dicabut) → hapus token lokal dan tampilkan "Login dengan wajah tidak berlaku lagi. Masuk dengan password."

---

## 5. Pemetaan Layar ke Fase
| Fase | Layar |
|---|---|
| Phase 1 | Komponen bersama 0.3, tema 0.1–0.2, layar sementara `/health` |
| Phase 2 | A1–A5, kerangka navigasi 0.7 (placeholder 3 tab) |
| Phase 3 | S1–S7 |
| Phase 4 | L1–L5 (Profile dosen memakai S5/S6/S7) |
| Phase 5 | B1–B2 |

## 6. Hal yang Belum Diputuskan
- Warna Sukses/Error tambahan (0.1): setuju atau mau memakai accent/teks sekunder saja?
- Logo: sementara teks "SISDIK". Perlu ikon aplikasi?
- Nama tab "Courses" tetap Inggris sesuai PRD, atau diindonesiakan ("Mata Kuliah")?