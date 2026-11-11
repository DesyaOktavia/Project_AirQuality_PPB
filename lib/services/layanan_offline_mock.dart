import 'dart:async';
import 'dart:math' as math;

import '../models/udara_model.dart';

/// Layanan Generator Data Simulasi Offline Kaltim
class LayananOfflineMock {
  Future<DataUdara> ambil(Kecamatan kec) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final DateTime sekarangUtc = DateTime.now().toUtc();
    final double offsetKec = (kec.index * 3.5);
    final double basisPm25 = ((kec.lintang.abs() * 12 + offsetKec) % 45.0) + 15.0;
    final double basisPm10 = basisPm25 * 1.5;

    final PengamatanUdara saatIni = PengamatanUdara(
      waktuUtc: sekarangUtc,
      waktuLokal: sekarangUtc.add(Duration(hours: kec.kota.zonaJam)),
      aqi: basisPm25 > 35 ? 3 : 2,
      ispu: hitungIspu(pm25: basisPm25, pm10: basisPm10),
      pm25: basisPm25,
      pm10: basisPm10,
      o3: 42.0,
      no2: 28.0,
      so2: 14.0,
      co: 420.0,
    );

    final List<PengamatanUdara> prakiraan = [];
    for (int i = 0; i < 48; i++) {
      final DateTime utc = sekarangUtc.add(Duration(hours: i));
      final double variasi = math.sin(i * 0.4) * 14.0;
      final double pm25 = (basisPm25 + variasi).clamp(6.0, 180.0);
      final double pm10 = (basisPm10 + variasi * 1.4).clamp(12.0, 250.0);

      prakiraan.add(
        PengamatanUdara(
          waktuUtc: utc,
          waktuLokal: utc.add(Duration(hours: kec.kota.zonaJam)),
          aqi: pm25 > 50 ? 3 : 2,
          ispu: hitungIspu(pm25: pm25, pm10: pm10),
          pm25: pm25,
          pm10: pm10,
          o3: 40.0 + variasi,
          no2: 25.0 + variasi * 0.5,
          so2: 12.0,
          co: 380.0 + variasi * 12,
        ),
      );
    }

    return DataUdara(
      kecamatan: kec,
      saatIni: saatIni,
      prakiraan: prakiraan,
      sumber: SumberData.offlineMock,
      catatanSumber: 'Mode Simulasi Offline (Tersedia tanpa koneksi internet)',
    );
  }
}