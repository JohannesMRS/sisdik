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
- Aksi: cek token tersimpan lewat `GET /me` sambil mempertahankan layar Splash. Berhasil → shell sesuai `role` (atau A4 bila `mustChangePassword=true`). Gagal/tidak ada token → A2. Setiap 401 dari proses ini ditangani sebagai sesi berakhir dan membuka A5.

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
- Validasi: kedua field wajib. Tombol Masuk loading saat request dan dikunci untuk mencegah pengiriman berulang.
- Error `INVALID_CREDENTIALS` tampil di bawah form: "NIM/NIP atau password salah." (satu pesan untuk semua kasus). Akun tidak aktif juga menggunakan pesan ini.
- 403 `PASSWORD_CHANGE_REQUIRED` setelah login mengarah ke A4 dan bukan ditampilkan sebagai error form.
- Kegagalan koneksi, 500/503, dan error lain mengikuti pesan umum 0.6.
- "Lupa password?" → A3.

### A3. Lupa Password
- App bar "Lupa Password". Teks penjelas: "Masukkan NIM/NIP. Permintaan akan diteruskan, lalu kamu akan menerima password sementara."
- Field NIM/NIP, tombol "Kirim Permintaan". Tombol loading saat request dan dikunci selama proses.
- Setelah kirim: tampil state sukses di layar yang sama (ikon centang, pesan generik: "Jika NIM/NIP terdaftar, permintaan reset sudah dicatat. Hubungi pengelola untuk menerima password sementara."), tombol "Kembali ke Login". Pesan sama baik akun ada maupun tidak.
- Kegagalan koneksi atau 500/503 mengikuti pesan umum 0.6; 400 `VALIDATION_ERROR` ditampilkan pada field NIM/NIP.

### A4. Ganti Password Wajib
- Tanpa tombol kembali dan tanpa bottom nav. Teks: "Demi keamanan, ganti password awal sebelum melanjutkan."
- Field: Password lama, Password baru, Konfirmasi password baru (masing-masing dengan tombol tampil/sembunyi).
- Di bawah field baru: daftar aturan (min 8 karakter, huruf dan angka, tidak sama dengan password lama atau identifier, maks 72 karakter) yang menjadi teks sekunder dan berubah warna Sukses saat terpenuhi.
- Validasi konfirmasi password dan setiap aturan dilakukan di klien; respons `VALIDATION_ERROR` ditampilkan pada field terkait.
- Tombol "Simpan Password" loading saat request dan dikunci selama proses.
- Sukses → semua sesi dicabut → dialog singkat "Password diubah. Silakan masuk kembali." → A2.

### A5. Dialog Sesi Berakhir
- `ConfirmDialog` satu tombol, tidak bisa ditutup dengan ketuk di luar. Judul "Sesi berakhir", isi "Silakan masuk kembali.", tombol "Masuk".
- Terbuka untuk respons 401 dari endpoint privat, termasuk `TOKEN_EXPIRED` dan `TOKEN_REVOKED`. Tombol Menghapus token lokal (dan hanya token sesi yang sesuai) lalu membuka A2.