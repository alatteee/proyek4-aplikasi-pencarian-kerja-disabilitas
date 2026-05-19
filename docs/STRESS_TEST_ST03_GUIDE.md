# Panduan Testing ST-03: Stress Test Aplikasi (20 Pelamar)

## Deskripsi Skenario
ST-03 menguji kemampuan aplikasi menangani **20 user dummy yang secara bersamaan submit lamaran ke 1 lowongan pekerjaan yang sama**. Ini menguji:
- ✅ Relationship integrity antara job_applications dan jobs
- ✅ Database performance dengan 20 concurrent writes
- ✅ UI rendering performance di Company Dashboard (applicants list)
- ✅ Data consistency saat multiple users apply to same job

---

## Prerequisites
Pastikan **ST-01 dan ST-02 sudah berhasil dijalankan sebelumnya**:
1. ✅ ST-01: Stress Test (20 Jobs) - untuk mendapatkan Job ID
2. ✅ ST-02: Stress Test (20 Users) - untuk membuat 20 user dummy

Jika belum, jalankan dua test ini terlebih dahulu dari Profile page.

---

## Langkah-Langkah Testing

### 1. Buka Halaman Beranda (Daftar Lowongan)
```
Bottom Navigation → Home (Beranda)
```
Anda akan melihat daftar lowongan pekerjaan. Di sini ada lowongan yang dibuat dari ST-01.

### 2. Copy Job ID dari Lowongan
```
Pilih salah satu lowongan dari hasil ST-01 → 
Detail page akan muncul (lihat job title, company, location, dll)
```

**Cara mendapatkan Job ID:**
- Job ID adalah `_id` di MongoDB Atlas untuk lowongan tersebut
- Format: string hex panjang, seperti `ObjectId("507f1f77bcf86cd799439011")`

**Alternatif: Copy dari MongoDB Atlas**
```
1. Buka MongoDB Atlas Data Explorer
2. Navigate ke collection: job_vacancies
3. Lihat document yang dibuat oleh ST-01 (semua punya is_stress_test_data: true)
4. Copy field _id dari salah satu document
```

### 3. Buka Profile Page
```
Bottom Navigation → Profile (Profil)
```

Anda akan melihat menu stress test dengan tombol-tombol:
- Stress Test (20 Jobs)
- Stress Test (20 Users)
- **[NEW] Stress Test (20 Pelamar)** ← Ini yang kita gunakan
- Bersihkan SEMUA Data Test

### 4. Klik Tombol "Stress Test (20 Pelamar)"
```
Tap → Stress Test (20 Pelamar)
```

Dialog akan muncul dengan input field berjudul "Input Job ID".

### 5. Paste Job ID ke Input Field
```
Paste job ID yang sudah dicopy → Tap "Lanjut"
```

Contoh input:
```
507f1f77bcf86cd799439011
```

### 6. Tunggu Loading Selesai
```
Circular progress indicator muncul
Processing: 20 users submit applications
Estimasi waktu: 10-30 detik (bergantung koneksi)
```

Monitor di console (flutter logs):
```
📋 Memulai Seeding 20 Aplikasi Lamaran ke Job: [jobId]...
✅ Progress aplikasi: 1/20 dari user_dummy_1
✅ Progress aplikasi: 2/20 dari user_dummy_2
...
✅ Progress aplikasi: 20/20 dari user_dummy_20
```

### 7. Verifikasi Berhasil
```
SnackBar muncul: "Berhasil tambah 20 aplikasi dummy!"
```

---

## Validasi Hasil di App

### Di Company Dashboard (jika role = perusahaan)
```
1. Logout dari akun pelamar
2. Login dengan akun perusahaan
3. Navigate ke dashboard → Applicants / Pelamar
4. Filter by job → Pilih job yang digunakan di ST-03
5. Anda harus melihat 20 pelamar dengan status "Pending"
```

### Apa yang harus terlihat:
- ✅ 20 row pelamar dengan profile photo dari i.pravatar.cc
- ✅ Nama (User Dummy 1, User Dummy 2, dst)
- ✅ Applied date (waktu ketika ST-03 dijalankan)
- ✅ Status: "Pending"
- ✅ CV attachment link

---

## Validasi Hasil di MongoDB Atlas

### 1. Collection: job_applications
```
Filter: {
  "job_id": "[job_id_yang_dipakai]",
  "is_stress_test_data": true
}

Expected: 20 documents
```

### 2. Field Validation
Setiap document harus memiliki:
```json
{
  "_id": ObjectId,
  "job_id": "[same_job_id]",
  "user_id": ObjectId (dari users collection),
  "status": "pending",
  "applied_at": ISODate("2024-..."),
  "updated_at": ISODate("2024-..."),
  "cv_attachment": "https://example.com/cv/...",
  "cover_letter": "[Lorem ipsum sentences]",
  "is_stress_test_data": true
}
```

### 3. Count Verification
```
Command: db.job_applications.countDocuments({
  "job_id": ObjectId("[job_id]"),
  "is_stress_test_data": true
})

Expected result: 20
```

---

## Performance Metrics to Monitor

### 1. Insertion Time
- **Recorded at**: `duration_ms` di console output
- **Expected**: < 60,000 ms (60 detik) untuk 20 inserts
- **Ideal**: < 30,000 ms

### 2. Memory Usage
- Buka DevTools → Memory profiler
- Sebelum ST-03: Baseline memory
- Selama ST-03: Peak memory
- Sesudah ST-03: Memory setelah GC

**Expected**: < 500MB increase

### 3. UI Responsiveness
- Company Dashboard harus tetap responsive saat load 20 applicants
- Scroll di applicants list harus smooth (60 fps)
- Taps/interactions tidak freeze

---

## Troubleshooting

### Error: "Tidak ada user dummy"
```
Solusi: Jalankan ST-02 dulu (Stress Test 20 Users)
```

### Error: "MongoDB tidak tersambung"
```
Solusi: 
1. Check internet connection
2. Verifikasi MongoDB Atlas cluster is accessible
3. Retry test
```

### Hanya 5-10 aplikasi yang masuk, bukan 20
```
Possible causes:
1. Job ID salah (copy-paste error)
2. Connection timeout saat loop insert
3. MongoDB Atlas rate limit

Solusi:
1. Verifikasi Job ID dari MongoDB Atlas
2. Tunggu 1-2 menit sebelum retry
3. Check MongoDB Atlas Activity tab untuk connection issues
```

### Data muncul di MongoDB tapi tidak di App UI
```
Solusi:
1. Pull-to-refresh halaman Applicants
2. Restart app completely
3. Clear app cache (Settings → Apps → JobAble → Storage → Clear Cache)
```

---

## Cleanup

### Hapus Semua Data ST-03
```
Profile page → Tap "Bersihkan SEMUA Data Test"
```

Ini akan menghapus:
- ✅ 20 jobs dari ST-01
- ✅ 20 users dan profiles dari ST-02
- ✅ 20 applications dari ST-03
- ✅ Semua data lain dengan is_stress_test_data: true

---

## Success Criteria Checklist

Nyatakan ST-03 **PASSED** jika semua ini terpenuhi:

- [ ] ST-02 (20 Users) berhasil dijalankan sebelumnya
- [ ] ST-01 (20 Jobs) berhasil dijalankan sebelumnya
- [ ] Job ID berhasil dicopy dari Beranda atau MongoDB
- [ ] Dialog input Job ID muncul dengan benar
- [ ] Klik "Lanjut" menjalankan seeding
- [ ] Loading indicator muncul untuk 10-30 detik
- [ ] SnackBar success muncul: "Berhasil tambah 20 aplikasi dummy!"
- [ ] Console logs menunjukkan "✅ Progress aplikasi: 20/20"
- [ ] MongoDB job_applications collection punya 20 records dengan is_stress_test_data: true
- [ ] Semua 20 applications punya job_id yang sama (sesuai input)
- [ ] Semua 20 applications punya user_id yang berbeda
- [ ] Company Dashboard bisa load 20 applicants tanpa freeze
- [ ] Applicants list responsive dan scrollable
- [ ] Data dapat dihapus dengan "Bersihkan SEMUA Data Test"

---

## Academic Documentation

### For Professor Submission
Include in your project documentation:

**ST-03 Implementation Summary:**
```
- Fungsi: StressTestService.seedApplications(count, jobId)
- Location: lib/services/stress_test_service.dart (lines X-Y)
- Test Type: Load & Relationship Testing
- Database: MongoDB Atlas - job_applications collection
- UI: Profile page menu + input dialog
- Performance: ~[actual duration]ms untuk 20 inserts
```

**Observations:**
- [ ] All 20 applications inserted successfully
- [ ] Database relationship integrity maintained
- [ ] UI responsive under load
- [ ] Data persistence confirmed
- [ ] Cleanup function working properly

---

## Next Steps After ST-03
1. ✅ ST-01: Create jobs data
2. ✅ ST-02: Create users data
3. ✅ ST-03: Create applications data (20 users → 1 job)
4. 🔄 **Optional ST-04**: Implement more complex scenarios:
   - Users applying to multiple jobs (1 user → 5 different jobs)
   - Batch operations testing
   - Concurrent access stress tests

---

**Last Updated**: 2024
**Status**: Ready for Production Testing
