import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'config/api_config.dart';
import 'models/udara_model.dart';
import 'repositories/repositori_udara.dart';
import 'services/layanan_offline_mock.dart';
import 'services/layanan_openmeteo.dart';
import 'services/layanan_openweather.dart';
import 'viewmodels/udara_viewmodel.dart';
import 'views/halaman_udara.dart';

// Re-export model dan komponen utama agar mudah diakses
export 'config/api_config.dart';
export 'models/udara_model.dart';
export 'repositories/repositori_udara.dart';
export 'services/layanan_offline_mock.dart';
export 'services/layanan_openmeteo.dart';
export 'services/layanan_openweather.dart';
export 'viewmodels/udara_viewmodel.dart';
export 'views/halaman_udara.dart';

// Kunci API OpenWeather default yang diambil dari api_config.dart
const String kunciOpenWeather = String.fromEnvironment(
  'OPENWEATHER_API_KEY',
  defaultValue: kunciOpenWeatherDefault,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Jalankan verifikasi pengujian fungsi internal saat aplikasi dimulai
  await jalankanUji();

  runApp(
    MultiProvider(
      providers: [
        Provider<LayananOpenWeather>(
          create: (BuildContext context) =>
              LayananOpenWeather(kunci: kunciOpenWeather),
          dispose: (BuildContext context, LayananOpenWeather layanan) =>
              layanan.tutup(),
        ),
        Provider<LayananOpenMeteo>(
          create: (BuildContext context) => LayananOpenMeteo(),
          dispose: (BuildContext context, LayananOpenMeteo layanan) =>
              layanan.tutup(),
        ),
        Provider<LayananOfflineMock>(
          create: (BuildContext context) => LayananOfflineMock(),
        ),
        Provider<RepositoriUdaraPintar>(
          create: (BuildContext context) => RepositoriUdaraPintar(
            layananOpenWeather: context.read<LayananOpenWeather>(),
            layananOpenMeteo: context.read<LayananOpenMeteo>(),
            layananOfflineMock: context.read<LayananOfflineMock>(),
          ),
        ),
        Provider<RepositoriUdara>(
          create: (BuildContext context) =>
              context.read<RepositoriUdaraPintar>(),
        ),
        ChangeNotifierProvider<UdaraViewModel>(
          create: (BuildContext context) => UdaraViewModel(
            repositori: context.read<RepositoriUdaraPintar>(),
          )..muat(),
        ),
      ],
      child: const AplikasiUdara(),
    ),
  );
}

/// Root Application Widget
class AplikasiUdara extends StatelessWidget {
  const AplikasiUdara({super.key});

  @override
  Widget build(BuildContext context) {
    final bool modeGelap = context.select((UdaraViewModel vm) => vm.modeGelap);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Pemantau Kualitas Udara Kalimantan Timur',
      themeMode: modeGelap ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const HalamanUdara(),
    );
  }
}

// --- LOGIKA PENGUJIAN UNIT INTERNAL ---

Map<String, dynamic> _butir(int dt, int aqi, double pm25, double pm10) => {
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

void periksa(String nama, Object? didapat, Object? diharapkan) {
  if (didapat == diharapkan) {
    debugPrint('LULUS  $nama');
  } else {
    debugPrint('GAGAL  $nama: diharapkan $diharapkan, hasilnya $didapat');
  }
}

UdaraViewModel _buatVm({String kunci = 'kunci-uji', int status = 200}) {
  return UdaraViewModel(
    repositori: RepositoriUdaraPintar(
      layananOpenWeather: LayananOpenWeather(
        kunci: kunci,
        klien: MockClient(
              (http.Request permintaan) async => http.Response('{}', status),
        ),
      ),
    ),
  );
}

Future<void> jalankanUji() async {
  periksa('ISPU PM2.5=10, PM10=10 -> 32',
      hitungIspu(pm25: 10, pm10: 10), 32);
  periksa('ISPU PM2.5=20, PM10=40 -> 56',
      hitungIspu(pm25: 20, pm10: 40), 56);
  periksa('ISPU PM2.5=300 -> 340',
      hitungIspu(pm25: 300, pm10: 10), 340);
  periksa('PM10 bisa jadi yang terburuk',
      hitungIspu(pm25: 5, pm10: 100), 75);
  periksa('ISPU 50 = baik', TingkatUdara.dariIspu(50), TingkatUdara.baik);
  periksa('ISPU 51 = sedang', TingkatUdara.dariIspu(51), TingkatUdara.sedang);
  periksa('ISPU 150 = tidak sehat', TingkatUdara.dariIspu(150),
      TingkatUdara.tidakSehat);
  periksa('ISPU 250 = sangat tidak sehat', TingkatUdara.dariIspu(250),
      TingkatUdara.sangatTidakSehat);
  periksa('ISPU 301 = berbahaya', TingkatUdara.dariIspu(301),
      TingkatUdara.berbahaya);

  final int dasar =
      DateTime.utc(2026, 10, 15).millisecondsSinceEpoch ~/ 1000;
  final int sekarang = dasar + 4 * 3600;

  final List<http.Request> permintaan = [];
  final RepositoriUdaraPintar repo = RepositoriUdaraPintar(
    layananOpenWeather: LayananOpenWeather(
      kunci: 'kunci-uji',
      klien: MockClient((http.Request req) async {
        permintaan.add(req);
        final bool prakiraan = req.url.path.endsWith('/forecast');
        final Map<String, dynamic> isi = prakiraan
            ? {
          'coord': [117.15, -0.5],
          'list': [
            for (int i = 0; i < 30; i++)
              _butir(
                sekarang + i * 3600,
                2,
                i == 8 ? 120.0 : 20.0 + i,
                40.0,
              ),
          ],
        }
            : {
          'coord': [117.15, -0.5],
          'list': [_butir(sekarang, 2, 20.0, 40.0)],
        };
        return http.Response(jsonEncode(isi), 200);
      }),
    ),
  );
  repo.modeSumber = ModeSumber.openWeather;

  final DataUdara data = await repo.ambil(Kecamatan.samarindaKota);
  periksa('Dua permintaan dikirim', permintaan.length, 2);
  periksa('Alamat ke api.openweathermap.org', permintaan.first.url.host,
      'api.openweathermap.org');
  periksa('Lintang kecamatan dikirim',
      permintaan.first.url.queryParameters['lat'],
      '${Kecamatan.samarindaKota.lintang}');
  periksa('API key dikirim', permintaan.first.url.queryParameters['appid'],
      'kunci-uji');
  periksa('PM2.5 saat ini', data.saatIni.pm25, 20.0);
  periksa('ISPU saat ini', data.saatIni.ispu, 56);
  periksa('Kategori saat ini = sedang', data.saatIni.tingkat,
      TingkatUdara.sedang);
  periksa('Jam lokal WITA = 12', data.saatIni.waktuLokal.hour, 12);
  periksa('Prakiraan 30 titik', data.prakiraan.length, 30);
  periksa('Delapan titik tiap 3 jam', data.mendatang.length, 8);
  periksa('Titik pertama +3 jam', data.mendatang.first.waktuUtc,
      data.saatIni.waktuUtc.add(const Duration(hours: 3)));
  periksa('Dua hari', data.perHari.length, 2);
  periksa('PM2.5 120 = tidak sehat', data.prakiraan[8].tingkat,
      TingkatUdara.tidakSehat);

  final RepositoriUdaraPintar repoPerKec = RepositoriUdaraPintar(
    layananOpenWeather: LayananOpenWeather(
      kunci: 'kunci-uji',
      klien: MockClient((http.Request req) async {
        final double lintang = double.parse(req.url.queryParameters['lat']!);

        final Map<String, dynamic> isi = {
          'list': [_butir(sekarang, 2, 10 + lintang.abs() * 5, 20.0)],
        };
        return http.Response(jsonEncode(isi), 200);
      }),
    ),
  );
  repoPerKec.modeSumber = ModeSumber.openWeather;

  final DataUdara samarinda =
  await repoPerKec.ambil(Kecamatan.samarindaKota);
  final DataUdara balikpapan =
  await repoPerKec.ambil(Kecamatan.balikpapanKota);
  periksa('Samarinda dan Balikpapan beda PM2.5',
      samarinda.saatIni.pm25 != balikpapan.saatIni.pm25, true);

  final UdaraViewModel tanpaKunci = _buatVm(kunci: '');
  tanpaKunci.ubahModeSumber(ModeSumber.openWeather);
  await tanpaKunci.muat();
  periksa('Tanpa key: status gagal', tanpaKunci.status, StatusMuat.gagal);
  periksa('Tanpa key: pesan', tanpaKunci.pesanGalat, pesanKunciKosong);
  tanpaKunci.dispose();

  final UdaraViewModel ditolak = _buatVm(status: 401);
  ditolak.ubahModeSumber(ModeSumber.openWeather);
  await ditolak.muat();
  periksa('Kode 401: status gagal', ditolak.status, StatusMuat.gagal);
  periksa('Kode 401: pesan', ditolak.pesanGalat,
      'API key ditolak (401). Periksa key Anda atau gunakan mode cadangan Open-Meteo.');
  ditolak.dispose();

  final UdaraViewModel rusak = _buatVm(status: 500);
  rusak.ubahModeSumber(ModeSumber.openWeather);
  await rusak.muat();
  periksa('Kode 500: pesan', rusak.pesanGalat,
      'Server OpenWeather sedang bermasalah. Coba lagi nanti.');
  rusak.dispose();
}
