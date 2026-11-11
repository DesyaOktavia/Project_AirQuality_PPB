# Aplikasi Pemantau Kualitas Udara Kalimantan Timur (Samarinda, Balikpapan, & Bontang)

Aplikasi pemantau kualitas udara real-time berbasis **Flutter** yang menyajikan Indeks Standar Pencemar Udara (**ISPU**) berdasarkan **Permen LHK No. P.14/2020** dan **AQI (Air Quality Index)** secara presisi hingga tingkat **Kecamatan** di 3 kota utama Kalimantan Timur.

---

## Deskripsi Aplikasi

Aplikasi ini dikembangkan untuk memudahkan masyarakat dan civitas akademika di Kalimantan Timur dalam memantau kondisi kualitas udara secara akurat. Aplikasi mengambil data konsentrasi polutan udara meliputi **PM2.5, PM10, O₃, NO₂, SO₂, dan CO** secara langsung dari layanan API publik.

### Cakupan Wilayah Pemantauan (19 Kecamatan)

1. **Kota Samarinda (10 Kecamatan)**
    * Kecamatan Loa Janan Ilir
    * Kecamatan Palaran
    * Kecamatan Samarinda Ilir
    * Kecamatan Samarinda Kota
    * Kecamatan Samarinda Seberang
    * Kecamatan Samarinda Ulu
    * Kecamatan Samarinda Utara
    * Kecamatan Sambutan
    * Kecamatan Sungai Kunjang
    * Kecamatan Sungai Pinang

2. **Kota Balikpapan (6 Kecamatan)**
    * Kecamatan Balikpapan Barat
    * Kecamatan Balikpapan Kota
    * Kecamatan Balikpapan Selatan
    * Kecamatan Balikpapan Tengah
    * Kecamatan Balikpapan Timur
    * Kecamatan Balikpapan Utara

3. **Kota Bontang (3 Kecamatan)**
    * Kecamatan Bontang Barat
    * Kecamatan Bontang Selatan
    * Kecamatan Bontang Utara

---

## Fitur Utama

* **Arsitektur Pintar Auto-Fallback (`RepositoriUdaraPintar`)**:
    * **Primary Data**: Menggunakan OpenWeather Air Pollution REST API.
    * **Automatic Backup**: Jika server OpenWeather bermasalah, terkena CORS di browser Web, atau API Key ditolak, aplikasi **otomatis beralih ke Open-Meteo Air Quality API** secara seamless.
    * **Offline Demo Mode**: Jika perangkat tidak terhubung ke internet, aplikasi menyediakan simulasi data lokal agar UI tetap dapat diakses tanpa error.
* **Indikator Baku Mutu & Saran Kesehatan**:
    * Perhitungan ISPU resmi sesuai Permen LHK P.14/2020.
    * Pengukur lingkaran ISPU animasi berwarna dinamis (Hijau = Baik, Biru = Sedang, Oranye = Tidak Sehat, Merah = Sangat Tidak Sehat, Ungu = Berbahaya).
    * Rekomendasi aktivitas dan saran penggunaan masker sesuai kondisi udara setempat.
* **Grid Detail Polutan Interaktif**:
    * Menampilkan 6 jenis polutan beserta indikator kelipatan aman standar WHO.
    * Setiap kartu polutan dapat diklik untuk menampilkan dialog edukasi penjelasan dampaknya terhadap kesehatan.
* **Tren 24 Jam & Prakiraan Harian**:
    * Grafik estimasi kualitas udara tiap jam selama 24 jam ke depan.
    * Proyeksi kondisi kualitas udara untuk beberapa hari mendatang.
* **Pengaturan API & Dukungan Mode Gelap (Dark Mode)**:
    * Pengguna dapat menguji dan memasukkan OpenWeather API Key sendiri via modal Pengaturan.
    * Pilihan sumber data fleksibel (Otomatis / OpenWeather / Open-Meteo / Offline Demo).
    * Tombol toggle cepat Mode Terang & Mode Gelap pada AppBar.

---

## Arsitektur & Pola Desain (MVVM)

Aplikasi ini dibangun menggunakan arsitektur **MVVM (Model-View-ViewModel)** dengan **Provider** sebagai State Management:

```
[REST API (OpenWeather / Open-Meteo)] 
                 │
                 ▼
     [Layanan Service Layer]
                 │
                 ▼
    [RepositoriUdaraPintar] ◄── Auto-Fallback Logic
                 │
                 ▼
         [UdaraViewModel] ◄── Provider / ChangeNotifier
                 │
                 ▼
       [AplikasiUdara / UI] ◄── Flutter Material 3
```

---

## Tampilan Antarmuka (Screenshots)

Berikut adalah dokumentasi tangkapan layar fitur-fitur utama aplikasi:

### 1. Dashboard Utama - Kota Samarinda (Mode Terang vs Mode Gelap)
| Mode Terang (Light Theme) | Mode Gelap (Dark Theme) |
| :---: | :---: |
| ![Samarinda Light](docs/screenshots/01_samarinda_light.png) | ![Samarinda Dark](docs/screenshots/03_samarinda_dark.png) |
| *Tampilan ISPU 31 (Udara Baik), tab Samarinda, chip kecamatan, dan saran kesehatan.* | *Tampilan mode gelap yang nyaman di mata untuk pemantauan malam hari.* |

### 2. Kandungan Polutan (µg/m³) & Tren 24 Jam
| Kandungan Polutan & Tren (Light) | Kandungan Polutan & Tren (Dark) |
| :---: | :---: |
| ![Polutan Light](docs/screenshots/02_polutan_light.png) | ![Polutan Dark](docs/screenshots/04_polutan_dark.png) |
| *Rincian 6 polutan (PM2.5, PM10, O₃, NO₂, SO₂, CO) dengan batas WHO & Tren 24 jam.* | *Grid polutan responsif dengan rasio aspek kompak.* |

### 3. Pemantauan Kota Balikpapan & Kota Bontang
| Kota Balikpapan (Kec. Balikpapan Barat) | Kota Bontang (Kec. Bontang Barat) |
| :---: | :---: |
| ![Balikpapan Barat](docs/screenshots/07_balikpapan_barat.png) | ![Bontang Barat](docs/screenshots/08_bontang_barat.png) |
| *Pemantauan tingkat kecamatan di Kota Balikpapan (ISPU 41).* | *Pemantauan tingkat kecamatan di Kota Bontang (ISPU 25).* |

### 4. Modal Pengaturan API & Edukasi ISPU Permen LHK
| Pengaturan Sumber Data & API | Modal Edukasi ISPU Permen LHK |
| :---: | :---: |
| ![Pengaturan API](docs/screenshots/05_modal_pengaturan.png) | ![Edukasi ISPU](docs/screenshots/06_modal_edukasi.png) |
| *Fitur perpindahan mode data (Otomatis/OpenWeather/Open-Meteo/Demo) & Custom API Key.* | *Penjelasan resmi kategori ISPU (Baik, Sedang, Tidak Sehat, Sangat Tidak Sehat, Berbahaya).* |

### 5. Prakiraan 5 Hari Harian
![Prakiraan 5 Hari](docs/screenshots/09_prakiraan_5hari.png)  
*Estimasi harian kondisi udara 5 hari ke depan beserta indikator PM2.5 tertinggi.*

---

## Cara Menjalankan Project

### Prasyarat:
* **Flutter SDK**: Versi >= 3.13.0
* **Dart SDK**: Versi >= 3.0.0

### Langkah-langkah:

1. **Clone atau Buka Project**:
   ```bash
   cd copyan_tugas_kelompok_ppb
   ```

2. **Unduh Dependensi Package**:
   ```bash
   flutter pub get
   ```

3. **Jalankan Analisis Kode & Pengujian Unit**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Jalankan Aplikasi pada Perangkat / Web Browser**:
    * **Untuk Chrome / Web**:
      ```bash
      flutter run -d chrome
      ```
    * **Untuk Android Device / Emulator**:
      ```bash
      flutter run
      ```

---

## Lisensi & Sumber Data
* **Baku Mutu ISPU**: Peraturan Menteri Lingkungan Hidup dan Kehutanan RI No. P.14/SETJEN/KUM.1/7/2020.
* **Sumber API**: OpenWeather Air Pollution API (`openweathermap.org`) & Open-Meteo Air Quality API (`open-meteo.com`).
