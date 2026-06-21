# Monity 🪙

**Monity** adalah aplikasi pencatat keuangan pribadi (*Personal Finance Tracker*) berbasis mobile yang dirancang dengan desain modern, minimalis, dan intuitif. Aplikasi ini membantu pengguna untuk mengelola pemasukan, pengeluaran, serta memvisualisasikan data keuangan secara praktis dan terstruktur.

---

## 🚀 Fitur Utama
- **Autentikasi Pengguna**: Sistem pendaftaran akun baru, login, serta manajemen profil pengguna.
- **Pencatatan Keuangan Lengkap**: Kelola transaksi pemasukan (*income*) dan pengeluaran (*expense*) secara mendetail dengan dukungan kategori khusus.
- **Visualisasi & Analisis Data**: Laporan keuangan interaktif menggunakan:
  - **Pie Chart**: Distribusi pengeluaran per kategori.
  - **Bar & Line Chart**: Tren fluktuasi pemasukan dan pengeluaran harian, mingguan, dan bulanan.
- **Persistensi Data Lokal**: Penyimpanan data offline yang aman menggunakan SQLite database sehingga data tidak hilang saat aplikasi ditutup.
- **Data Demo Otomatis**: Pengguna baru otomatis disuguhkan dengan data dummy interaktif untuk mempermudah pemahaman antarmuka grafik pada pendaftaran pertama.

---

## 🛠️ Tech Stack & Library
- **Core Framework**: Flutter & Dart (minimum SDK ^3.12.1)
- **State Management**: `provider` (reaktif, bersih, dan efisien)
- **Database Lokal**: `sqflite` & `path` (SQLite engine)
- **Visualisasi Grafik**: `fl_chart` (grafik dinamis & responsif)
- **Sesi Pengguna**: `shared_preferences` (menyimpan sesi login)
- **Typography & Styling**: `google_fonts` (Outfit / font kustom premium)

---

## 📂 Arsitektur Proyek
Aplikasi ini mengadopsi **Clean Architecture** dengan pendekatan **Feature-First / Layer-First** untuk memisahkan logika bisnis dari antarmuka visual agar kode mudah dipelihara (*maintainable*):

```text
lib/
├── core/
│   ├── theme/          # Konfigurasi ThemeData minimalis & skema warna semantik
│   └── utils/          # Helper utilitas (misal: enkripsi password, formatter)
├── data/
│   ├── database/       # SQLite DatabaseHelper (Singleton pattern)
│   └── models/         # Model data transaksi & user (konversi dari/ke map & JSON)
├── providers/          # Otak aplikasi / State Management (Auth & Transactions)
└── presentation/
    ├── screens/        # Halaman antarmuka pengguna (Dashboard, Login, Report, dll.)
    └── widgets/        # Komponen UI reusable (Button, StatCard, EmptyState, dll.)
```

---

## 💻 Cara Menjalankan Proyek

### 1. Prasyarat
Pastikan komputer Anda sudah terinstal [Flutter SDK](https://docs.flutter.dev/get-started/install) versi terbaru.

### 2. Kloning Repositori
```bash
git clone https://github.com/Nazlul31/monity-uas-pbm.git
cd monity-uas-pbm
```

### 3. Instalasi Dependensi
```bash
flutter pub get
```

### 4. Hubungkan Perangkat & Jalankan
Pastikan emulator aktif, lalu jalankan:
```bash
flutter run
```

---

## 👥 Tim Pengembang
- **Muhammad Nazlul Ramadhyan** (2308107010036)
- **Naufal Farrel Syafilan** (2308107010058)
