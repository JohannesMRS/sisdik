# SISDIK — Sistem Informasi Akademik

## 1. Gambaran Umum

SISDIK merupakan aplikasi sistem informasi akademik berbasis mobile yang ditujukan untuk membantu mahasiswa dan dosen dalam mengakses informasi akademik.

Aplikasi dikembangkan dengan pendekatan **Minimum Viable Product (MVP)**. Fokus utamanya adalah menyediakan fitur akademik dasar dengan memperhatikan keamanan data, kemudahan penggunaan, dan desain antarmuka yang modern.

### Tujuan utama
- Memudahkan mahasiswa melihat informasi mata kuliah dan tugas.
- Memungkinkan mahasiswa mengumpulkan tugas melalui aplikasi.
- Memudahkan dosen mengakses informasi mata kuliah dan tugas yang diberikan.
- Melindungi data akademik agar hanya dapat diakses oleh pengguna yang berwenang.
- Menerapkan konsep keamanan CIA Triad, Biometric Security, dan Cryptography.

### Target pengguna

Untuk tahap MVP:
1. Mahasiswa.
2. Dosen.

**Admin belum memiliki aplikasi atau dashboard tersendiri.** Pengelolaan akun dan data akademik dilakukan oleh programmer melalui database secara manual.

---

# 2. Teknologi yang Digunakan

| Komponen | Teknologi |
|---|---|
| Mobile Application | Flutter |
| Backend | Express.js (Node.js) |
| Database | PostgreSQL |
| API Communication | REST API |
| Authentication | JWT |
| Password Hashing | Argon2id |
| Biometric Authentication | Native Device Biometric |
| Local Secure Storage | Flutter Secure Storage |
| Database Driver | pg |
| Version Control | Git & GitHub |

### Struktur Monorepo

Seluruh aplikasi berada dalam satu repository GitHub, tetapi setiap aplikasi memiliki tanggung jawab dan dependensinya masing-masing.

```text
sisdik/
│
├── mobile-app/
│   ├── android/
│   ├── ios/
│   ├── assets/
│   ├── lib/
│   │   ├── core/
│   │   ├── config/
│   │   ├── data/
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── routes/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── courses/
│   │   │   ├── assignments/
│   │   │   ├── profile/
│   │   │   └── biometric/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── backend-api/
│   ├── src/
│   │   ├── config/
│   │   ├── middlewares/
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   ├── users/
│   │   │   ├── students/
│   │   │   ├── lecturers/
│   │   │   ├── courses/
│   │   │   └── assignments/
│   │   ├── utils/
│   │   ├── app.js
│   │   └── server.js
│   ├── uploads/
│   ├── tests/
│   └── package.json
│
├── docs/
│   ├── requirements.md
│   ├── database-design.md
│   ├── api-documentation.md
│   └── security-design.md
│
├── .gitignore
└── README.md
```

Struktur ini masih bisa disesuaikan ketika implementasi dimulai. Prinsipnya, Flutter hanya menangani antarmuka dan interaksi pengguna, sedangkan Express.js bertanggung jawab terhadap autentikasi, otorisasi, validasi, dan pengelolaan data.

---

# 3. Authentication dan Account Management

## 3.1 Login

Aplikasi tidak menyediakan registrasi mandiri.

Akun mahasiswa dan dosen dibuat oleh programmer melalui database.

### Mahasiswa
- Login menggunakan NIM dan password.
- Password awal ditentukan oleh programmer.
- Mahasiswa wajib mengganti password pada login pertama.
- Tidak ada batasan jumlah percobaan login untuk MVP.

### Dosen
- Memiliki akun yang dibuat oleh programmer.
- Menggunakan mekanisme autentikasi yang sama.
- Identitas login dosen menggunakan NIP sebagai rekomendasi, apabila belum ada ketentuan lain.

### Ketentuan tambahan
- Satu perangkat boleh digunakan untuk login beberapa akun.
- Tidak ada pembatasan satu akun untuk satu perangkat.
- Tidak tersedia fitur registrasi publik.
- Aplikasi harus selalu terhubung dengan backend.
- Tidak tersedia mode offline.

## 3.2 JWT Authentication

Setiap login yang berhasil akan menghasilkan token autentikasi.

Ketentuannya:

1. Token memiliki masa berlaku 30 menit.
2. Setelah token kedaluwarsa, pengguna harus login kembali.
3. Token wajib diverifikasi pada setiap endpoint yang membutuhkan autentikasi.
4. Logout harus mencabut sesi atau token yang sedang digunakan.
5. Token yang sudah dicabut tidak boleh digunakan kembali.
6. Token disimpan menggunakan secure storage pada perangkat.

Untuk mendukung pencabutan token, backend sebaiknya menggunakan tabel session/token dengan informasi seperti:

- User ID.
- Token ID (`jti`).
- Waktu pembuatan.
- Waktu kedaluwarsa.
- Status pencabutan.

Dengan pendekatan ini, JWT tidak hanya diperiksa tanda tangannya, tetapi juga status sesinya.

## 3.3 Change Password

Mahasiswa wajib mengganti password awal.

Fitur perubahan password mencakup:
- Memasukkan password lama.
- Memasukkan password baru.
- Konfirmasi password baru.
- Validasi password.
- Mencatat riwayat perubahan password.

Riwayat perubahan password hanya menampilkan informasi seperti tanggal dan waktu perubahan. Password lama maupun password baru tidak boleh ditampilkan.

Setelah password berhasil diubah, sesi lama sebaiknya dicabut sehingga pengguna harus melakukan autentikasi kembali.

## 3.4 Forgot Password

Tersedia fitur lupa password.

Karena aplikasi masih berjalan secara lokal untuk demonstrasi, mekanisme reset password perlu disesuaikan dengan lingkungan demonstrasi.

Rekomendasi MVP:
- Pengguna mengajukan permintaan reset.
- Programmer melakukan reset password melalui mekanisme backend yang terkontrol.
- Pengguna memperoleh password sementara.
- Pengguna wajib mengganti password sementara tersebut ketika login berikutnya.

Tidak perlu menyediakan registrasi atau sistem pengelolaan akun admin di aplikasi.

---

# 4. Biometric Security

Biometric Security digunakan sebagai alternatif login, bukan sebagai pengganti autentikasi awal.

### Alur penggunaan

1. Pengguna login pertama kali menggunakan NIM/NIP dan password.
2. Pengguna dapat mengaktifkan fitur biometric melalui halaman profil.
3. Ketika fitur aktif, pengguna dapat menggunakan autentikasi biometrik pada login berikutnya.
4. Jika autentikasi berhasil, aplikasi dapat mengakses sesi akun yang tersimpan secara aman.
5. Jika autentikasi gagal atau perangkat tidak mendukung, pengguna dapat menggunakan NIM/NIP dan password.

### Ketentuan

- Biometric dapat diaktifkan dan dinonaktifkan.
- Setiap akun memiliki pengaturan biometric tersendiri pada perangkat.
- Ketika pengguna berpindah perangkat, pengguna wajib login menggunakan NIM/NIP dan password.
- Tidak ada kewajiban menggunakan biometric.
- Aplikasi hanya mengizinkan Face Recognition sesuai persyaratan proyek.

### Catatan implementasi penting

Aku merekomendasikan penggunaan native biometric melalui Flutter, misalnya package `local_auth`.

Namun, ada perbedaan antara dua pendekatan:

**Native Biometric**
- Menggunakan fitur biometrik yang sudah disediakan sistem operasi.
- Tidak perlu mengunggah foto wajah ke server.
- Data biometrik tidak disimpan oleh aplikasi.
- Aplikasi hanya menerima hasil autentikasi berhasil atau gagal.

**Face Recognition berbasis foto**
- Mengambil gambar wajah melalui kamera.
- Membandingkan wajah dengan gambar referensi yang disimpan.
- Membutuhkan sistem pengenalan wajah, pengamanan data biometrik, dan perlindungan terhadap foto atau video palsu.

Untuk MVP, aku merekomendasikan pendekatan pertama.

Karena kamu menginginkan Face Recognition saja, aplikasi harus memeriksa apakah perangkat menyediakan autentikasi wajah. Jika perangkat hanya menyediakan fingerprint, fitur biometric tidak ditawarkan dan pengguna tetap login menggunakan password.

**Tidak perlu meminta mahasiswa mengunggah foto wajah ke aplikasi jika kita menggunakan native biometric.** Pendaftaran wajah dilakukan melalui sistem keamanan perangkat.

---

# 5. Cryptography dan Password Security

Kamu mengusulkan SHA-256 untuk hashing password.

Namun, ada satu hal yang perlu kita ubah.

**SHA-256 tidak direkomendasikan untuk menyimpan password pengguna.**

SHA-256 merupakan algoritma hash yang cepat. Kecepatan tersebut justru membuat password lebih mudah ditebak melalui serangan brute force atau dictionary attack apabila database bocor.

Rekomendasiku adalah menggunakan **Argon2id**.

### Ketentuan password hashing

1. Password diproses di backend Express.js.
2. Password tidak boleh disimpan dalam bentuk plaintext.
3. Gunakan Argon2id untuk menghasilkan password hash.
4. Gunakan salt unik untuk setiap password.
5. Proses verifikasi password dilakukan menggunakan fungsi verify dari library Argon2.
6. Password tidak boleh dikirim atau disimpan dalam bentuk hash yang dibuat oleh Flutter.

### Bagaimana dengan password yang sudah ada?

Ketika programmer membuat akun awal, password harus langsung diproses menggunakan Argon2id sebelum disimpan ke database.

Ketika mahasiswa mengganti password:
1. Backend memverifikasi password lama.
2. Backend menerima password baru.
3. Password baru di-hash menggunakan Argon2id.
4. Hash lama digantikan dengan hash baru.

Password lama tidak perlu di-hash ulang karena sistem tidak menyimpan password plaintext.

### Perlindungan tambahan

- Gunakan HTTPS ketika aplikasi nantinya dipublikasikan.
- Gunakan parameterized query untuk mencegah SQL Injection.
- Validasi setiap input di backend.
- Jangan pernah menyimpan password di log.
- Lindungi file `.env` dan kredensial database.

---

# 6. Penerapan CIA Triad

SISDIK wajib menerapkan tiga prinsip utama keamanan informasi.

## 6.1 Confidentiality

Tujuan: memastikan informasi hanya dapat diakses oleh pengguna yang memiliki hak akses.

Implementasi:
- Login menggunakan NIM/NIP dan password.
- JWT untuk autentikasi.
- Role-based access control.
- Setiap pengguna hanya dapat mengakses data sesuai identitas dan kewenangannya.
- Mahasiswa hanya dapat melihat data akademik miliknya sendiri.
- Dosen hanya dapat mengakses data yang berkaitan dengan mata kuliah dan tugas yang menjadi tanggung jawabnya.
- Password disimpan menggunakan Argon2id.
- Token disimpan secara aman di perangkat.

Contoh:

Mahasiswa A tidak boleh dapat melihat informasi akademik Mahasiswa B meskipun ia mencoba mengubah parameter ID melalui request API.

## 6.2 Integrity

Tujuan: memastikan data tidak dapat dimodifikasi oleh pihak yang tidak berwenang.

Implementasi:
- Validasi seluruh perubahan data di backend.
- Otorisasi sebelum melakukan operasi INSERT, UPDATE, dan DELETE.
- Mahasiswa tidak dapat mengubah data akademik seperti IPK.
- Mahasiswa hanya dapat mengubah password miliknya.
- Dosen hanya dapat mengubah data yang menjadi tanggung jawabnya.
- Gunakan audit log untuk mencatat aktivitas penting.
- Gunakan foreign key dan constraint pada PostgreSQL.

Contoh:

Mahasiswa tidak boleh mengubah IPK melalui manipulasi request API meskipun ia mengetahui endpoint untuk memperbarui profil.

## 6.3 Availability

Tujuan: memastikan data dan layanan dapat tersedia kembali ketika terjadi kegagalan.

Implementasi:
- Full database backup satu kali setiap minggu.
- Menyimpan hasil backup pada lokasi berbeda dari database utama.
- Menyediakan prosedur pemulihan database.
- Melakukan pengujian restore backup.
- Menangani kegagalan koneksi database dengan baik.

Catatan: backup mingguan merupakan persyaratan awal proyek. Untuk sistem akademik yang digunakan secara nyata, frekuensi backup perlu ditingkatkan agar kehilangan data dapat diminimalkan.

---

# 7. Fitur Mahasiswa

Aplikasi mahasiswa menggunakan bottom navigation dengan tiga menu utama:

1. Home.
2. Courses.
3. Profile.

## 7.1 Home

Beranda mahasiswa menampilkan informasi tugas terbaru.

Informasi yang ditampilkan:
- Nama mata kuliah.
- Judul tugas.
- Deskripsi singkat.
- Deadline.
- Status pengumpulan.

Tidak perlu menampilkan ringkasan semester aktif.

Jika tidak ada tugas, tampilkan ilustrasi dan tulisan:

"Tidak ada tugas untuk saat ini."

## 7.2 Courses

Menampilkan seluruh mata kuliah yang diambil mahasiswa dari berbagai semester.

Mata kuliah sudah ditentukan oleh program studi, admin, atau programmer.

Mahasiswa tidak dapat memilih maupun mengubah mata kuliah yang diambil.

Setiap mata kuliah memiliki:
- Nama mata kuliah.
- Kode mata kuliah.
- Nama dosen pengampu.
- SKS.
- Jadwal perkuliahan.

### Detail Mata Kuliah

Ketika mahasiswa memilih salah satu mata kuliah, aplikasi menampilkan:

- Nama mata kuliah.
- Kode mata kuliah.
- Nama dosen pengampu.
- SKS.
- Jadwal perkuliahan.
- Daftar tugas.

Mahasiswa tidak dapat melihat nilai mata kuliah karena proses penilaian masih dilakukan secara manual.

## 7.3 Assignment

Mahasiswa dapat melihat dan mengumpulkan tugas.

Informasi tugas:
- Judul tugas.
- Deskripsi.
- Mata kuliah terkait.
- Deadline.
- Status pengumpulan.

Fitur pengumpulan:
- Mengunggah file tugas.
- Mengirim tugas.
- Melihat status pengumpulan.
- Melihat informasi pengumpulan sebelumnya.

Jenis file dan batas ukuran upload perlu ditentukan ketika implementasi fitur dimulai.

## 7.4 Profile

Informasi yang ditampilkan:
- Nama mahasiswa.
- NIM.
- IPK.
- Pengaturan biometric.
- Riwayat perubahan password.

Fitur yang tersedia:
- Mengganti password.
- Mengaktifkan biometric.
- Menonaktifkan biometric.
- Logout.

Ketentuan:
- Mahasiswa hanya memiliki satu profil.
- Mahasiswa tidak dapat mengubah NIM.
- Mahasiswa tidak dapat mengubah IPK.
- IPK diinput atau diperbarui oleh programmer melalui database.
- Mahasiswa tidak dapat mengubah informasi akademik lainnya.

---

# 8. Fitur Dosen

Aplikasi dosen menggunakan bottom navigation dengan konsep yang konsisten dengan aplikasi mahasiswa.

Menu utama:
1. Home.
2. Courses.
3. Profile.

## 8.1 Home

Menampilkan tugas yang diberikan oleh dosen.

Informasi tugas dapat mencakup:
- Judul tugas.
- Mata kuliah terkait.
- Deadline.
- Deskripsi singkat.

## 8.2 Courses

Menampilkan seluruh mata kuliah yang diampu oleh dosen.

Setiap mata kuliah memiliki:
- Nama mata kuliah.
- Kode mata kuliah.
- SKS.
- Jadwal perkuliahan.

## 8.3 Profile

Informasi yang ditampilkan:
- Nama dosen.
- NIP.
- Pengaturan biometric.
- Riwayat perubahan password.

Fitur:
- Mengganti password.
- Mengaktifkan biometric.
- Menonaktifkan biometric.
- Logout.

Catatan: mekanisme pembuatan, pengelolaan tugas, dan pemeriksaan hasil pengumpulan oleh dosen masih perlu ditetapkan secara lebih detail sebelum implementasi modul dosen.

---

# 9. Database Design

Database menggunakan PostgreSQL.

Berikut gambaran entitas utama yang direkomendasikan untuk MVP.

| Tabel | Fungsi |
|---|---|
| users | Menyimpan informasi autentikasi dan role |
| students | Menyimpan informasi profil mahasiswa |
| lecturers | Menyimpan informasi profil dosen |
| courses | Menyimpan data mata kuliah |
| student_courses | Relasi mahasiswa dengan mata kuliah |
| lecturer_courses | Relasi dosen dengan mata kuliah |
| assignments | Menyimpan data tugas |
| assignment_submissions | Menyimpan data pengumpulan tugas |
| password_histories | Mencatat riwayat perubahan password |
| sessions | Mengelola sesi dan pencabutan token |
| audit_logs | Mencatat aktivitas penting |

### Relasi utama

- Satu user memiliki satu profil mahasiswa atau dosen sesuai role.
- Satu mahasiswa dapat mengambil banyak mata kuliah.
- Satu mata kuliah dapat diikuti banyak mahasiswa.
- Satu dosen dapat mengampu banyak mata kuliah.
- Satu mata kuliah dapat memiliki banyak tugas.
- Satu tugas dapat memiliki banyak pengumpulan dari mahasiswa.

### Informasi IPK

IPK dapat disimpan sebagai field pada tabel `students`, bukan `users`.

Alasannya, IPK merupakan informasi akademik yang melekat pada profil mahasiswa, bukan informasi autentikasi.

Nilai IPK diperbarui oleh programmer sesuai kebutuhan demonstrasi.

---

# 10. Design System dan UI/UX

## 10.1 Konsep Visual

Gaya desain:

**Clean & Minimalist**

Karakteristik:
- Tampilan sederhana.
- Tidak terlalu banyak elemen dekoratif.
- Mengutamakan keterbacaan.
- Spacing yang konsisten.
- Komponen dengan hierarki visual yang jelas.
- Navigasi mudah dipahami.

## 10.2 Color Palette

| Peran | Warna | Kode |
|---|---|---|
| Background | Slate 50 | #F8FAFC |
| Surface | White | #FFFFFF |
| Primary Text | Slate 900 | #0F172A |
| Secondary Text | Slate 500 | #64748B |
| Accent | Blue 600 | #2563EB |

Proporsi penggunaan warna:
- 60% background dan surface.
- 30% teks dan warna netral.
- 10% accent.

## 10.3 Typography

Menggunakan dua jenis font:

- Manrope.
- IBM Plex Sans.

Rekomendasi:
- Manrope untuk heading dan elemen yang membutuhkan penekanan.
- IBM Plex Sans untuk body text dan informasi akademik.

## 10.4 Komponen UI

Komponen yang digunakan:
- Bottom Navigation.
- Cards.
- Input Fields.
- Buttons.
- Modal Dialog.
- Bottom Sheet.
- Skeleton Loading.
- Empty State.
- Confirmation Dialog.
- Form Validation.

Tidak menggunakan badge untuk menyampaikan informasi. Informasi status dapat ditampilkan menggunakan teks, warna yang halus, dan elemen visual sederhana.

## 10.5 Animasi

- Menggunakan animasi transisi sederhana.
- Mengutamakan responsivitas dan performa.
- Tidak menggunakan animasi besar tanpa persetujuan terlebih dahulu.

## 10.6 Tema

Untuk MVP:
- Hanya mendukung Light Mode.
- Tidak menyediakan Dark Mode.

## 10.7 Loading dan Empty State

Ketika mengambil data dari API:
- Gunakan skeleton loading.
- Tampilkan error state ketika terjadi kegagalan koneksi.
- Tampilkan empty state ketika tidak ada data.

Contoh empty state:
- Tidak ada tugas.
- Tidak ada mata kuliah.

---

# 11. Security Requirements

Seluruh keamanan harus diterapkan di sisi backend, bukan hanya di Flutter.

Ketentuan wajib:

1. Setiap endpoint privat harus memverifikasi JWT.
2. Setiap endpoint harus memeriksa role pengguna.
3. Backend harus mengambil identitas pengguna dari token yang sudah diverifikasi.
4. Jangan mempercayai user ID, NIM, atau role yang dikirim melalui request body.
5. Mahasiswa hanya dapat mengakses mata kuliah dan tugas yang memang menjadi haknya.
6. Dosen hanya dapat mengakses data yang berkaitan dengan kewenangannya.
7. Semua query database menggunakan parameterized query.
8. Semua input harus divalidasi di backend.
9. Password wajib di-hash menggunakan Argon2id.
10. Token wajib dapat dicabut ketika logout.
11. File pengumpulan tugas harus melalui validasi tipe dan ukuran.
12. IPK tidak boleh dapat diubah oleh mahasiswa.
13. Semua perubahan data penting sebaiknya dicatat dalam audit log.

Prinsip utamanya:

**Jangan pernah mengandalkan validasi di frontend sebagai satu-satunya lapisan keamanan.**

Contohnya, menyembunyikan tombol untuk melihat data mahasiswa lain tidak cukup. Backend tetap harus menolak request yang mencoba mengakses data tersebut.

---

# 12. Batasan MVP (Out of Scope)

Fitur berikut belum termasuk dalam pengembangan saat ini:

- Registrasi mandiri.
- Pengumpulan dan pengisian KRS.
- Pembayaran UKT.
- Chat dosen dan mahasiswa.
- Dashboard admin di mobile.
- Pengelolaan akun admin melalui aplikasi.
- Mode offline.
- Perhitungan IPK otomatis.
- Pengolahan nilai otomatis.
- Pemilihan mata kuliah secara mandiri oleh mahasiswa.

Pengelolaan data akademik masih dilakukan oleh programmer melalui database.

---

# 13. Deployment dan Environment

Untuk tahap demonstrasi:
- Backend berjalan secara lokal.
- PostgreSQL berjalan secara lokal.
- Flutter dijalankan pada emulator atau perangkat Android.
- Komunikasi aplikasi dan backend menggunakan REST API.
- Tidak memerlukan hosting publik.

Perlu diperhatikan bahwa jika Flutter dijalankan melalui perangkat fisik, `localhost` pada perangkat bukanlah komputer tempat backend berjalan. Gunakan alamat IP lokal komputer sebagai base URL API.

Contoh:

```text
http://192.168.1.10:3000/api
```

Alamat tersebut hanya contoh dan harus disesuaikan dengan jaringan lokal.

---

# 14. Prioritas Pengembangan

Agar pengembangan tidak terlalu luas, pengerjaan dibagi menjadi beberapa fase.

### Phase 1 — Foundation
- Membuat struktur monorepo.
- Menyiapkan Flutter.
- Menyiapkan Express.js.
- Menghubungkan PostgreSQL.
- Membuat desain database.
- Menyiapkan dokumentasi API.

### Phase 2 — Authentication & Security
- Login mahasiswa dan dosen.
- JWT authentication.
- Session management.
- Logout dan token revocation.
- Password hashing Argon2id.
- Change password.
- Forgot password.
- Force password change.
- Middleware authorization.

### Phase 3 — Student Module
- Student Home.
- Daftar mata kuliah.
- Detail mata kuliah.
- Daftar tugas.
- Pengumpulan tugas.
- Profile.
- Riwayat perubahan password.

### Phase 4 — Lecturer Module
- Lecturer Home.
- Daftar mata kuliah yang diampu.
- Profile.
- Pengelolaan tugas sesuai kewenangan dosen.

### Phase 5 — Biometric Security
- Integrasi native biometric.
- Pemeriksaan dukungan Face Recognition.
- Aktivasi biometric.
- Penonaktifan biometric.
- Penyimpanan sesi secara aman.

### Phase 6 — Testing & Security Validation
- Pengujian login.
- Pengujian JWT.
- Pengujian token revocation.
- Pengujian role authorization.
- Pengujian akses data antar mahasiswa.
- Pengujian akses data dosen.
- Pengujian upload tugas.
- Pengujian password hashing.
- Pengujian backup dan restore.

---

# 15. Prinsip Pengembangan

Seluruh pengembangan SISDIK harus mengikuti prinsip berikut:

1. **Security First:** keamanan harus menjadi bagian dari arsitektur sejak awal.
2. **Backend as the Source of Truth:** backend menjadi sumber kebenaran untuk seluruh data dan otorisasi.
3. **Separation of Concerns:** Flutter dan Express.js memiliki tanggung jawab yang terpisah.
4. **Modular Architecture:** setiap fitur dikembangkan dalam modul yang terstruktur.
5. **Minimalist UI:** tidak menambahkan komponen visual yang tidak memiliki fungsi jelas.
6. **MVP First:** tidak menambahkan fitur di luar ruang lingkup tanpa persetujuan.
7. **Documentation:** setiap modul penting memiliki dokumentasi yang relevan.

**Hasil akhir yang diharapkan:** aplikasi mobile SISDIK yang dapat digunakan oleh mahasiswa dan dosen untuk mengakses informasi akademik dasar, melihat dan mengumpulkan tugas, serta menerapkan autentikasi dan mekanisme keamanan yang sesuai dengan kebutuhan demonstrasi proyek.