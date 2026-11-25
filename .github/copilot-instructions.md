# Instruksi untuk GitHub Copilot — SISDIK

SISDIK adalah aplikasi mobile sistem informasi akademik untuk mahasiswa dan dosen.
Ini **MVP untuk tugas/demonstrasi**, bukan aplikasi produksi. Monorepo: Flutter + Express.js + PostgreSQL.

## Dokumen rujukan
Selalu baca `docs/progress.md` dan file fase aktif. 
- Jangan membaca ulang dokumen yang sama jika konteksnya
  masih tersedia dan belum berubah.
- Gunakan pencarian heading untuk menemukan bagian relevan.
- Jangan membaca seluruh source code repository.
- Inspeksi hanya file yang berkaitan dengan tugas.
- Jangan membuat ringkasan panjang dari dokumen yang dibaca.
Dokumen lain dibaca **hanya bagian yang relevan** dengan tugas (yang disebut di prompt atau di file fase), jangan memuat semuanya setiap kali:
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
- Setelah satu unit pekerjaan yang dapat diuji selesai,
  perbarui checklist pada file fase.
- Perbarui docs/progress.md setelah satu kelompok tugas
  selesai atau ketika status fase berubah.
- Jangan menulis ulang seluruh riwayat progress.
- Catat hanya perubahan terbaru dan summary yang relevan.
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
- Endpoint perubahan password wajib dikecualikan dari
  pembatasan requirePasswordChanged.
- Pengecualian ini tidak boleh melewati authenticate.
- Endpoint lain tetap mengikuti pembatasan password.
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