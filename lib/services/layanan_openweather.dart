import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/udara_model.dart';

/// Layanan Klien REST API OpenWeather
class LayananOpenWeather {
  LayananOpenWeather({
    required this.kunci,
    http.Client? klien,
    this.batasWaktu = const Duration(seconds: 8),
  }) : _klien = klien ?? http.Client();

  String kunci;
  final http.Client _klien;
  final Duration batasWaktu;

  Future<Map<String, dynamic>> ambilSaatIni(Kecamatan kec) =>
      _ambil('/data/2.5/air_pollution', kec);

  Future<Map<String, dynamic>> ambilPrakiraan(Kecamatan kec) =>
      _ambil('/data/2.5/air_pollution/forecast', kec);

  Future<Map<String, dynamic>> _ambil(String jalur, Kecamatan kec) async {
    if (kunci.isEmpty) {
      throw const KunciApiKosong();
    }
    final Uri alamat = Uri.https('api.openweathermap.org', jalur, {
      'lat': '${kec.lintang}',
      'lon': '${kec.bujur}',
      'appid': kunci,
    });

    debugPrint('GET OpenWeather $jalur (${kec.nama}, ${kec.kota.nama})');

    final http.Response respons = await _klien
        .get(alamat, headers: {'Accept': 'application/json'})
        .timeout(batasWaktu);

    if (respons.statusCode != 200) {
      throw ApiException(respons.statusCode);
    }

    return switch (jsonDecode(utf8.decode(respons.bodyBytes))) {
      final Map<String, dynamic> data => data,
      _ => throw const FormatException('Bentuk JSON tidak dikenal'),
    };
  }

  void tutup() => _klien.close();
}