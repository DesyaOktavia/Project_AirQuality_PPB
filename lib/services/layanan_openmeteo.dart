import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/udara_model.dart';

/// Layanan Klien REST API Open-Meteo (Cadangan Bebas CORS & Tanpa Key)
class LayananOpenMeteo {
  LayananOpenMeteo({
    http.Client? klien,
    this.batasWaktu = const Duration(seconds: 8),
  }) : _klien = klien ?? http.Client();

  final http.Client _klien;
  final Duration batasWaktu;

  Future<DataUdara> ambil(Kecamatan kec) async {
    final Uri alamat = Uri.https(
      'air-quality-api.open-meteo.com',
      '/v1/air-quality',
      {
        'latitude': '${kec.lintang}',
        'longitude': '${kec.bujur}',
        'current':
        'pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone',
        'hourly':
        'pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone',
        'forecast_days': '4',
      },
    );

    debugPrint('GET Open-Meteo (${kec.nama}, ${kec.kota.nama})');

    final http.Response respons = await _klien
        .get(alamat, headers: {'Accept': 'application/json'})
        .timeout(batasWaktu);

    if (respons.statusCode != 200) {
      throw ApiException(respons.statusCode);
    }

    final Map<String, dynamic> json =
    jsonDecode(utf8.decode(respons.bodyBytes));
    return _parseOpenMeteo(json, kec);
  }

  DataUdara _parseOpenMeteo(Map<String, dynamic> json, Kecamatan kec) {
    if (!json.containsKey('current') || !json.containsKey('hourly')) {
      throw const FormatException('Format data Open-Meteo tidak sesuai');
    }

    final Map<String, dynamic> cur = json['current'];
    final double pm25SaatIni = _angka(cur['pm2_5']) ?? 15.0;
    final double pm10SaatIni = _angka(cur['pm10']) ?? 30.0;
    final int ispuSaatIni = hitungIspu(pm25: pm25SaatIni, pm10: pm10SaatIni);

    int aqiSaatIni = 1;
    if (ispuSaatIni > 300) {
      aqiSaatIni = 5;
    } else if (ispuSaatIni > 200) {
      aqiSaatIni = 4;
    } else if (ispuSaatIni > 100) {
      aqiSaatIni = 3;
    } else if (ispuSaatIni > 50) {
      aqiSaatIni = 2;
    }

    final DateTime sekarangUtc = DateTime.now().toUtc();
    final PengamatanUdara pengamatanSaatIni = PengamatanUdara(
      waktuUtc: sekarangUtc,
      waktuLokal: sekarangUtc.add(Duration(hours: kec.kota.zonaJam)),
      aqi: aqiSaatIni,
      ispu: ispuSaatIni,
      pm25: pm25SaatIni,
      pm10: pm10SaatIni,
      o3: _angka(cur['ozone']),
      no2: _angka(cur['nitrogen_dioxide']),
      so2: _angka(cur['sulphur_dioxide']),
      co: _angka(cur['carbon_monoxide']),
    );

    final Map<String, dynamic> hourly = json['hourly'];
    final List<dynamic> times = hourly['time'] ?? [];
    final List<dynamic> pm25List = hourly['pm2_5'] ?? [];
    final List<dynamic> pm10List = hourly['pm10'] ?? [];
    final List<dynamic> o3List = hourly['ozone'] ?? [];
    final List<dynamic> no2List = hourly['nitrogen_dioxide'] ?? [];
    final List<dynamic> so2List = hourly['sulphur_dioxide'] ?? [];
    final List<dynamic> coList = hourly['carbon_monoxide'] ?? [];

    final List<PengamatanUdara> prakiraan = [];
    for (int i = 0; i < times.length; i++) {
      final String? tStr = times[i]?.toString();
      if (tStr == null) continue;
      final DateTime? utc = DateTime.tryParse('${tStr}Z');
      if (utc == null) continue;

      final double pm25 = (i < pm25List.length ? _angka(pm25List[i]) : null) ?? 15.0;
      final double pm10 = (i < pm10List.length ? _angka(pm10List[i]) : null) ?? 30.0;
      final int ispu = hitungIspu(pm25: pm25, pm10: pm10);
      int aqi = 1;
      if (ispu > 300) {
        aqi = 5;
      } else if (ispu > 200) {
        aqi = 4;
      } else if (ispu > 100) {
        aqi = 3;
      } else if (ispu > 50) {
        aqi = 2;
      }

      prakiraan.add(
        PengamatanUdara(
          waktuUtc: utc,
          waktuLokal: utc.add(Duration(hours: kec.kota.zonaJam)),
          aqi: aqi,
          ispu: ispu,
          pm25: pm25,
          pm10: pm10,
          o3: i < o3List.length ? _angka(o3List[i]) : null,
          no2: i < no2List.length ? _angka(no2List[i]) : null,
          so2: i < so2List.length ? _angka(so2List[i]) : null,
          co: i < coList.length ? _angka(coList[i]) : null,
        ),
      );
    }

    return DataUdara(
      kecamatan: kec,
      saatIni: pengamatanSaatIni,
      prakiraan: prakiraan,
      sumber: SumberData.openMeteo,
      catatanSumber: 'Data diperbarui secara real-time dari server Open-Meteo',
    );
  }

  double? _angka(Object? nilai) => nilai is num ? nilai.toDouble() : null;

  void tutup() => _klien.close();
}