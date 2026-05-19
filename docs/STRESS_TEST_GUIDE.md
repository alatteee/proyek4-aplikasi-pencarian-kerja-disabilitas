# 🚀 Panduan Stress Testing (Full Flow)
Aplikasi Pencarian Kerja Disabilitas

Dokumen ini menjelaskan cara melakukan uji beban (Stress Testing) untuk mensimulasikan penggunaan aplikasi dalam skala besar (Bulk Data), mulai dari pendaftaran akun hingga lowongan pekerjaan.

## 1. Tujuan Pengujian
1. **Database Reliability**: Memastikan MongoDB sanggup menerima input beruntun tanpa kegagalan.
2. **UI Smoothness**: Memastikan daftar lowongan tidak patah-patah (*jank*) saat jumlah data bertambah.
3. **Data Integrity**: Memvalidasi penggunaan `faker` untuk membangkitkan data unik.
4. **Relational Consistency**: Memastikan akun (`users`) dan profil (`users_details`) tersinkronisasi saat dibuat masal.

## 2. Skenario Pengujian (Full Flow)

| ID | Skenario | Langkah Pengujian | Target | Ekspektasi |
|:---|:---|:---|:---|:---|
| **ST-01** | **Massive Job Entry** | Klik `Stress Test (20 Jobs)` | MongoDB `jobs` | 20 lowongan dummy tersimpan dalam < 3 detik. |
| **ST-02** | **Bulk Registration** | Klik `Stress Test (20 Users)` | `users` & `users_details` | 20 Akun + 20 Profil sinkron dengan status profil lengkap. |
| **ST-03** | **Infinite Scroll** | Scroll Home dengan data aktif | Flutter UI | FPS tetap stabil, gambar ter-load tanpa crash. |
| **ST-04** | **Cleanup Routine** | Klik `Bersihkan SEMUA Data` | All Collections | Semua data dummy dihapus bersih tanpa sisa. |

## 3. Cara Menjalankan
1. Buka aplikasi, masuk ke menu **Profil**.
2. Anda akan menemukan 3 tombol baru di bagian bawah pengaturan.
3. Jalankan **ST-01** dan **ST-02** secara berurutan.
4. Verifikasi di halaman **Beranda** (tarik ke bawah untuk refresh).
5. Jalankan **ST-04** setelah selesai demo untuk membersihkan database.


```dart
// Skrip ini berada di lib/services/stress_test_service.dart
final result = await StressTestService.seedJobs(50);
print("Berhasil memasukkan ${result['success_count']} data dalam ${result['duration_ms']}ms");
```

## 4. Cara Penggunaan untuk Demo
1. Klik tombol **"Mulai Stress Test"** (20 atau 50 data).
2. Perhatikan konsol log untuk melihat proses *insertion*.
3. Buka **Home Page**, lakukan *Pull to Refresh*.
4. Scroll sampai bawah untuk melihat performa rendering.
5. Jalankan **"Bersihkan Data Test"** untuk mengembalikan database ke kondisi semula.

---
*Dibuat untuk kebutuhan Proyek 4 - Semester 4.*
