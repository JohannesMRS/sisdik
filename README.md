# SISDIK

SISDIK adalah MVP aplikasi mobile sistem informasi akademik berbasis Flutter, Express.js, dan PostgreSQL.

## Prasyarat

- Node.js LTS
- PostgreSQL dan `psql`
- Flutter stable beserta Android SDK
- JDK 17
- Kabel USB untuk perangkat Android fisik

## 1. Database

Buat dua database lokal:

```bash
psql -U postgres -c "CREATE DATABASE sisdik;"
psql -U postgres -c "CREATE DATABASE sisdik_test;"
```

## 2. Backend

```bash
cd backend-api
npm install
cp .env.example .env
```

Isi `backend-api/.env`:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgres://postgres:PASSWORD@localhost:5432/sisdik
JWT_SECRET=rahasia-acak-minimal-32-karakter
LOGIN_RATE_LIMIT_ENABLED=false
```

Jika password PostgreSQL mengandung karakter khusus, URL-encode sebelum dipakai.

Jalankan migrasi:

```bash
npm run migrate:up
npm run dev
```

Cek server:

```bash
curl http://localhost:3000/api/v1/health
```

Respons sehat:

```json
{"data":{"status":"ok","db":"up"}}
```

Untuk database uji, timpa URL hanya untuk proses migrasi:

```bash
DATABASE_URL=postgres://postgres:PASSWORD@localhost:5432/sisdik_test npm run migrate:up
```

Jangan jalankan operasi data seperti migrasi atau seed sebelum memastikan database target benar.

## 3. Membuat akun

Password awal di-hash Argon2id dan akun dibuat dengan `must_change_password=true`:

```bash
npm run create-user -- --role=student --identifier=2301001 --name="Budi Mahasiswa" --password=Awal12345
npm run create-user -- --role=lecturer --identifier=19800101 --name="Dosen Demo" --password=Awal12345
```

Import CSV:

```bash
npm run import-users -- users.csv
```

Format CSV:

```csv
role,identifier,name,password
student,2301002,Siti Mahasiswa,Awal12345
lecturer,19800102,Dosen Dua,Awal12345
```

## 4. Flutter

```bash
cd mobile_app
flutter pub get
flutter test
flutter run --dart-define=API_URL=http://localhost:3000/api/v1
```

## 5. Perangkat Android fisik

1. Aktifkan USB debugging.
2. Sambungkan perangkat dan pastikan muncul pada `adb devices`.
3. Jalankan backend, lalu:

```bash
adb reverse tcp:3000 tcp:3000
```

4. Jalankan aplikasi:

```bash
cd mobile_app
flutter run --dart-define=API_URL=http://localhost:3000/api/v1
```

Untuk WiFi tanpa adb reverse, pakai alamat IP laptop pada jaringan yang sama:

```bash
flutter run --dart-define=API_URL=http://192.168.1.10:3000/api/v1
```

## Pengujian

```bash
cd backend-api
npm test

cd ../mobile_app
flutter analyze
flutter test
```