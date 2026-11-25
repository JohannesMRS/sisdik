# SISDIK — PRD Addendum (Celah yang Ditambal)

Dokumen ini melengkapi PRD. Jika bertentangan dengan PRD asli, **addendum ini yang berlaku**. Setiap keputusan punya ID agar bisa dirujuk di kode dan commit.

## A. Keputusan

### D-01. Programmer tidak bisa menulis hash Argon2id lewat SQL biasa
PRD menyebut akun dibuat "melalui database", padahal hash Argon2id tidak bisa dibuat manual di SQL.
**Keputusan:** sediakan script CLI di `backend-api/scripts/`:
- `create-user` (satu akun) dan `import-users` (CSV: role, identifier, name, password awal).
- `reset-password` (membuat password sementara acak, mencetak sekali ke terminal).
Data akademik lain (IPK, mata kuliah, jadwal, relasi) tetap diisi lewat SQL/seed.

### D-02. Penanda wajib ganti password
Tambah `users.must_change_password`. Bernilai `true` untuk akun baru dan setelah reset password. Selama `true`, semua endpoint privat ditolak dengan `403 PASSWORD_CHANGE_REQUIRED`, kecuali: `POST /auth/change-password`, `POST /auth/logout`, `GET /me`. Berlaku untuk **mahasiswa dan dosen** (PRD hanya menyebut mahasiswa).

### D-03. Kebijakan password
Minimal 8 karakter, mengandung huruf dan angka, tidak sama dengan password lama, tidak sama dengan identifier. Maksimal 72 karakter. Password awal dari programmer tidak dicek kebijakan, tapi password baru wajib.

### D-04. Alur Forgot Password (login belum berhasil)
1. Layar login → "Lupa password" → input NIM/NIP.
2. `POST /auth/forgot-password` selalu membalas sukses dengan pesan generik (agar tidak membocorkan apakah NIM/NIP terdaftar) dan, jika akun ada, membuat baris `password_reset_requests` berstatus `pending`.
3. Programmer melihat antrean (`SELECT ... WHERE status='pending'`), menjalankan `reset-password`, lalu memberikan password sementara ke pengguna.
4. Script mengatur `must_change_password=true`, mencabut semua sesi dan biometric, menandai request `done`, mencatat `password_histories` dan `audit_logs`.

### D-05. Satu-satunya batasan login: sesuai PRD
PRD menyatakan tidak ada batas percobaan login. Default tetap mengikuti PRD, **tetapi** middleware rate limit dibuat dengan flag `.env` `LOGIN_RATE_LIMIT_ENABLED` (default `false`) supaya bisa dinyalakan saat demo keamanan. Percobaan gagal tetap dicatat di audit log. *(Lihat pertanyaan terbuka Q-01.)*

### D-06. Sesi 30 menit dan JWT
Tidak ada refresh token. Setelah 30 menit pengguna login ulang. Flutter menangani `401` dengan dialog "Sesi berakhir" lalu kembali ke layar login. Satu akun boleh punya banyak sesi aktif (banyak perangkat).

### D-07. Desain biometric yang konsisten dengan JWT 30 menit
PRD berkata biometric "mengakses sesi akun yang tersimpan", padahal JWT hanya hidup 30 menit. **Keputusan:** biometric memakai *token perangkat* terpisah.
1. Pengguna login password → di Profil mengaktifkan biometric → app cek dukungan, minta verifikasi biometric.
2. `POST /auth/biometric/enable` (butuh JWT + `deviceId`) → backend membuat token acak 32 byte, menyimpan **hash SHA-256**-nya di `biometric_credentials` (SHA-256 aman di sini karena token acak berentropi tinggi, beda dengan password), mengembalikan token **sekali saja**.
3. App menyimpan token di secure storage dengan kunci per akun: `bio_token:<identifier>`.
4. Login biometric: app menampilkan prompt biometric → jika berhasil, kirim `POST /auth/biometric/login` (`identifier`, `deviceId`, `token`) → backend verifikasi hash, belum kedaluwarsa (30 hari), belum dicabut → membuat sesi dan JWT baru.
5. Dinonaktifkan oleh: tombol nonaktifkan (`DELETE /auth/biometric`), ganti/reset password, atau kedaluwarsa. Logout biasa **tidak** menghapus biometric.
6. Pindah perangkat: token tidak ada → wajib login password.

### D-08. Face Recognition saja — batasan teknis
`local_auth` memberi daftar biometric yang tersedia. App menawarkan biometric hanya jika daftar memuat `BiometricType.face`. Jika hanya fingerprint, opsi biometric disembunyikan. **Risiko:** sebagian HP Android mengklasifikasikan face unlock sebagai "weak" dan tidak selalu terdeteksi sebagai `face`. Hal ini harus diuji di HP demo pada Phase 5. *(Q-02.)*

### D-09. Mata kuliah, semester, dan jadwal
- `courses.semester` = semester kurikulum (1–8). Daftar Courses mahasiswa dikelompokkan per semester.
- `student_courses.academic_term` (contoh `2025/2026 Ganjil`) mencatat kapan diambil.
- Jadwal memakai tabel `course_schedules` (hari, jam mulai, jam selesai, ruang), karena satu MK bisa punya beberapa sesi per minggu.

### D-10. Aturan tugas
- Dosen membuat tugas untuk MK yang diampu: judul, deskripsi, deadline (wajib).
- **Mahasiswa mengumpulkan:** satu file per pengiriman. Boleh kirim ulang **sebelum deadline**; versi lama tetap tersimpan sebagai riwayat, versi terbaru yang dianggap berlaku.
- Setelah deadline: pengiriman ditolak `DEADLINE_PASSED` (waktu server yang menentukan).
- Status (teks, tanpa badge): **Belum dikumpulkan**, **Sudah dikumpulkan**, **Lewat deadline** (deadline lewat dan belum mengumpulkan).
- Dosen **tidak** memberi nilai (penilaian manual). Dosen hanya melihat daftar pengumpulan dan mengunduh file.
- Menghapus tugas yang sudah punya pengumpulan: ditolak (`409`), demi integritas data.

### D-11. Aturan upload file
Tipe diizinkan: `pdf`, `docx`, `zip`. Maksimal **10 MB**. Validasi: ekstensi + MIME + signature file (magic bytes). Nama file disimpan sebagai UUID, nama asli disimpan di database. Folder `uploads/` tidak di-serve statis, file hanya bisa diunduh lewat endpoint yang cek kepemilikan. Hitung dan simpan SHA-256 file (bukti integritas). Path file tidak pernah dikirim ke klien.

### D-12. Definisi Home
- **Mahasiswa:** tugas dari MK yang diambil, diurutkan: belum dikumpulkan dengan deadline terdekat dulu, lalu yang sudah dikumpulkan. Batas 20 item. Tugas lewat deadline lebih dari 30 hari disembunyikan.
- **Dosen:** tugas yang ia buat, diurutkan deadline terdekat, dengan jumlah pengumpulan per tugas.

### D-13. Endpoint dipisah per role
`/student/*` dan `/lecturer/*` (lihat `docs/api-documentation.md`) agar pemeriksaan role jelas dan mudah diuji. Pengambilan data tidak pernah menerima `studentId`/`lecturerId` dari klien.

### D-14. Respons 404 untuk data milik orang lain
Akses ke resource yang bukan miliknya mengembalikan `404` (bukan `403`) agar keberadaan data tidak bocor. Percobaannya dicatat di audit log (`ACCESS_DENIED`).

### D-15. Akun nonaktif
Tambah `users.is_active`. Akun nonaktif tidak bisa login dan sesinya ditolak. Tidak ada penghapusan permanen user.

### D-16. IPK
`students.gpa NUMERIC(3,2)` dengan CHECK 0.00–4.00. Tidak ada endpoint tulis untuk IPK.

### D-17. Audit log
Event yang dicatat: `LOGIN_SUCCESS`, `LOGIN_FAILED`, `LOGOUT`, `PASSWORD_CHANGED`, `PASSWORD_RESET`, `BIOMETRIC_ENABLED`, `BIOMETRIC_DISABLED`, `BIOMETRIC_LOGIN`, `ASSIGNMENT_CREATED/UPDATED/DELETED`, `SUBMISSION_UPLOADED`, `SUBMISSION_DOWNLOADED`, `ACCESS_DENIED`. Isi: user, aksi, entitas, IP, metadata JSON **tanpa** data sensitif.

### D-18. Backup & restore
- `scripts/backup.sh`: `pg_dump` format custom (`-Fc`) ke folder di luar repo (default `~/sisdik-backups/`), nama berstempel waktu, ikut menyalin folder `uploads/`.
- Jadwal mingguan memakai `cron` (contoh di `docs/security-design.md`).
- `scripts/restore.sh`: restore ke database uji (`sisdik_restore_test`), lalu cek jumlah baris tabel utama.
- Lokasi berbeda dari database utama: minimal folder di drive/partisi lain atau flashdisk, dicatat di dokumentasi.

### D-19. Penanganan kegagalan database
Pool `pg` dengan timeout koneksi. Error koneksi menghasilkan `503 SERVICE_UNAVAILABLE` generik. Endpoint `GET /health` memeriksa koneksi DB.

### D-20. Keamanan HTTP dasar
`helmet`, CORS dibatasi (mobile tidak memerlukan CORS, jadi default tertutup), batas ukuran body JSON 100 KB, `x-powered-by` dimatikan. HTTPS tidak dipakai di demo lokal, dicatat sebagai keterbatasan di dokumentasi keamanan, dan Android memakai `usesCleartextTraffic` hanya untuk debug (lewat `AndroidManifest` di folder `debug`/`profile`).

### D-21. Konvensi penamaan
Folder `mobile_app` (bukan `mobile-app` seperti di PRD) karena package Dart tidak boleh memakai tanda hubung. API memakai JSON `camelCase`, database memakai `snake_case`.

## B. Pertanyaan Terbuka (sudah ada default, silakan koreksi)
- **Q-01.** Apakah rate limit login tetap dimatikan (sesuai PRD)? Dosen penguji keamanan biasanya menanyakan brute force. Default: dimatikan, bisa dinyalakan lewat flag.
- **Q-02.** HP demo apa yang dipakai, dan apakah face unlock-nya terdeteksi sebagai `face` oleh `local_auth`? Jika tidak, opsi: pakai HP lain, atau (di luar rencana) memakai pendekatan face recognition berbasis kamera.
- **Q-03.** Tipe file dan batas 10 MB untuk tugas: cukup `pdf, docx, zip`?
- **Q-04.** Lingkup dosen (D-10): buat/ubah/hapus tugas, lihat dan unduh pengumpulan, tanpa penilaian. Sesuai?
- **Q-05.** Apakah pengumpulan setelah deadline benar-benar ditolak, atau diterima dengan label terlambat?