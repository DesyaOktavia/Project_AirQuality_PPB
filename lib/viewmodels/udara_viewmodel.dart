import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/udara_model.dart';
import '../repositories/repositori_udara.dart';

enum StatusMuat { memuat, berhasil, gagal }

const String pesanKunciKosong =
    'API key OpenWeather belum diisi. Isi di pengaturan aplikasi atau lib/config/api_config.dart.';

String pesanRamah(Object galat) {
  return switch (galat) {
    KunciApiKosong() => pesanKunciKosong,
    TimeoutException() =>
    'Server OpenWeather terlalu lama menjawab. Coba lagi atau pilih mode Open-Meteo.',
    ApiException(kodeStatus: 401) =>
    'API key ditolak (401). Periksa key Anda atau gunakan mode cadangan Open-Meteo.',
    ApiException(kodeStatus: 429) =>
    'Terlalu banyak permintaan ke OpenWeather (429). Tunggu sebentar.',
    ApiException(kodeStatus: >= 500) =>
    'Server OpenWeather sedang bermasalah. Coba lagi nanti.',
    ApiException() => 'Permintaan data ditolak server OpenWeather.',
    FormatException() => 'Format data dari server tidak bisa dibaca.',
    http.ClientException() =>
    'Tidak dapat terhubung. Periksa koneksi internet Anda.',
    _ => 'Terjadi kesalahan yang tidak terduga.',
  };
}

/// ViewModel Aplikasi Udara Kaltim
class UdaraViewModel extends ChangeNotifier {
  UdaraViewModel({required this.repositori});

  final RepositoriUdaraPintar repositori;

  KotaInduk _kotaTerpilih = KotaInduk.samarinda;
  Kecamatan _kecamatanTerpilih = Kecamatan.samarindaKota;
  StatusMuat _status = StatusMuat.memuat;
  DataUdara? _data;
  DateTime? _diperbarui;
  String _pesanGalat = '';
  int _nomorPermintaan = 0;
  bool _sudahDibuang = false;
  bool _modeGelap = false;
  String _kunciCustom = kunciOpenWeatherDefault;

  KotaInduk get kotaTerpilih => _kotaTerpilih;
  Kecamatan get kecamatanTerpilih => _kecamatanTerpilih;
  StatusMuat get status => _status;
  DataUdara? get data => _data;
  DateTime? get diperbarui => _diperbarui;
  String get pesanGalat => _pesanGalat;
  bool get modeGelap => _modeGelap;
  String get kunciCustom => _kunciCustom;
  ModeSumber get modeSumber => repositori.modeSumber;

  void toggleModeGelap() {
    _modeGelap = !_modeGelap;
    notifyListeners();
  }

  void ubahModeSumber(ModeSumber mode) {
    repositori.modeSumber = mode;
    muat();
  }

  void updateKunciCustom(String keyBaru) {
    _kunciCustom = keyBaru.trim();
    repositori.layananOpenWeather.kunci = _kunciCustom;
    notifyListeners();
    muat();
  }

  void pilihKota(KotaInduk kota) {
    if (kota == _kotaTerpilih) return;
    _kotaTerpilih = kota;
    final List<Kecamatan> daftar = Kecamatan.perKota(kota);
    _kecamatanTerpilih = daftar.first;
    muat();
  }

  void pilihKecamatan(Kecamatan kec) {
    if (kec == _kecamatanTerpilih) return;
    _kecamatanTerpilih = kec;
    _kotaTerpilih = kec.kota;
    muat();
  }

  Future<void> muat({bool tampilkanMemuat = true}) async {
    final int nomor = ++_nomorPermintaan;
    if (tampilkanMemuat) {
      _status = StatusMuat.memuat;
      notifyListeners();
    }
    try {
      final DataUdara data = await repositori.ambil(_kecamatanTerpilih);
      if (_sudahDibuang || nomor != _nomorPermintaan) {
        return;
      }
      _data = data;
      _diperbarui = DateTime.now();
      _status = StatusMuat.berhasil;
    } catch (galat) {
      if (_sudahDibuang || nomor != _nomorPermintaan) {
        return;
      }

      debugPrint('Galat saat memuat data udara: ${galat.runtimeType}');
      _pesanGalat = pesanRamah(galat);
      _status = StatusMuat.gagal;
    }
    notifyListeners();
  }

  Future<void> segarkan() => muat(tampilkanMemuat: false);

  @override
  void dispose() {
    _sudahDibuang = true;
    super.dispose();
  }
}