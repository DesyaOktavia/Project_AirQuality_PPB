import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:project_kualitas_udara_ppb/config/api_config.dart';
import 'package:project_kualitas_udara_ppb/models/udara_model.dart';
import 'package:project_kualitas_udara_ppb/repositories/repositori_udara.dart';
import 'package:project_kualitas_udara_ppb/services/layanan_offline_mock.dart';
import 'package:project_kualitas_udara_ppb/services/layanan_openmeteo.dart';
import 'package:project_kualitas_udara_ppb/services/layanan_openweather.dart';
import 'package:project_kualitas_udara_ppb/viewmodels/udara_viewmodel.dart';

Map<String, dynamic> _butirOw(int dt, int aqi, double pm25, double pm10) => {
      'dt': dt,
      'main': {'aqi': aqi},
      'components': {
        'co': 200.0,
        'no': 0.0,
        'no2': 1.5,
        'o3': 60.0,
        'so2': 0.8,
        'pm2_5': pm25,
        'pm10': pm10,
        'nh3': 0.1,
      },
    };

void main() {
  group('1. Pengujian Formula ISPU Permen LHK No. P.14/2020', () {
    test('Kalkulasi ISPU untuk PM2.5 dan PM10 normal', () {
      expect(hitungIspu(pm25: 10, pm10: 10), equals(32));
      expect(hitungIspu(pm25: 20, pm10: 40), equals(56));
      expect(hitungIspu(pm25: 300, pm10: 10), equals(340));
    });

    test('Memilih parameter terburuk antara PM2.5 dan PM10', () {
      expect(hitungIspu(pm25: 5, pm10: 100), equals(75));
    });

    test('Konversi ISPU ke Kategori TingkatUdara', () {
      expect(TingkatUdara.dariIspu(0), equals(TingkatUdara.baik));
      expect(TingkatUdara.dariIspu(50), equals(TingkatUdara.baik));
      expect(TingkatUdara.dariIspu(51), equals(TingkatUdara.sedang));
      expect(TingkatUdara.dariIspu(100), equals(TingkatUdara.sedang));
      expect(TingkatUdara.dariIspu(101), equals(TingkatUdara.tidakSehat));
      expect(TingkatUdara.dariIspu(200), equals(TingkatUdara.tidakSehat));
      expect(TingkatUdara.dariIspu(201), equals(TingkatUdara.sangatTidakSehat));
      expect(TingkatUdara.dariIspu(300), equals(TingkatUdara.sangatTidakSehat));
      expect(TingkatUdara.dariIspu(301), equals(TingkatUdara.berbahaya));
    });
  });

  group('2. Pengujian Entitas & Wilayah Kaltim', () {
    test('Cakupan 10 Kecamatan Kota Samarinda', () {
      final List<Kecamatan> sam = Kecamatan.perKota(KotaInduk.samarinda);
      expect(sam.length, equals(10));
      expect(sam.map((k) => k.nama), containsAll([
        'Loa Janan Ilir',
        'Palaran',
        'Samarinda Ilir',
        'Samarinda Kota',
        'Samarinda Seberang',
        'Samarinda Ulu',
        'Samarinda Utara',
        'Sambutan',
        'Sungai Kunjang',
        'Sungai Pinang',
      ]));
    });

    test('Cakupan 6 Kecamatan Kota Balikpapan', () {
      final List<Kecamatan> bkp = Kecamatan.perKota(KotaInduk.balikpapan);
      expect(bkp.length, equals(6));
      expect(bkp.map((k) => k.nama), containsAll([
        'Balikpapan Barat',
        'Balikpapan Kota',
        'Balikpapan Selatan',
        'Balikpapan Tengah',
        'Balikpapan Timur',
        'Balikpapan Utara',
      ]));
    });

    test('Cakupan 3 Kecamatan Kota Bontang', () {
      final List<Kecamatan> btg = Kecamatan.perKota(KotaInduk.bontang);
      expect(btg.length, equals(3));
      expect(btg.map((k) => k.nama), containsAll([
        'Bontang Barat',
        'Bontang Selatan',
        'Bontang Utara',
      ]));
    });

    test('Total 19 Kecamatan di 3 Kota Kaltim', () {
      expect(Kecamatan.values.length, equals(19));
    });
  });

  group('3. Pengujian Layanan REST API & Offline Mock', () {
    test('LayananOfflineMock menghasilkan data valid Kaltim', () async {
      final mock = LayananOfflineMock();
      final DataUdara result = await mock.ambil(Kecamatan.samarindaKota);
      expect(result.kecamatan, equals(Kecamatan.samarindaKota));
      expect(result.sumber, equals(SumberData.offlineMock));
      expect(result.prakiraan.length, equals(48));
      expect(result.saatIni.ispu, greaterThan(0));
    });

    test('LayananOpenWeather memproses data JSON dengan benar', () async {
      final int dasar = DateTime.utc(2026, 10, 15).millisecondsSinceEpoch ~/ 1000;
      final mockClient = MockClient((req) async {
        final bool isForecast = req.url.path.endsWith('/forecast');
        final Map<String, dynamic> payload = isForecast
            ? {
                'coord': [117.15, -0.5],
                'list': [
                  for (int i = 0; i < 24; i++)
                    _butirOw(dasar + i * 3600, 2, 20.0 + i, 40.0),
                ],
              }
            : {
                'coord': [117.15, -0.5],
                'list': [_butirOw(dasar, 2, 25.0, 45.0)],
              };
        return http.Response(jsonEncode(payload), 200);
      });

      final owService = LayananOpenWeather(kunci: 'kunci-tes', klien: mockClient);
      final repo = RepositoriUdaraPintar(layananOpenWeather: owService);
      repo.modeSumber = ModeSumber.openWeather;

      final DataUdara data = await repo.ambil(Kecamatan.samarindaKota);
      expect(data.sumber, equals(SumberData.openWeather));
      expect(data.saatIni.pm25, equals(25.0));
      expect(data.prakiraan.length, equals(24));
    });

    test('LayananOpenMeteo memproses JSON real-time Open-Meteo', () async {
      final mockClient = MockClient((req) async {
        final Map<String, dynamic> payload = {
          'current': {
            'pm2_5': 18.5,
            'pm10': 35.0,
            'ozone': 50.0,
            'nitrogen_dioxide': 12.0,
            'sulphur_dioxide': 5.0,
            'carbon_monoxide': 300.0,
          },
          'hourly': {
            'time': ['2026-11-11T12:00', '2026-11-11T13:00'],
            'pm2_5': [18.5, 22.0],
            'pm10': [35.0, 40.0],
            'ozone': [50.0, 52.0],
            'nitrogen_dioxide': [12.0, 14.0],
            'sulphur_dioxide': [5.0, 6.0],
            'carbon_monoxide': [300.0, 320.0],
          }
        };
        return http.Response(jsonEncode(payload), 200);
      });

      final omService = LayananOpenMeteo(klien: mockClient);
      final DataUdara data = await omService.ambil(Kecamatan.balikpapanKota);

      expect(data.sumber, equals(SumberData.openMeteo));
      expect(data.saatIni.pm25, equals(18.5));
      expect(data.prakiraan.length, equals(2));
    });
  });

  group('4. Pengujian Smart Auto-Fallback Repositori Udara', () {
    test('Beralih dari OpenWeather ke Open-Meteo jika OpenWeather error', () async {
      final mockOwClient = MockClient((req) async => http.Response('Error', 500));
      final mockOmClient = MockClient((req) async {
        final payload = {
          'current': {'pm2_5': 12.0, 'pm10': 25.0},
          'hourly': {
            'time': ['2026-11-11T12:00'],
            'pm2_5': [12.0],
            'pm10': [25.0],
          }
        };
        return http.Response(jsonEncode(payload), 200);
      });

      final owService = LayananOpenWeather(kunci: 'kunci-rusak', klien: mockOwClient);
      final omService = LayananOpenMeteo(klien: mockOmClient);

      final repo = RepositoriUdaraPintar(
        layananOpenWeather: owService,
        layananOpenMeteo: omService,
      );
      repo.modeSumber = ModeSumber.otomatis;

      final DataUdara result = await repo.ambil(Kecamatan.bontangBarat);
      expect(result.sumber, equals(SumberData.openMeteo));
      expect(result.catatanSumber, contains('Otomatis beralih ke Open-Meteo'));
    });

    test('Beralih ke Mode Offline jika semua server REST API bermasalah', () async {
      final mockOwClient = MockClient((req) async => http.Response('Error', 500));
      final mockOmClient = MockClient((req) async => http.Response('Error', 500));

      final owService = LayananOpenWeather(kunci: 'kunci-rusak', klien: mockOwClient);
      final omService = LayananOpenMeteo(klien: mockOmClient);
      final mockService = LayananOfflineMock();

      final repo = RepositoriUdaraPintar(
        layananOpenWeather: owService,
        layananOpenMeteo: omService,
        layananOfflineMock: mockService,
      );
      repo.modeSumber = ModeSumber.otomatis;

      final DataUdara result = await repo.ambil(Kecamatan.samarindaUlu);
      expect(result.sumber, equals(SumberData.offlineMock));
      expect(result.catatanSumber, contains('Jaringan Offline'));
    });
  });

  group('5. Pengujian State Management UdaraViewModel (MVVM)', () {
    test('Pindah Kota dan Kecamatan memperbarui State', () async {
      final mockRepo = RepositoriUdaraPintar(
        layananOpenWeather: LayananOpenWeather(kunci: 'tes'),
        layananOfflineMock: LayananOfflineMock(),
      );
      mockRepo.modeSumber = ModeSumber.offlineMock;

      final vm = UdaraViewModel(repositori: mockRepo);
      await vm.muat();

      expect(vm.kotaTerpilih, equals(KotaInduk.samarinda));
      expect(vm.kecamatanTerpilih, equals(Kecamatan.samarindaKota));
      expect(vm.status, equals(StatusMuat.berhasil));

      vm.pilihKota(KotaInduk.balikpapan);
      await vm.muat();

      expect(vm.kotaTerpilih, equals(KotaInduk.balikpapan));
      expect(vm.kecamatanTerpilih, equals(Kecamatan.balikpapanBarat));

      vm.pilihKecamatan(Kecamatan.balikpapanUtara);
      await vm.muat();

      expect(vm.kecamatanTerpilih, equals(Kecamatan.balikpapanUtara));
    });

    test('Toggle Mode Gelap', () {
      final mockRepo = RepositoriUdaraPintar(
        layananOpenWeather: LayananOpenWeather(kunci: 'tes'),
      );
      final vm = UdaraViewModel(repositori: mockRepo);

      expect(vm.modeGelap, isFalse);
      vm.toggleModeGelap();
      expect(vm.modeGelap, isTrue);
      vm.toggleModeGelap();
      expect(vm.modeGelap, isFalse);
    });

    test('Update Custom API Key', () {
      final ow = LayananOpenWeather(kunci: kunciOpenWeatherDefault);
      final mockRepo = RepositoriUdaraPintar(layananOpenWeather: ow);
      final vm = UdaraViewModel(repositori: mockRepo);
      vm.ubahModeSumber(ModeSumber.offlineMock);

      vm.updateKunciCustom('kunci-baru-123');
      expect(vm.kunciCustom, equals('kunci-baru-123'));
      expect(ow.kunci, equals('kunci-baru-123'));
    });
  });
}
