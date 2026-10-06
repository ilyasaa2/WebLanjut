# PANDUAN LANGKAH DEPLOYMENT DAN PENGUMPULAN TUGAS

Panduan ini berisi langkah-langkah praktis untuk menyelesaikan seluruh target tugas: membuat repository GitHub, deploy ke cloud hosting gratis, menguji di Postman, menjalankan Flutter, dan mengumpulkan berkas.

---

## TAHAP 1: Push Project ke GitHub

Project di folder ini sudah diinisialisasi git dan memiliki commit awal yang lengkap. Anda hanya perlu menghubungkannya ke akun GitHub Anda:

1. Buka [github.com/new](https://github.com/new) di browser Anda.
2. Beri nama repository, misalnya: `WebLanjut-Laravel-API` atau `WebLanjut`.
3. Pilih **Public** (agar dapat diakses saat dinilai oleh dosen).
4. **Jangan** centang *"Add a README file"*, *"Add .gitignore"*, atau license (karena sudah ada di lokal).
5. Klik **Create repository**.
6. Salin URL repository Anda, lalu jalankan dua perintah ini di terminal / PowerShell:
   ```powershell
   git remote add origin https://github.com/USERNAME-ANDA/WebLanjut.git
   git push -u origin main
   ```
   *(Ganti `USERNAME-ANDA` dengan username GitHub Anda)*

---

## TAHAP 2: Deploy ke Hosting Gratis (Render.com - Rekomendasi)

Render menyediakan Web Service gratis yang sangat cocok untuk Docker Laravel.

1. Buka [render.com](https://render.com) dan login (bisa langsung login menggunakan akun GitHub).
2. Di dashboard Render, klik tombol **New +** > pilih **Web Service**.
3. Pilih opsi **Build and deploy from a Git repository** > klik **Next**.
4. Cari dan pilih repository `WebLanjut` Anda yang baru saja di-push.
5. Isi formulir konfigurasi berikut:
   * **Name:** `weblanjut-laravel-api` (atau nama unik yang Anda inginkan)
   * **Region:** `Singapore (Southeast Asia)` (paling cepat untuk Indonesia)
   * **Branch:** `main`
   * **Runtime:** Pilih **Docker** (Render akan otomatis mendeteksi `Dockerfile` yang sudah kami sediakan)
   * **Instance Type:** Pilih **Free**
6. Di bagian **Environment Variables**, klik **Add Environment Variable** dan masukkan:
   * `APP_NAME` : `Laravel_Product_API`
   * `APP_ENV` : `production`
   * `APP_DEBUG` : `false`
   * `APP_KEY` : `base64:laWsm6Izt6EoDqOX353kxAy/7kBpuVD7JMNjqR0RBkY=`
   * `DB_CONNECTION` : `sqlite`
   * `DB_DATABASE` : `/var/www/html/database/database.sqlite`
   * `RUN_MIGRATIONS` : `true`
   * `RUN_SEED` : `true`
7. Klik **Create Web Service**.
8. Tunggu proses build (sekitar 2–3 menit). Setelah status berubah menjadi **Live**, Anda akan mendapatkan URL publik, contohnya:
   `https://weblanjut-laravel-api.onrender.com`
9. Buka URL tersebut di browser dengan menambahkan `/api/products`:
   `https://weblanjut-laravel-api.onrender.com/api/products`
   Jika muncul data JSON produk, **selamat! Backend Anda sudah 100% online di internet!**

---

## TAHAP 3: Pengujian di Postman / Insomnia & Pengambilan Screenshot

File koleksi Postman sudah disiapkan: `postman_collection.json`.

1. Buka aplikasi **Postman** (atau Insomnia).
2. Klik tombol **Import** di pojok kiri atas, lalu pilih file:
   `C:\xampp\htdocs\WebLanjut\postman_collection.json`
3. Di dalam Postman, klik koleksi **Tugas Deployment Web & Seluler - Product REST API**:
   - Buka tab **Variables**.
   - Ubah nilai `base_url` dari `http://127.0.0.1:8000` menjadi URL hosting Anda, contoh:
     `https://weblanjut-laravel-api.onrender.com`
   - Klik **Save** (`Ctrl + S`).
4. Jalankan setiap request dan ambil screenshot layar Postman Anda (pastikan URL, Method, Status Code, dan JSON Body terlihat jelas):
   - **Screenshot 1:** Request `1. GET - Menampilkan Seluruh Data Produk` (Status: 200 OK)
   - **Screenshot 2:** Request `2. GET - Menampilkan Detail Data Produk (ID: 1)` (Status: 200 OK)
   - **Screenshot 3:** Request `3. POST - Menambahkan Data Produk (Valid)` (Status: 201 Created)
   - **Screenshot 4:** Request `4. POST - Validasi Data (Data Kosong)` (Status: 422 Unprocessable Content)
   - **Screenshot 5:** Request `5. PUT - Mengubah Data Produk (ID: 1)` (Status: 200 OK)
   - **Screenshot 6:** Request `6. DELETE - Menghapus Data Produk` (Status: 200 OK)

---

## TAHAP 4: Menjalankan & Menguji Aplikasi Flutter

Kode aplikasi Flutter lengkap sudah berada di folder:
`C:\xampp\htdocs\WebLanjut\flutter_client\`

1. Buka file `flutter_client/lib/config/api_config.dart`.
2. Pastikan `baseUrl` telah sesuai dengan URL online hosting Anda:
   ```dart
   static const String baseUrl = 'https://weblanjut-laravel-api.onrender.com/api';
   ```
3. Buka folder `flutter_client` di terminal / Android Studio / VS Code, lalu jalankan:
   ```bash
   flutter pub get
   flutter run
   ```
   *(Bisa dijalankan di Chrome, Android Emulator, atau HP Fisik)*
4. Aplikasi akan menampilkan daftar produk langsung dari server cloud hosting.
5. Lakukan pengujian di Flutter:
   - Tambah produk baru melalui tombol floating action button (+).
   - Ubah produk melalui menu titik tiga > "Ubah Data".
   - Hapus produk melalui menu titik tiga > "Hapus Data".
6. Ambil screenshot antarmuka Flutter yang memperlihatkan data berhasil dimuat dari server online.

---

## TAHAP 5: Checklist Bukti yang Wajib Dikumpulkan (Bagian G & M)

Pastikan seluruh berkas berikut telah siap sebelum dikumpulkan ke dosen:

- [ ] **1. Link Repository:** URL GitHub / GitLab (contoh: `https://github.com/username/WebLanjut`)
- [ ] **2. URL Backend / API:** URL online aktif (contoh: `https://weblanjut-laravel-api.onrender.com/api/products`)
- [ ] **3. Screenshot Deployment:** Tangkapan layar dashboard Render/Railway berstatus *Live / Deployed*.
- [ ] **4. Screenshot Postman:** 6 tangkapan layar (GET list, GET detail, POST valid, POST invalid 422, PUT update, DELETE).
- [ ] **5. Screenshot Database:** Tangkapan layar tabel database / log seeder di dashboard server.
- [ ] **6. Screenshot Flutter:** Tangkapan layar aplikasi Flutter memuat data dari internet.
- [ ] **7. Laporan PDF:** File `LAPORAN_TUGAS_DEPLOYMENT.md` yang telah diisi identitas dan diekspor ke format PDF.
- [ ] **8. Video Demonstrasi (Durasi 5–10 Menit):**
  - Alur video:
    1. Buka aplikasi Flutter dan perlihatkan data yang ditarik dari server.
    2. Perlihatkan URL API backend online.
    3. Buka Postman dan kirim request GET.
    4. Lakukan minimal satu operasi POST / Update / Delete di Postman atau Flutter.
    5. Tunjukkan response JSON berhasil.
