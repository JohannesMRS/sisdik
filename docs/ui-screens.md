# Instruksi untuk GitHub Copilot — SISDIK

SISDIK adalah aplikasi mobile sistem informasi akademik untuk mahasiswa dan dosen.
Ini **MVP untuk tugas/demonstrasi**, bukan aplikasi produksi. Monorepo: Flutter + Express.js + PostgreSQL.

## Dokumen rujukan
Selalu baca `docs/progress.md` dan file fase aktif. Dokumen lain dibaca **hanya bagian yang relevan** dengan tugas (yang disebut di prompt atau di file fase), jangan memuat semuanya setiap kali:
1. `docs/context.md` — konteks, keputusan teknis, konvensi kode.
2. `docs/progress.md` — status terkini, cari fase yang sedang aktif.
3. `docs/phases/phase-N-*.md` — fase aktif (daftar tugas + kriteria selesai).
4. `docs/prd-addendum.md` — keputusan yang melengkapi PRD.
5. `docs/database-design.md` dan `docs/api-documentation.md` — kontrak data dan API.
6. `docs/ui-screens.md` — rancangan layar Flutter (wajib untuk setiap pekerjaan UI).

Urutan prioritas jika ada konflik: `docs/prd-addendum.md` > `docs/requirements.md` (PRD asli).

## Alur kerja
- Kerjakan **hanya fase aktif**. Jangan melompat ke fase berikutnya.
- Kerjakan per fitur kecil, dari database sampai UI, lalu uji.
- Setelah selesai satu tugas: centang di file fase dan perbarui `docs/progress.md`.
- Endpoint baru atau yang berubah wajib dicatat di `docs/api-documentation.md`.
- Jika ada hal yang tidak jelas atau di luar scope, **tanyakan**, jangan berasumsi.
- Jangan menambah fitur di luar PRD (lihat daftar Out of Scope di `docs/context.md`).
- **Penutup setiap tugas (otomatis, tidak perlu diminta di prompt):** sebutkan file yang dibuat/diubah, beri perintah uji, centang tugas di file fase, dan update `docs/progress.md`.
- Perintah yang mengubah data atau database (`migrate`, `seed`, backup, restore) **jangan dijalankan sendiri**; berikan perintahnya.
- Prompt bertanda `[Ask]` (tinjau, rencana, verifikasi, review) hanya melaporkan: **jangan mengubah file**.

## Struktur
- `backend-api/` — Express.js, struktur `src/modules/<modul>/{routes,controller,service,schema}.js`
- `mobile_app/` — Flutter, struktur `lib/{core,config,data,models,services,providers,routes,features}`
- `docs/` — dokumentasi

## Aturan backend
- JavaScript (CommonJS), async/await, tanpa ORM, driver `pg`.
- **Selalu** query parameterized (`$1, $2`). Dilarang menyusun SQL dengan string concatenation.
- Validasi semua input dengan `zod` di layer `schema.js`.
- Identitas dan role pengguna **hanya** dari JWT yang sudah diverifikasi (`req.user`), tidak pernah dari body/query/params.
- Setiap endpoint privat: `authenticate` → `requireRole(...)` → `requirePasswordChanged`.
- Cek kepemilikan data di query (misal `WHERE student_id = $1`), bukan hanya di UI.
- Password: Argon2id, hanya di backend. Jangan pernah log password, hash, atau token.
- Format respons dan error mengikuti `docs/context.md` bagian "Konvensi API".
- **Skema database hanya diubah lewat file migrasi baru** di `backend-api/db/migrations/` (format `-- Up Migration` / `-- Down Migration`, panduan di bagian "Migrasi" pada `docs/database-design.md`). Jangan mengedit migrasi yang sudah dijalankan, jangan mengubah tabel langsung lewat `psql`, dan jangan memasukkan seed data ke dalam migrasi. Setelah skema berubah, perbarui `docs/database-design.md`.
- Komentar kode dalam Bahasa Indonesia.

## Aturan Flutter
- State management: `provider`. Routing: `go_router`. HTTP: `dio` (satu instance di `core/`).
- Token disimpan di `flutter_secure_storage`, bukan SharedPreferences.
- Base URL dari `--dart-define=API_URL=...`, jangan hardcode.
- UI: Clean & Minimalist, Light Mode saja, warna dan font sesuai `docs/context.md`.
- Layar **harus mengikuti `docs/ui-screens.md`** (ID layar, urutan komponen, state, teks). Pakai widget bersama di `lib/core/widgets/`, jangan membuat ulang. Jika perlu menyimpang, tanyakan dan perbarui dokumen itu.
- Tanpa badge. Wajib ada skeleton loading, error state, dan empty state untuk setiap data dari API.
- Tidak ada animasi besar tanpa persetujuan.
- Jangan menaruh logika keamanan/otorisasi di Flutter sebagai satu-satunya lapisan.
- Komentar kode dalam Bahasa Indonesia.

## Keamanan (tidak boleh dilanggar)
- Dilarang SHA-256 atau hash cepat untuk password. Gunakan Argon2id.
- Jangan commit `.env`, file di `backend-api/uploads/`, atau kredensial.
- Upload file wajib divalidasi tipe dan ukuran di backend.
- Mahasiswa tidak boleh mengubah IPK, NIM, atau mata kuliah, lewat endpoint mana pun.

## Mahasiswa — Phase 3

Aturan bersama:
- Light mode, Background `#F8FAFC`, Surface `#FFFFFF`, teks `#0F172A`, sekunder `#64748B`, accent `#2563EB`.
- Tidak memakai badge. Status ditampilkan sebagai teks.
- Setiap data API memakai skeleton saat loading, tombol "Coba lagi" pada error, dan empty state yang relevan.

### S1 — Home
Urutan komponen:
1. AppBar berjudul `Home`.
2. Daftar kartu tugas maksimal sesuai respons API.
3. Setiap kartu menampilkan kode/nama MK, judul tugas, deskripsi singkat, deadline, dan status teks.
4. Ketuk kartu membuka S4 Detail Tugas.
- Loading: skeleton kartu.
- Error: `Terjadi kesalahan. Coba lagi.` beserta tombol `Coba lagi`.
- Empty: judul `Tidak ada tugas untuk saat ini.` dan deskripsi `Belum ada tugas yang perlu ditinjau.`

### S2 — Courses
Urutan komponen:
1. AppBar berjudul `Courses`.
2. Daftar dikelompokkan per `semester`, masing-masing dengan istilah akademik dari API.
3. Setiap kartu MK menampilkan kode, nama, dan SKS.
4. Ketuk kartu membuka S3 Detail Mata Kuliah.
- Loading: skeleton kelompok dan kartu.
- Error: tombol `Coba lagi`.
- Empty: `Belum ada mata kuliah yang diambil.`

### S3 — Detail Mata Kuliah
Urutan komponen:
1. AppBar dengan nama atau kode MK.
2. Informasi kode, nama, dosen pengampu, SKS, dan semester.
3. Bagian `Jadwal` berisi hari, jam, dan ruang untuk setiap sesi.
4. Bagian `Tugas` berisi daftar tugas MK beserta deadline dan status teks.
5. Ketuk tugas membuka S4 Detail Tugas.
- Loading: skeleton pada seluruh bagian.
- Error: tombol `Coba lagi`.
- Empty jadwal/tugas: pesan relevan tanpa badge.

### S4 — Detail Tugas
Urutan komponen:
1. AppBar berjudul `Detail Tugas`.
2. Kode/nama MK, judul tugas, deskripsi, deadline, dan status teks.
3. Bagian `Riwayat Pengumpulan` berisi nama file, waktu pengumpulan, ukuran, dan penanda versi terbaru sebagai teks.
4. Tombol `Pilih File`.
5. Setelah file dipilih, tampilkan nama file dan ukuran.
6. Tombol `Kirim`.
- Jenis diizinkan: PDF, DOCX, ZIP; maksimal 10 MB.
- Validasi file di klien hanya untuk kenyamanan dan tetap diverifikasi oleh backend.
- Sebelum kirim, tampilkan dialog konfirmasi berisi nama file.
- Setelah konfirmasi, tampilkan progres upload dan tombol kirim dinonaktifkan.
- Setelah berhasil, muat ulang detail/riwayat dan tampilkan status `Sudah dikumpulkan`.
- Loading: skeleton.
- Error: pesan backend yang aman dan tombol `Coba lagi` bila pengambilan gagal.
- Empty riwayat: `Belum ada file dikumpulkan.`

### S5 — Profile
Urutan komponen:
1. AppBar berjudul `Profile`.
2. Nama, NIM, dan IPK dua angka desimal.
3. Bagian `Riwayat Perubahan Password` dari `/me/password-histories`.
4. Tombol `Ganti Password` menuju layar perubahan password.
5. Bagian biometric placeholder menyatakan `Biometric` dan `Belum dikonfigurasi` tanpa fungsi pada Phase 3.
6. Tombol `Keluar`.
- Ketuk Keluar membuka dialog konfirmasi.
- Loading/error/empty mengikuti aturan bersama.

### S6 — Loading, Error, dan Empty
Gunakan widget bersama `SkeletonCard`, `ErrorState`, dan `EmptyState`. Skeleton dipakai saat API berjalan, bukan placeholder statis.

### S7 — Bottom Navigation
Navigasi tetap: `Home`, `Courses`, `Profile`. Tidak memakai tab atau badge tambahan untuk status tugas.

## Prioritas Dokumentasi

Jika ditemukan konflik:
1. PRD Addendum: keputusan kebutuhan dan business rules.
2. Security Design: mekanisme keamanan.
3. Database Design: struktur dan relasi database.
4. API Documentation: kontrak endpoint dan respons.
5. UI Screens: spesifikasi tampilan.
6. Phase Document: ruang lingkup implementasi fase.

Jika konflik menyangkut keputusan lintas dokumen,
jangan mengambil keputusan sendiri. Laporkan dan tanyakan.