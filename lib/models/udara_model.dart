import 'package:flutter/material.dart';

/// Enum Kota Induk di Kalimantan Timur
enum KotaInduk {
  samarinda('Kota Samarinda', 'Kalimantan Timur', 8, 'WITA'),
  balikpapan('Kota Balikpapan', 'Kalimantan Timur', 8, 'WITA'),
  bontang('Kota Bontang', 'Kalimantan Timur', 8, 'WITA');

  const KotaInduk(this.nama, this.provinsi, this.zonaJam, this.zonaNama);

  final String nama;
  final String provinsi;
  final int zonaJam;
  final String zonaNama;
}

/// Enum Kecamatan untuk Samarinda (10), Balikpapan (6), dan Bontang (3)
enum Kecamatan {
  // --- KOTA SAMARINDA (10 KECAMATAN) ---
  loaJananIlir('Loa Janan Ilir', KotaInduk.samarinda, -0.555, 117.112),
  palaran('Palaran', KotaInduk.samarinda, -0.571, 117.182),
  samarindaIlir('Samarinda Ilir', KotaInduk.samarinda, -0.505, 117.162),
  samarindaKota('Samarinda Kota', KotaInduk.samarinda, -0.502, 117.148),
  samarindaSeberang('Samarinda Seberang', KotaInduk.samarinda, -0.523, 117.135),
  samarindaUlu('Samarinda Ulu', KotaInduk.samarinda, -0.485, 117.125),
  samarindaUtara('Samarinda Utara', KotaInduk.samarinda, -0.421, 117.178),
  sambutan('Sambutan', KotaInduk.samarinda, -0.515, 117.195),
  sungaiKunjang('Sungai Kunjang', KotaInduk.samarinda, -0.512, 117.092),
  sungaiPinang('Sungai Pinang', KotaInduk.samarinda, -0.472, 117.158),

  // --- KOTA BALIKPAPAN (6 KECAMATAN) ---
  balikpapanBarat('Balikpapan Barat', KotaInduk.balikpapan, -1.221, 116.821),
  balikpapanKota('Balikpapan Kota', KotaInduk.balikpapan, -1.268, 116.832),
  balikpapanSelatan('Balikpapan Selatan', KotaInduk.balikpapan, -1.252, 116.882),
  balikpapanTengah('Balikpapan Tengah', KotaInduk.balikpapan, -1.241, 116.841),
  balikpapanTimur('Balikpapan Timur', KotaInduk.balikpapan, -1.212, 116.958),
  balikpapanUtara('Balikpapan Utara', KotaInduk.balikpapan, -1.188, 116.862),

  // --- KOTA BONTANG (3 KECAMATAN) ---
  bontangBarat('Bontang Barat', KotaInduk.bontang, 0.132, 117.442),
  bontangSelatan('Bontang Selatan', KotaInduk.bontang, 0.108, 117.478),
  bontangUtara('Bontang Utara', KotaInduk.bontang, 0.152, 117.488);

  const Kecamatan(this.nama, this.kota, this.lintang, this.bujur);

  final String nama;
  final KotaInduk kota;
  final double lintang;
  final double bujur;

  static List<Kecamatan> perKota(KotaInduk kota) {
    return Kecamatan.values.where((k) => k.kota == kota).toList();
  }
}

/// Kategori Tingkat Kualitas Udara sesuai Standar Permen LHK No. P.14/2020
enum TingkatUdara {
  baik(
    'Baik',
    Color(0xFF2E7D32),
    Icons.sentiment_very_satisfied_rounded,
    'Kualitas udara sangat baik. Aman untuk beraktivitas dan berolahraga di luar ruangan.',
  ),
  sedang(
    'Sedang',
    Color(0xFF1976D2),
    Icons.sentiment_satisfied_rounded,
    'Kualitas udara cukup baik. Kelompok sangat sensitif disarankan memantau gejala pernapasan.',
  ),
  tidakSehat(
    'Tidak sehat',
    Color(0xFFF57C00),
    Icons.sentiment_dissatisfied_rounded,
    'Kurangi aktivitas berat di luar ruangan. Kelompok sensitif disarankan memakai masker.',
  ),
  sangatTidakSehat(
    'Sangat tidak sehat',
    Color(0xFFD32F2F),
    Icons.sentiment_very_dissatisfied_rounded,
    'Sangat tidak sehat. Gunakan masker standar N95/KN95 dan kurangi kegiatan luar ruangan.',
  ),
  berbahaya(
    'Berbahaya',
    Color(0xFF4A148C),
    Icons.warning_amber_rounded,
    'Tingkat berbahaya! Tetap berada di dalam ruangan, tutup jendela, dan nyalakan pemurni udara.',
  );

  const TingkatUdara(this.label, this.warna, this.ikon, this.saran);

  final String label;
  final Color warna;
  final IconData ikon;
  final String saran;

  static TingkatUdara dariIspu(int ispu) {
    if (ispu <= 50) return TingkatUdara.baik;
    if (ispu <= 100) return TingkatUdara.sedang;
    if (ispu <= 200) return TingkatUdara.tidakSehat;
    if (ispu <= 300) return TingkatUdara.sangatTidakSehat;
    return TingkatUdara.berbahaya;
  }
}

/// Indikator Sumber Data
enum SumberData {
  openWeather('OpenWeather', '☁️', Colors.blue, 'API OpenWeather Official'),
  openMeteo('Open-Meteo', '⚡', Colors.teal, 'API Open-Meteo Air Quality (Real-time & Bebas CORS)'),
  offlineMock('Demo Offline', '📱', Colors.orange, 'Simulasi Data Lokal Kaltim');

  const SumberData(this.label, this.simbol, this.warna, this.deskripsi);
  final String label;
  final String simbol;
  final Color warna;
  final String deskripsi;
}

/// Mode Pengambilan Data
enum ModeSumber {
  otomatis('Otomatis (Sangat Direkomendasikan)', 'Mencoba OpenWeather; jika timeout/CORS/error, otomatis berpindah ke Open-Meteo / Simulasi.'),
  openWeather('Hanya OpenWeather', 'Memaksa permintaan ke server OpenWeather.'),
  openMeteo('Hanya Open-Meteo', 'Memaksa permintaan ke server Open-Meteo (Cepat & Bebas CORS).'),
  offlineMock('Hanya Demo Offline', 'Memakai generator data simulasi lokal.');

  const ModeSumber(this.label, this.keterangan);
  final String label;
  final String keterangan;
}

// Batas-batas perhitungan ISPU berdasarkan Permen LHK
const List<double> _ispuAtas = [50, 100, 200, 300, 500];
const List<double> _batasPm25 = [15.5, 55.4, 150.4, 250.4, 500];
const List<double> _batasPm10 = [50, 150, 350, 420, 500];

double ispuBagian(double konsentrasi, List<double> batas) {
  double bawahX = 0;
  double bawahI = 0;
  for (int i = 0; i < batas.length; i++) {
    if (konsentrasi <= batas[i]) {
      return (_ispuAtas[i] - bawahI) /
          (batas[i] - bawahX) *
          (konsentrasi - bawahX) +
          bawahI;
    }
    bawahX = batas[i];
    bawahI = _ispuAtas[i];
  }
  return 500;
}

int hitungIspu({required double pm25, required double pm10}) {
  final double a = ispuBagian(pm25, _batasPm25);
  final double b = ispuBagian(pm10, _batasPm10);
  return (a > b ? a : b).round();
}

/// Model Data Pengamatan Udara Satu Titik Waktu
class PengamatanUdara {
  const PengamatanUdara({
    required this.waktuUtc,
    required this.waktuLokal,
    required this.aqi,
    required this.ispu,
    required this.pm25,
    required this.pm10,
    this.o3,
    this.no2,
    this.so2,
    this.co,
  });

  final DateTime waktuUtc;
  final DateTime waktuLokal;
  final int aqi;
  final int ispu;
  final double pm25;
  final double pm10;
  final double? o3;
  final double? no2;
  final double? so2;
  final double? co;

  TingkatUdara get tingkat => TingkatUdara.dariIspu(ispu);
}

/// Model Data Udara Lengkap untuk Kecamatan
class DataUdara {
  const DataUdara({
    required this.kecamatan,
    required this.saatIni,
    required this.prakiraan,
    required this.sumber,
    this.catatanSumber,
  });

  final Kecamatan kecamatan;
  final PengamatanUdara saatIni;
  final List<PengamatanUdara> prakiraan;
  final SumberData sumber;
  final String? catatanSumber;

  List<PengamatanUdara> get mendatang {
    final List<PengamatanUdara> depan = prakiraan
        .where((p) => p.waktuUtc.isAfter(saatIni.waktuUtc))
        .toList();
    return [
      for (int i = 2; i < depan.length; i += 3) depan[i],
    ].take(8).toList();
  }

  Map<DateTime, List<PengamatanUdara>> get perHari {
    final Map<DateTime, List<PengamatanUdara>> hasil = {};
    for (final PengamatanUdara p in prakiraan) {
      final DateTime hari = DateTime(
        p.waktuLokal.year,
        p.waktuLokal.month,
        p.waktuLokal.day,
      );
      (hasil[hari] ??= []).add(p);
    }
    return hasil;
  }
}

class ApiException implements Exception {
  const ApiException(this.kodeStatus);
  final int kodeStatus;

  @override
  String toString() => 'ApiException: kode status $kodeStatus';
}

class KunciApiKosong implements Exception {
  const KunciApiKosong();

  @override
  String toString() => 'KunciApiKosong';
}