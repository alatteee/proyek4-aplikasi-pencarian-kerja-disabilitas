# 🧪 PANDUAN TESTING ST-03 DETAIL STEP-BY-STEP

## ⚠️ PENTING: ORDER EKSEKUSI
Harus dilakukan dalam urutan ini:
1. ✅ **ST-01**: Seed 20 Lowongan
2. ✅ **ST-02**: Seed 20 User
3. 🟡 **ST-03**: Seed 20 Aplikasi (yang sedang kita test sekarang)

---

# 📍 STEP 1: JALANKAN ST-01 & ST-02 DULU

## Buka App JobAble

### A. Buka Halaman Profile
```
Tap menu di bawah → Profile (gambar orang)
```

**Screenshot expected:**
- Menu buttons akan terlihat dengan icon-icon

### B. Scroll ke bawah sampai melihat Stress Test buttons
```
Anda akan melihat 3 tombol merah/orange:
1. 🚀 Stress Test (20 Jobs)
2. 👥 Stress Test (20 Users)  
3. 🗑️ Bersihkan SEMUA Data Test
```

### C. Jalankan ST-01: Stress Test (20 Jobs)
```
Tap tombol pertama: "Stress Test (20 Jobs)"
```

**Apa yang terjadi:**
- Loading indicator muncul (spinning circle)
- Di background, console akan print progress (lihat Flutter Logs)
- Tunggu 15-30 detik sampai selesai

**Indikator berhasil:**
```
Snackbar hijau/biru muncul: "Berhasil tambah 20 lowongan dummy!"
```

### D. Jalankan ST-02: Stress Test (20 Users)
```
Tap tombol kedua: "Stress Test (20 Users)"
```

**Tunggu sampai muncul snackbar:**
```
"Berhasil tambah 20 akun & profil dummy!"
```

---

# 🔑 STEP 2: COPY JOB ID

Ada **2 cara** untuk mendapatkan Job ID. Pilih salah satu:

## CARA A: Copy dari MongoDB Atlas (PALING MUDAH & AKURAT)

### 1. Buka MongoDB Atlas
```
https://cloud.mongodb.com
Login dengan akun Anda
```

### 2. Buka Database
```
Clusters → Connect → Data Explorer
```

### 3. Pilih Collection "job_vacancies"
```
Database: pencaker (atau nama database Anda)
Collection: job_vacancies
```

Seharusnya Anda melihat sekali 20 documents dengan data seperti:

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "job_title": "Senior Flutter Developer",
  "company_name": "PT Tech Indonesia",
  "location": "Jakarta",
  "salary": "15000000 - 20000000",
  "type": "full-time",
  "status": "active",
  "is_stress_test_data": true,
  ...
}
```

### 4. Copy _id dari salah satu document
**Klik pada value _id:**
```
ObjectId("507f1f77bcf86cd799439011")
```

**Copy hanya ISINYA (tanpa ObjectId()):**
```
507f1f77bcf86cd799439011
```

Gunakan Ctrl+C untuk copy, atau klik ikon copy jika ada.

---

## CARA B: Copy dari App (Jika ingin langsung dari UI)

### 1. Buka Halaman Beranda (Home)
```
Tap menu di bawah → Home (gambar rumah)
```

### 2. Lihat Daftar Lowongan Dummy
```
Anda akan melihat 20 lowongan yang baru saja di-seed dari ST-01
Filter: Cari lowongan dengan company/title yang aneh (dari faker data)
```

### 3. Tap Salah Satu Lowongan
```
Tap card lowongan
→ Detail page terbuka
```

### 4. Cari Job ID di Detail
**Lokasi Job ID bisa di beberapa tempat:**

Opsi 1: Di app bar / header
```
Lihat judul page atau icons
```

Opsi 2: Di bagian bawah detail (jika ada "Debug Info")
```
Scroll ke paling bawah
Cari text yang terlihat seperti ID (panjang, hex)
```

Opsi 3: Dari browser DevTools (jika testing di web)
```
Press F12 → Console
Cari job object dengan console.log
```

**REKOMENDASI**: Gunakan **CARA A (MongoDB Atlas)** karena lebih pasti dan akurat.

---

# 📝 STEP 3: INPUT JOB ID KE DIALOG

### 1. Kembali ke Profile Page
```
Tap menu di bawah → Profile
```

### 2. Scroll ke Stress Test Buttons
```
Lihat 4 tombol menu:
1. Stress Test (20 Jobs)
2. Stress Test (20 Users)
3. ⭐ Stress Test (20 Pelamar) ← INI YANG BARU
4. Bersihkan SEMUA Data Test
```

### 3. TAP TOMBOL "Stress Test (20 Pelamar)"
```
Tap tombol dengan icon orang + dokumen
```

**Dialog akan muncul dengan judul: "Input Job ID"**

```
┌─────────────────────────┐
│    Input Job ID         │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ Paste Job ID dari   │ │
│ │ Beranda             │ │
│ └─────────────────────┘ │
│                         │
│  [Batal] [Lanjut]      │
└─────────────────────────┘
```

### 4. CLICK di Input Field (kotak putih)
```
Tap/click pada text field
```

Cursor sekarang ada di dalam text field (bisa mengetik/paste).

### 5. PASTE JOB ID yang sudah dicopy
```
Ctrl+V (Windows/Linux) atau Cmd+V (Mac)
atau
Klik kanan → Paste
```

**Text field sekarang berisi:**
```
507f1f77bcf86cd799439011
```

### 6. VERIFIKASI INPUT
```
Pastikan Job ID sudah ter-paste dengan benar
Tidak ada spasi di awal/akhir
Format: 24 karakter hex
```

### 7. TAP TOMBOL "LANJUT"
```
Tap blue button: "Lanjut"
```

---

# ⏳ STEP 4: TUNGGU LOADING SELESAI

### Dialog loading akan muncul:
```
┌─────────────────────┐
│                     │
│    ⏳ (spinning)    │
│                     │
└─────────────────────┘
```

### Tunggu 10-30 detik

**Apa yang terjadi di background:**
- 20 user queries dari database
- Loop 20 kali: setiap user submit aplikasi
- 20 inserts ke collection job_applications

### Monitor di Console/Logs:
Buka Flutter Logs (bottom panel):
```
flutter: 📋 Memulai Seeding 20 Aplikasi Lamaran ke Job: 507f1f77bcf86cd799439011...
flutter: ✅ Progress aplikasi: 1/20 dari user_dummy_1
flutter: ✅ Progress aplikasi: 2/20 dari user_dummy_2
flutter: ✅ Progress aplikasi: 3/20 dari user_dummy_3
...
flutter: ✅ Progress aplikasi: 20/20 dari user_dummy_20
```

---

# ✅ STEP 5: VERIFIKASI SUCCESS

### Dialog Loading Hilang
```
Loading indicator hilang
Dialog ditutup
```

### Snackbar Muncul
```
Snackbar text: "Berhasil tambah 20 aplikasi dummy!"
```

Ini berarti **20 aplikasi BERHASIL dimasukkan ke database!**

---

# 🔍 STEP 6: VALIDASI DI MONGODB ATLAS

### A. Buka MongoDB Atlas
```
https://cloud.mongodb.com → Data Explorer
```

### B. Buka Collection "job_applications"
```
Database: pencaker
Collection: job_applications
```

### C. Cari Data Dummy yang Baru Saja Dibuat
```
Filter by: is_stress_test_data = true
```

**Seharusnya muncul 20 documents:**

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "job_id": "507f1f77bcf86cd799439011",  ← SAMA dengan Job ID yang di-input
  "user_id": ObjectId("507f1f77bcf86cd799439020"),  ← User dummy
  "status": "pending",
  "applied_at": ISODate("2024-05-19T10:30:45.123Z"),
  "updated_at": ISODate("2024-05-19T10:30:45.123Z"),
  "cv_attachment": "https://example.com/cv/507f1f77bcf86cd799439020.pdf",
  "cover_letter": "Lorem ipsum dolor sit amet consectetur...",
  "is_stress_test_data": true
}
```

### D. Verifikasi Data dengan Count
```
Di MongoDB Atlas console, run:

db.job_applications.countDocuments({
  "is_stress_test_data": true,
  "job_id": ObjectId("507f1f77bcf86cd799439011")
})
```

**Expected result: 20**

---

# 🎯 STEP 7: VALIDASI DI APP (COMPANY VIEW)

Jika Anda punya akun perusahaan, verifikasi aplikasi terlihat di company dashboard:

### A. Logout dari Akun Pelamar
```
Profile → Logout
```

### B. Login Sebagai Perusahaan
```
Email/Username: [akun perusahaan]
Password: [password]
```

### C. Buka Company Dashboard
```
Navigate ke: Dashboard / Kelola Pelamar / Applicants
```

### D. Filter by Job
```
Pilih job yang sama dengan Job ID yang digunakan di ST-03
```

### E. Lihat 20 Pelamar
```
Harus ada 20 row dengan:
- Foto profil (dari i.pravatar.cc)
- Nama: User Dummy 1, User Dummy 2, ..., User Dummy 20
- Status: Pending
- Applied Date: Waktu ketika ST-03 dijalankan
```

---

# 🗑️ STEP 8: CLEANUP (OPSIONAL)

Jika ingin menghapus semua data dummy (ST-01, ST-02, ST-03):

### Buka Profile Page
```
Tap menu → Profile
```

### Tap Tombol "Bersihkan SEMUA Data Test"
```
Tap button dengan icon trash/delete
```

### Tunggu Loading
```
Dialog loading muncul
Tunggu 5-10 detik
```

### Snackbar Success
```
"Semua data dummy berhasil dibersihkan!"
```

**Data yang dihapus:**
- ✅ 20 jobs dari ST-01 (collection: job_vacancies)
- ✅ 20 users dari ST-02 (collection: users)
- ✅ 20 user_details dari ST-02 (collection: user_details)
- ✅ 20 applications dari ST-03 (collection: job_applications)

---

# 🆘 TROUBLESHOOTING

## Problem: Dialog "Input Job ID" tidak muncul

**Kemungkinan:**
- Button belum ter-render (scroll ke bawah dulu)
- Hot reload issue

**Solusi:**
```
1. Hot Restart (R) di VS Code terminal
2. Atau tutup dan buka ulang app
```

---

## Problem: Copy-Paste tidak bekerja

**Kemungkinan:**
- Clipboard tidak support di Flutter
- Android Emulator permission issue

**Solusi:**
```
1. Ketik manual Job ID ke text field
2. Atau copy dari MongoDB, paste ke notepad dulu, 
   kemudian copas ke app
```

---

## Problem: SnackBar berhasil tapi "Error: Tidak ada user dummy"

**Kemungkinan:**
- ST-02 belum dijalankan / gagal

**Solusi:**
```
1. Kembali ke Profile
2. Jalankan ST-02 terlebih dahulu
3. Tunggu sampai success snackbar muncul
4. Baru jalankan ST-03 lagi
```

---

## Problem: Job ID "Invalid" atau "Not Found"

**Kemungkinan:**
- Job ID salah (typo, copy-paste error)
- Job ID dari collection lain

**Solusi:**
```
1. Verifikasi di MongoDB Atlas
2. Pastikan dari collection "job_vacancies"
3. Pastikan punya is_stress_test_data: true
4. Copy ulang dengan hati-hati
```

---

## Problem: Hanya 5-10 aplikasi yang masuk, bukan 20

**Kemungkinan:**
- Connection timeout
- MongoDB rate limit
- Network error di tengah-tengah

**Solusi:**
```
1. Tunggu 2-3 menit
2. Check MongoDB Atlas connection status
3. Retry ST-03
4. Jika tetap problem, check console untuk error message
```

---

## Problem: Data ada di MongoDB tapi tidak muncul di App

**Kemungkinan:**
- Cache Hive belum di-refresh
- App tidak di-restart

**Solusi:**
```
1. Profile → Pull to refresh (geser dari atas ke bawah)
2. Atau tutup dan buka app ulang
3. Atau clear app cache:
   Settings → Apps → JobAble → Storage → Clear Cache
```

---

# ✨ CHECKLIST SUKSES

Nyatakan **ST-03 PASSED** jika:

- [ ] ST-01 berhasil (20 jobs ada di MongoDB)
- [ ] ST-02 berhasil (20 users ada di MongoDB)
- [ ] Job ID berhasil dicopy dari MongoDB Atlas
- [ ] Dialog "Input Job ID" muncul saat tap tombol
- [ ] Job ID berhasil di-paste ke text field
- [ ] Tombol "Lanjut" diklik, dialog loading muncul
- [ ] Console menunjukkan "✅ Progress aplikasi: 20/20"
- [ ] Snackbar "Berhasil tambah 20 aplikasi dummy!" muncul
- [ ] MongoDB job_applications punya 20 documents
- [ ] Semua 20 documents punya job_id yang sama
- [ ] Semua documents punya is_stress_test_data: true
- [ ] Cleanup berhasil menghapus semua 20 data

---

# 📚 RINGKASAN CEPAT

```
1. Profile → ST-01 ✅
2. Profile → ST-02 ✅
3. Copy Job ID dari MongoDB Atlas
4. Profile → ST-03 → Paste Job ID → Lanjut
5. Tunggu loading → Cek snackbar success ✅
6. Verifikasi di MongoDB (20 records) ✅
7. (Optional) Cleanup ✅
```

**DONE!** 🎉

---

**Jika masih ada pertanyaan, ask me anything!**
