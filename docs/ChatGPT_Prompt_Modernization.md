# Modernisasi Aplikasi Pencari Kerja Disabilitas (Pencaker)

Dokumen ini berisi informasi teknis mengenai status aplikasi Pencaker untuk digunakan sebagai referensi pengembang atau AI di masa mendatang.

## 1. Arsitektur Proyek
- **Framework:** Flutter (Android & iOS).
- **Database:** MongoDB (Koneksi langsung melalui `mongo_dart`).
- **Caching Lokal:** Hive (Offline-first architecture).
- **State Management:** ValueNotifier & ValueListenableBuilder (Tanpa Provider/Bloc untuk efisiensi).

## 2. Fitur Aksesibilitas: Mode Kontras Tinggi
Fitur unggulan untuk pengguna tunanetra/low vision:
- **Warna:** Hitam (#050505) sebagai background dan Kuning (#FFEA00) sebagai warna teks/interaktif utama.
- **Implementasi:** Menggunakan `AccessibilityController` dengan `ValueNotifier<bool>` yang diobservasi oleh `ValueListenableBuilder` di setiap halaman utama.
- **Halaman Tercover:**
  - `home_page.dart`
  - `notification_page.dart`
  - `job_seeker_notification_detail_page.dart`
  - `applications_page.dart`
  - `cv_view.dart`
  - `cv_form_view.dart`
  - `cv_detail_view.dart`
  - `application_success_page.dart`

## 3. Integrasi Data
- **MongoService:** Bertanggung jawab atas semua query ke database.
- **OfflineService:** Mengelola cache Hive.
- **sinkronisasi:** Aplikasi memprioritaskan data dari MongoDB saat online dan menyimpannya ke cache. Saat offline, data diambil dari cache Hive.

## 4. Masalah Teknis yang Telah Diperbaiki
1. **Field Mismatch:** Mengubah referensi `company_logo` menjadi `job_photo` di seluruh aplikasi sesuai skema MongoDB.
2. **Invalid Colors:** Mengganti `Colors.white87` (yang menyebabkan error) dengan `Colors.white.withOpacity(0.87)`.
3. **Cache Invalidation:** Menambahkan method `clearJobsCache()` dan `clearAllCache()` di `OfflineService` untuk memaksa fetch data terbaru.
4. **Dynamic Icons:** Memastikan icon pada detail notifikasi mengikuti tema kontras tinggi (menjadi kuning saat aktif).

## 5. Instruksi Pengembangan Selanjutnya
- Jika menambah halaman baru, pastikan membungkus `Scaffold` dengan `ValueListenableBuilder<bool>` dari `AccessibilityController.highContrastNotifier`.
- Gunakan konstanta dari `AccessibilityTheme` untuk warna mode gelap/kontras tinggi.
- Selalu periksa apakah field `job_photo` tersedia sebelum menampilkan gambar lowongan kerja.
