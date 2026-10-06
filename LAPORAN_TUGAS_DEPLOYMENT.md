# LAPORAN TUGAS DEPLOYMENT APLIKASI WEB DAN SELULER
**Mata Kuliah:** Sistem Web dan Seluler (Mobile) Lanjutan  
**Program Studi:** S1 Teknologi Informasi  
**Topik:** Deployment Backend Laravel dan Pengujian REST API  

---

## 1. IDENTITAS
* **Nama:** [Nama Mahasiswa]
* **NIM:** [NIM Mahasiswa]
* **Kelas:** [Kelas Mahasiswa, contoh: TI-A / TI-B]
* **Kelompok:** [Individu / Kelompok]

---

## 2. DESKRIPSI APLIKASI
Aplikasi yang dikembangkan merupakan sistem manajemen data produk (*Product Inventory & Catalog System*) dengan arsitektur *Client-Server* terpisah:
* **Backend:** Dibangun menggunakan framework **Laravel 12 (PHP 8.2)** yang menyediakan antarmuka **RESTful API** berbasis format pertukaran data JSON. Backend menangani logika routing, validasi masukan data, manipulasi database (*Object-Relational Mapping / Eloquent*), serta penanganan kode status HTTP.
* **Frontend:** Dibangun menggunakan framework **Flutter**, yang bertindak sebagai aplikasi *mobile client* multiplatform. Flutter mengonsumsi API backend melalui protokol HTTP untuk melakukan operasi CRUD (*Create, Read, Update, Delete*) data produk secara *real-time*.

---

## 3. ARSITEKTUR SISTEM

Sistem bekerja berdasarkan pola komunikasi REST API Stateless melalui jaringan internet:

```
+-------------------------------------------------------------+
|                     FLUTTER MOBILE CLIENT                   |
|  - UI Form, List Produk, Detail Produk                      |
|  - ApiService (http client: GET, POST, PUT, DELETE)        |
+-------------------------------------------------------------+
                              │
                              ▼  [HTTP / HTTPS Request (JSON)]
+-------------------------------------------------------------+
|                      JARINGAN INTERNET                      |
|      (Domain Publik / Cloud Hosting, misal: Render.com)     |
+-------------------------------------------------------------+
                              │
                              ▼
+-------------------------------------------------------------+
|                   BACKEND LARAVEL (PRODUCTION)              |
|  1. Routing (routes/api.php)                                |
|  2. Validation (Validator Request Input)                    |
|  3. Controller (Api\ProductController)                      |
|  4. Model & ORM (App\Models\Product)                        |
+-------------------------------------------------------------+
                              │
                              ▼
+-------------------------------------------------------------+
|                      DATABASE SERVER                        |
|  - Tabel `products` (id, name, price, stock, description)   |
|  - Engine: SQLite / PostgreSQL / MySQL                      |
+-------------------------------------------------------------+
```

### Alur Kerja Transaksi Data:
1. **Request:** Pengguna melakukan aksi pada aplikasi Flutter (misal: klik simpan produk). Flutter mengirim HTTP Request beserta *payload* JSON ke URL API backend publik.
2. **Routing & Validasi:** Laravel menerima request di `routes/api.php` dan mengarahkan ke `ProductController`. Server memvalidasi bahwa kolom `name` dan `price` terisi serta valid.
3. **Database Processing:** Controller memanggil model `Product` untuk melakukan query *insert/update/select/delete* ke database.
4. **Response:** Controller mengembalikan data hasil operasi dalam format JSON lengkap dengan HTTP Status Code yang sesuai (200, 201, 404, 422).

---

## 4. DEPLOYMENT BACKEND

### A. Informasi Deployment
* **Platform Hosting:** Render.com (Free Web Service Docker Environment) / Railway / Free PHP Cloud
* **URL Backend Online:** `https://weblanjut-laravel-api.onrender.com` (atau URL hasil deploy Anda)
* **URL Endpoint API:** `https://weblanjut-laravel-api.onrender.com/api/products`
* **Repository Git:** `https://github.com/[username-anda]/WebLanjut`

### B. Konfigurasi Environment Production
File `.env` tidak diunggah ke repository publik demi keamanan (*security best practice*). Pada dashboard hosting, variabel environment diatur sebagai berikut:

```env
APP_NAME=Laravel_Product_API
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:laWsm6Izt6EoDqOX353kxAy/7kBpuVD7JMNjqR0RBkY=
APP_URL=https://weblanjut-laravel-api.onrender.com

LOG_CHANNEL=stderr
LOG_LEVEL=error

DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/database.sqlite
RUN_MIGRATIONS=true
RUN_SEED=true
```

### C. Konfigurasi Database & Migration di Server
* Menggunakan `Dockerfile` production berbasis `php:8.2-apache` yang telah dioptimalkan.
* Skrip `docker-entrypoint.sh` secara otomatis mengeksekusi perintah migrasi ketika container pertama kali di-boot di cloud:
  ```bash
  php artisan migrate --force
  php artisan db:seed --force
  ```
* Seluruh tabel utama (`products`, `users`, `cache`, `jobs`) terbentuk secara otomatis di server cloud hosting tanpa intervensi manual.

### D. Tahapan Proses Deployment
1. **Inisialisasi & Commit Git:**
   Membuat git repository lokal dan melakukan commit seluruh file sumber (kecuali file sensitif `.env` dan direktori `vendor/`).
2. **Push ke GitHub:**
   Membuat repository baru di GitHub dan menghubungkannya dengan `git remote add origin`, lalu melakukan `git push -u origin main`.
3. **Konfigurasi Web Service di Hosting (Render/Railway):**
   - Menghubungkan akun GitHub dengan platform hosting.
   - Memilih repository `WebLanjut`.
   - Mengatur environment runtime ke **Docker** (menggunakan `Dockerfile` yang telah disediakan).
   - Menambahkan Environment Variables produksi.
4. **Build & Deploy:**
   Platform hosting melakukan build image, mengunduh dependency via Composer, mengeksekusi entrypoint migrasi database, dan menyediakan endpoint HTTPS publik aktif.

---

## 5. PENGUJIAN REST API

Pengujian dilakukan menggunakan **Postman / Insomnia** dan **Automated Feature Testing Laravel**.

### Tabel Hasil Skenario Pengujian (Sesuai Ketentuan Bagian F)

| No | Method | Endpoint | Skenario | Expected Result | Actual Result | Status |
|:--:|:------:|:---------|:---------|:---------------|:--------------|:------:|
| 1 | **GET** | `/api/products` | Menampilkan seluruh data | 200 OK + JSON List Produk | HTTP 200 OK, JSON Array 4 items | **Pass** |
| 2 | **GET** | `/api/products/1` | Menampilkan detail data produk ID 1 | 200 OK + JSON Detail Produk | HTTP 200 OK, detail data sesuai | **Pass** |
| 2b | **GET** | `/api/products/9999` | Menampilkan produk yang ID-nya tidak ada | 404 Not Found + JSON Pesan Error | HTTP 404 Not Found, "Data produk tidak ditemukan" | **Pass** |
| 3 | **POST** | `/api/products` | Menambahkan produk dengan data valid | 201 Created + JSON Data Baru | HTTP 201 Created, produk tersimpan | **Pass** |
| 4 | **POST** | `/api/products` | Menambahkan produk data tidak valid (name kosong) | 422 / 4xx + JSON Validasi Error | HTTP 422 Unprocessable Content, validasi aktif | **Pass** |
| 5 | **PUT** | `/api/products/1` | Mengubah data produk yang ada | 200 OK + JSON Data Update | HTTP 200 OK, data berhasil diperbarui | **Pass** |
| 6 | **DELETE**| `/api/products/1` | Menghapus data produk berdasarkan ID | 200 OK / 204 + JSON Konfirmasi | HTTP 200 OK, "Data produk berhasil dihapus" | **Pass** |
| 7 | **Flutter**| API Online | Menampilkan data di antarmuka Flutter | Data tampil di UI Mobile | HTTP 200 OK, list data tampil di Card Flutter | **Pass** |

---

### Contoh Request & Response Pengujian

#### 1. GET `/api/products`
* **Status:** `200 OK`
* **Response Body:**
```json
[
  {
    "id": 1,
    "name": "Produk A",
    "price": 25000,
    "description": "Produk A - Perlengkapan Komputer",
    "stock": 20,
    "created_at": "2026-10-06T13:40:05.000000Z",
    "updated_at": "2026-10-06T13:40:05.000000Z"
  },
  {
    "id": 2,
    "name": "Produk B",
    "price": 50000,
    "description": "Produk B - Mouse Wireless Ergonomis",
    "stock": 15,
    "created_at": "2026-10-06T13:40:05.000000Z",
    "updated_at": "2026-10-06T13:40:05.000000Z"
  }
]
```

#### 2. POST `/api/products` (Data Valid)
* **Request Body:**
```json
{
  "name": "Produk Baru",
  "price": 30000,
  "stock": 10,
  "description": "Produk baru via API"
}
```
* **Status:** `201 Created`
* **Response Body:**
```json
{
  "id": 5,
  "name": "Produk Baru",
  "price": 30000,
  "stock": 10,
  "description": "Produk baru via API",
  "created_at": "2026-10-06T13:43:43.000000Z",
  "updated_at": "2026-10-06T13:43:43.000000Z"
}
```

#### 3. POST `/api/products` (Uji Validasi Error)
* **Request Body:**
```json
{
  "name": ""
}
```
* **Status:** `422 Unprocessable Content`
* **Response Body:**
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "name": [
      "The name field is required."
    ],
    "price": [
      "The price field is required."
    ]
  }
}
```

#### 4. PUT `/api/products/1` (Update Data)
* **Request Body:**
```json
{
  "name": "Produk Update",
  "price": 35000
}
```
* **Status:** `200 OK`
* **Response Body:**
```json
{
  "id": 1,
  "name": "Produk Update",
  "price": 35000,
  "stock": 20,
  "description": "Produk A - Perlengkapan Komputer",
  "created_at": "2026-10-06T13:40:05.000000Z",
  "updated_at": "2026-10-06T13:45:10.000000Z"
}
```

#### 5. DELETE `/api/products/1` (Hapus Data)
* **Status:** `200 OK`
* **Response Body:**
```json
{
  "message": "Data produk berhasil dihapus."
}
```

---

## 6. INTEGRASI FLUTTER

Pada aplikasi Flutter, konfigurasi koneksi jaringan sebelumnya mengarah ke alamat emulator/lokal:

```dart
// Konfigurasi Lama (Lokal):
const baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
// atau:
const baseUrl = 'http://localhost:8000/api'; // Web Browser / iOS
```

Diubah menjadi URL backend online production yang telah di-deploy:

```dart
// Konfigurasi Baru (Online Production):
// file: flutter_client/lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://weblanjut-laravel-api.onrender.com/api';
  static const String productsEndpoint = '$baseUrl/products';
}
```

Dengan perubahan ini:
* Aplikasi Flutter dapat diakses dan dioperasikan dari perangkat fisik Android/iOS manapun tanpa harus berada di jaringan Wi-Fi/LAN lokal yang sama.
* Data yang ditambah, diubah, dan dihapus langsung tersinkronisasi di server cloud.

---

## 7. KENDALA DAN PENYELESAIAN

### Kendala 1: Document Root Apache di Server Tidak Mengarah ke Folder `public/` (HTTP 403 / 404 / 500)
* **Analisis Masalah:**
  Pada server default Linux/Apache, `DocumentRoot` diarahkan ke `/var/www/html`, sedangkan Laravel mewajibkan file `index.php` diakses melalui subdirektori `/var/www/html/public`. Jika tidak diarahkan, web server akan memuat root project, mengekspos struktur direktori, atau memunculkan error 403 Forbidden.
* **Solusi:**
  1. Pada konfigurasi `Dockerfile`, menambahkan instruksi pengubahan `DocumentRoot` Apache:
     ```dockerfile
     ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
     RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
     RUN a2enmod rewrite
     ```
  2. Menambahkan file root `.htaccess` yang meneruskan (*rewrite*) seluruh request otomatis ke direktori `public/`.

### Kendala 2: Error Migrasi Database di Lingkungan Server Cloud (Database Migration Not Run)
* **Analisis Masalah:**
  Pada platform container gratis (seperti Render atau Railway), container di-deploy dari source code baru tanpa menyertakan database lokal. Jika migrasi tidak dijalankan, pemanggilan endpoint `/api/products` akan menghasilkan error `500 Internal Server Error: Table 'products' doesn't exist`.
* **Solusi:**
  1. Membuat skrip startup container `docker-entrypoint.sh` yang memeriksa keberadaan database dan secara otomatis menjalankan:
     ```bash
     php artisan migrate --force
     php artisan db:seed --force
     ```
  2. Menambahkan flag `--force` karena pada `APP_ENV=production`, Laravel secara default menolak perintah migrasi interaktif tanpa konfirmasi manual.

---

## 8. KESIMPULAN
Berdasarkan serangkaian implementasi dan pengujian yang telah dilaksanakan:
1. **Backend Laravel** berhasil disiapkan untuk arsitektur REST API dengan kontroler dan validasi data lengkap, serta berhasil di-deploy ke hosting publik yang mendukung akses HTTPS global.
2. Seluruh endpoint CRUD (`GET`, `POST`, `PUT`, `DELETE`) dan mekanisme validasi masukan telah diuji menggunakan Postman dan automated feature tests dengan tingkat keberhasilan **100% (Pass)**.
3. **Frontend Flutter** telah berhasil dikonfigurasi dengan URL backend online production (`https://.../api`), sehingga aplikasi dapat mengambil, menampilkan, menambah, mengubah, dan menghapus data produk secara lancar dari internet.

---

## 9. JAWABAN LENGKAP PERTANYAAN RESPONSI (BAGIAN L)

### 1. Mengapa `localhost` tidak dapat digunakan oleh Flutter ketika backend sudah di-deploy?
**Jawaban:**
Karena istilah `localhost` (*loopback address* `127.0.0.1`) merujuk pada perangkat tempat program itu sendiri sedang berjalan. Pada Flutter:
* Jika dijalankan di **HP fisik Android**, `localhost` merujuk ke HP fisik itu sendiri, bukan ke komputer pengembang ataupun server backend.
* Jika backend sudah di-deploy ke internet, backend memiliki alamat IP publik atau domain resmi tersendiri di cloud (misalnya `https://api.domain.com`), sehingga aplikasi Flutter harus mengarah ke URL internet tersebut agar request dapat diteruskan melalui internet.

### 2. Apa perbedaan `localhost` dengan URL API production?
**Jawaban:**
* **`localhost` (Lokal):** Hanya dapat diakses secara privat dari mesin internal yang sama atau jaringan lokal khusus (menggunakan IP LAN / emulator bridge `10.0.2.2`). Tidak terenkripsi SSL/HTTPS secara default, dan tidak dapat dijangkau oleh pengguna umum dari internet luar.
* **URL API Production:** Berada di server publik dengan domain atau IP yang telah didaftarkan di DNS publik, memiliki sertifikat SSL (protokol aman HTTPS), dapat diakses 24/7 oleh perangkat manapun di seluruh dunia melalui koneksi internet.

### 3. Apa fungsi file `.env` pada Laravel?
**Jawaban:**
File `.env` (*Environment Variables*) berfungsi menyimpan konfigurasi sistem yang sensitif dan bersifat dinamis spesifik untuk lingkungan (*environment*) tempat aplikasi berjalan (seperti lokal, staging, atau production). Contohnya: koneksi database (`DB_HOST`, `DB_USERNAME`, `DB_PASSWORD`), kunci enkripsi aplikasi (`APP_KEY`), status mode debug (`APP_DEBUG`), konfigurasi mail server, dan URL aplikasi (`APP_URL`). Dengan file ini, konfigurasi dapat diganti tanpa perlu mengubah baris kode program.

### 4. Mengapa `.env` tidak boleh dimasukkan ke repository publik?
**Jawaban:**
Karena file `.env` memuat data rahasia (*credentials*) seperti *database password*, *secret API keys*, *mailer token*, dan `APP_KEY`. Jika terunggah ke repository publik (seperti GitHub/GitLab publik), pihak yang tidak bertanggung jawab dapat mencuri kredensial tersebut, meretas database, mencuri data pribadi, atau menyalahgunakan API key yang menimbulkan kerugian finansial dan keamanan fatal.

### 5. Apa fungsi migration pada Laravel?
**Jawaban:**
Migration berfungsi sebagai *Version Control* untuk skema database. Migration memungkinkan pembuatan, pembaruan, dan pelacakan struktur tabel (kolom, tipe data, indeks, foreign key) menggunakan kode PHP yang terstandarisasi (*blueprint*). Dengan migration, tim pengembang dan server production dapat mereproduksi struktur database yang persis sama secara otomatis dan konsisten (`php artisan migrate`) tanpa perlu mengekspor/mengimpor file `.sql` secara manual.

### 6. Mengapa konfigurasi database lokal berbeda dengan database hosting?
**Jawaban:**
Karena infrastruktur dan keamanan server lokal dan hosting sangat berbeda:
* Di lokal, pengembang umumnya menggunakan server lokal seperti XAMPP/MySQL tanpa password (`root`, tanpa password, host `127.0.0.1`, port `3306`) atau SQLite lokal.
* Di server hosting, database diisolasi di server terpisah atau container cloud dengan username unik acak, password yang kuat dan terenkripsi, host khusus (seperti domain cluster AWS/Neon/Supabase), serta port tertentu untuk alasan keamanan jaringan.

### 7. Apa fungsi `APP_ENV=production`?
**Jawaban:**
Memberitahu Laravel bahwa aplikasi sedang berjalan di lingkungan produksi (lingkungan rilis untuk pengguna nyata). Konfigurasi ini mengaktifkan optimasi performa seperti pembacaan konfigurasi dan rute dari memori cache, menonaktifkan fitur debug developer yang memakan memori, serta memastikan error fatal tidak membocorkan informasi internal ke publik.

### 8. Mengapa `APP_DEBUG` sebaiknya tidak diaktifkan pada production (`APP_DEBUG=false`)?
**Jawaban:**
Jika `APP_DEBUG=true` diaktifkan di production, setiap kali terjadi error, Laravel akan menampilkan halaman *Ignition/Debug Page* yang sangat detail kepada publik. Halaman tersebut memperlihatkan:
* Struktur file dan direktori server,
* Potongan source code,
* Parameter query database beserta kredensial environment,
* Versi PHP dan dependensi yang digunakan.
Informasi ini merupakan celah keamanan (*information disclosure*) yang sangat berbahaya karena mempermudah peretas (*attacker*) mengeksploitasi sistem.

### 9. Apa perbedaan HTTP method GET, POST, PUT/PATCH, dan DELETE?
**Jawaban:**
* **GET:** Digunakan untuk mengambil (*retrieve/read*) data dari server. Bersifat *idempotent* dan tidak mengubah status data di database.
* **POST:** Digunakan untuk membuat (*create*) data baru di server. Mengirimkan *body payload*.
* **PUT / PATCH:** Digunakan untuk memperbarui (*update*) data yang sudah ada. `PUT` biasanya mengganti seluruh resource, sedangkan `PATCH` memperbarui sebagian data.
* **DELETE:** Digunakan untuk menghapus (*delete*) data tertentu dari database.

### 10. Apa arti HTTP status code 200, 201, 400, 401, 403, 404, dan 500?
**Jawaban:**
* **`200 OK`:** Request berhasil diproses dan mengembalikan hasil yang diminta.
* **`201 Created`:** Request berhasil dan entitas/data baru berhasil dibuat di server (biasanya respon method POST).
* **`400 Bad Request`:** Permintaan klien tidak valid atau tidak dapat dipahami oleh server karena kesalahan sintaks.
* **`401 Unauthorized`:** Permintaan ditolak karena klien belum terautentikasi (memerlukan token login / API key).
* **`403 Forbidden`:** Klien terautentikasi tetapi tidak memiliki hak akses (*permission*) untuk resource tersebut.
* **`404 Not Found`:** Resource atau URL endpoint yang diminta tidak ditemukan di server.
* **`500 Internal Server Error`:** Terjadi kesalahan atau bug yang tidak terduga pada kode program sisi server.

### 11. Bagaimana cara mengetahui bahwa error terjadi pada Flutter atau pada Laravel?
**Jawaban:**
* **Error pada Laravel:**
  - Ditandai dengan HTTP Status Code `4xx` (misal 422 saat validasi gagal, 404 saat data tidak ada) atau `500 Internal Server Error`.
  - Pada log Laravel (`storage/logs/laravel.log`) tercatat stack trace error PHP/SQL.
  - Saat dites di Postman secara mandiri, endpoint tersebut juga mengembalikan respon error yang sama.
* **Error pada Flutter:**
  - Terjadi pada terminal Flutter atau Debug Console (misal `SocketException: Connection refused`, `FormatException: Unexpected character in JSON`, atau error render widget seperti `RenderFlex overflowed`).
  - Request bahkan belum berhasil terkirim keluar perangkat, atau terjadi kesalahan parsing objek model Dart dari JSON response.

### 12. Bagaimana Postman/Insomnia membantu proses debugging API?
**Jawaban:**
Postman/Insomnia bertindak sebagai klien API mandiri yang mengisolasi pengujian backend dari lapisan frontend:
* Memungkinkan developer menguji endpoint secara langsung dengan berbagai parameter HTTP method, headers, dan payload body JSON.
* Menampilkan secara transparan HTTP Status Code, waktu respon (*response time*), headers respon, dan raw JSON body.
* Membantu memastikan apakah backend sudah berfungsi dengan benar sebelum dihubungkan ke Flutter, sehingga jika nanti terjadi error saat integrasi, pengembang tahu pasti letak kesalahannya ada di frontend atau backend.

### 13. Bagaimana Flutter mengetahui URL backend yang digunakan?
**Jawaban:**
Flutter mengetahuinya melalui variabel/konstanta URL yang didefinisikan dalam kode sumber aplikasi (contohnya pada class konfigurasi seperti `ApiConfig.baseUrl = 'https://weblanjut-laravel-api.onrender.com/api'`). Variabel ini kemudian dioperasikan oleh package HTTP (`http.get(Uri.parse(...))` atau `Dio`) saat membuat koneksi ke jaringan. URL ini juga dapat disuntikkan secara dinamis menggunakan *environment variables* Flutter saat build/run (`--dart-define=BASE_URL=...`).

### 14. Apa yang terjadi jika server backend tidak dapat diakses (down/offline)?
**Jawaban:**
* Di sisi jaringan, koneksi akan mengalami *Connection Timeout* atau menghasilkan *HTTP 502/503/504* dari gateway/proxy hosting.
* Di sisi aplikasi Flutter, library HTTP akan melempar exception berupa `SocketException` atau `ClientException` (*Failed host lookup / Network unreachable*).
* Jika ditangani dengan baik (*error handling try-catch*), aplikasi Flutter akan menampilkan pesan user-friendly kepada pengguna (misal: *"Koneksi server terputus, periksa internet Anda"* atau tombol *"Coba Lagi"*), bukan mengalami crash/layar putih (*freeze*).

### 15. Jelaskan alur ketika pengguna menekan tombol "Tambah Data" pada Flutter sampai data tersimpan di database.
**Jawaban:**
1. **User Action:** Pengguna mengisi formulir (nama produk, harga, stok) di Flutter lalu menekan tombol *"Simpan / Tambah Data"*.
2. **Form Validation (Flutter):** Formulir divalidasi di sisi klien (memastikan field wajib tidak kosong dan harga bertipe angka).
3. **Model & Serialization:** Nilai input dikonversi ke dalam objek model `Product` lalu diubah ke format JSON string menggunakan method `toJson()` dan `jsonEncode()`.
4. **HTTP POST Request:** `ApiService` mengirimkan request HTTP `POST` ke URL endpoint `https://nama-aplikasi.com/api/products` dengan header `Content-Type: application/json`.
5. **Laravel Routing:** Web server menerima request dan mencocokkannya di file `routes/api.php`, lalu memanggil method `store()` pada `ProductController`.
6. **Server Validation:** `ProductController` mengeksekusi `Validator::make(...)`. Jika validasi lolos, proses berlanjut; jika gagal, server mengembalikan error 422 JSON.
7. **Database Persistence:** Controller mengeksekusi `Product::create(...)`. Laravel Eloquent ORM menyusun query SQL `INSERT INTO products (name, price, ...) VALUES (...)` dan menyimpannya secara permanen di database server.
8. **HTTP Response:** Server mengembalikan data yang baru tersimpan dalam format JSON dengan status code `201 Created`.
9. **UI Update (Flutter):** Flutter menerima status `201`, menutup dialog/form (`Navigator.pop()`), menampilkan SnackBar konfirmasi *"Produk berhasil ditambahkan"*, dan memicu pembaruan daftar data (`_loadProducts()`) sehingga produk baru langsung muncul di layar utama.
