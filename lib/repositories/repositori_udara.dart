import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/udara_model.dart';
import '../services/layanan_offline_mock.dart';
import '../services/layanan_openmeteo.dart';
import '../services/layanan_openweather.dart';

/// Antarmuka Repositori Udara
abstract class RepositoriUdara {
  Future<DataUdara> ambil(Kecamatan kec);
}

/// Implementasi Repositori Udara Pintar dengan Auto-Fallback
class RepositoriUdaraPintar implements RepositoriUdara {
  RepositoriUdaraPintar({
    required this.layananOpenWeather,
    LayananOpenMeteo? layananOpenMeteo,
    LayananOfflineMock? layananOfflineMock,
  })  : _layananOpenMeteo = layananOpenMeteo ?? LayananOpenMeteo(),
        _layananOfflineMock = layananOfflineMock ?? LayananOfflineMock();

  final LayananOpenWeather layananOpenWeather;
  final LayananOpenMeteo _layananOpenMeteo;
  final LayananOfflineMock _layananOfflineMock;

  ModeSumber modeSumber = ModeSumber.otomatis;

  @override
  Future<DataUdara> ambil(Kecamatan kec) async {
    switch (modeSumber) {
      case ModeSumber.openWeather:
        return await _ambilDariOpenWeather(kec);
      case ModeSumber.openMeteo:
        return await _layananOpenMeteo.ambil(kec);
      case ModeSumber.offlineMock:
        return await _layananOfflineMock.ambil(kec);
      case ModeSumber.otomatis:
        try {
          return await _ambilDariOpenWeather(kec);
        } catch (galatOw) {
          debugPrint(
              'OpenWeather gagal ($galatOw). Otomatis mencoba Open-Meteo...');
          try {
            final DataUdara dMeteo = await _layananOpenMeteo.ambil(kec);
            return DataUdara(
              kecamatan: dMeteo.kecamatan,
              saatIni: dMeteo.saatIni,
              prakiraan: dMeteo.prakiraan,
              sumber: SumberData.openMeteo,
              catatanSumber:
              'Otomatis beralih ke Open-Meteo (OpenWeather timeout/CORS)',
            );
          } catch (galatMeteo) {
            debugPrint(
                'Open-Meteo juga bermasalah ($galatMeteo). Beralih ke Mode Offline...');
            final DataUdara dMock = await _layananOfflineMock.ambil(kec);
            return DataUdara(
              kecamatan: dMock.kecamatan,
              saatIni: dMock.saatIni,
              prakiraan: dMock.prakiraan,
              sumber: SumberData.offlineMock,
              catatanSumber:
              'Otomatis beralih ke Mode Simulasi (Jaringan Offline)',
            );
          }
        }
    }
  }

  Future<DataUdara> _ambilDariOpenWeather(Kecamatan kec) async {
    final List<Map<String, dynamic>> hasil =
    await Future.wait<Map<String, dynamic>>([
      layananOpenWeather.ambilSaatIni(kec),
      layananOpenWeather.ambilPrakiraan(kec),
    ]);

    final List<PengamatanUdara> saatIni = _daftar(hasil[0], kec);
    final List<PengamatanUdara> prakiraan = _daftar(hasil[1], kec)
      ..sort((a, b) => a.waktuUtc.compareTo(b.waktuUtc));

    return DataUdara(
      kecamatan: kec,
      saatIni: saatIni.first,
      prakiraan: prakiraan,
      sumber: SumberData.openWeather,
      catatanSumber: 'Data resmi dari OpenWeather API',
    );
  }

  List<PengamatanUdara> _daftar(Map<String, dynamic> json, Kecamatan kec) {
    if (json case {'list': final List<dynamic> daftar} when daftar.isNotEmpty) {
      return [for (final dynamic butir in daftar) _butir(butir, kec)];
    }
    throw const FormatException('Data udara kosong atau bentuknya salah');
  }

  PengamatanUdara _butir(Object? butir, Kecamatan kec) {
    if (butir case {
    'dt': final num dt,
    'main': {'aqi': final num aqi},
    'components': final Map<String, dynamic> k,
    }) {
      final double? pm25 = _angka(k['pm2_5']);
      final double? pm10 = _angka(k['pm10']);
      if (pm25 == null || pm10 == null) {
        throw const FormatException('Data PM2.5/PM10 tidak ada');
      }
      final DateTime utc = DateTime.fromMillisecondsSinceEpoch(
        dt.toInt() * 1000,
        isUtc: true,
      );
      return PengamatanUdara(
        waktuUtc: utc,
        waktuLokal: utc.add(Duration(hours: kec.kota.zonaJam)),
        aqi: aqi.toInt(),
        ispu: hitungIspu(pm25: pm25, pm10: pm10),
        pm25: pm25,
        pm10: pm10,
        o3: _angka(k['o3']),
        no2: _angka(k['no2']),
        so2: _angka(k['so2']),
        co: _angka(k['co']),
      );
    }
    throw const FormatException('Bentuk data satu titik salah');
  }

  double? _angka(Object? nilai) => nilai is num ? nilai.toDouble() : null;
}

class RepositoriUdaraOpenWeather extends RepositoriUdaraPintar {
  RepositoriUdaraOpenWeather({required LayananOpenWeather layanan})
      : super(layananOpenWeather: layanan);
}