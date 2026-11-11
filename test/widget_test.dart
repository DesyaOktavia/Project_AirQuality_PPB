import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:project_kualitas_udara_ppb/main.dart';

Widget buatWidgetPengujianAplikasi() {
  final offlineMock = LayananOfflineMock();
  final repo = RepositoriUdaraPintar(
    layananOpenWeather: LayananOpenWeather(kunci: 'kunci-uji'),
    layananOpenMeteo: LayananOpenMeteo(),
    layananOfflineMock: offlineMock,
  );
  repo.modeSumber = ModeSumber.offlineMock;

  return MultiProvider(
    providers: [
      Provider<LayananOfflineMock>.value(value: offlineMock),
      Provider<RepositoriUdaraPintar>.value(value: repo),
      Provider<RepositoriUdara>.value(value: repo),
      ChangeNotifierProvider<UdaraViewModel>(
        create: (_) => UdaraViewModel(repositori: repo)..muat(),
      ),
    ],
    child: const AplikasiUdara(),
  );
}

void main() {
  testWidgets('1. Verifikasi Render Tampilan Utama Dashboard Udara Kaltim',
      (WidgetTester tester) async {
    await tester.pumpWidget(buatWidgetPengujianAplikasi());
    await tester.pumpAndSettle();

    // Verifikasi Nama Kecamatan dan Kota pada Appbar dan Header
    expect(find.text('Kecamatan Samarinda Kota'), findsWidgets);
    expect(find.text('Kota Samarinda, Kalimantan Timur'), findsOneWidget);

    // Verifikasi Tab Nama Kota di Navigasi
    expect(find.text('Samarinda'), findsOneWidget);
    expect(find.text('Balikpapan'), findsOneWidget);
    expect(find.text('Bontang'), findsOneWidget);

    // Verifikasi Elemen Kartu Utama ISPU
    expect(find.text('ISPU'), findsOneWidget);
    expect(find.textContaining('Saran Kesehatan:'), findsOneWidget);
    expect(find.textContaining('Koordinat:'), findsOneWidget);

    // Verifikasi Seksi Kandungan Polutan
    expect(find.text('Kandungan Polutan (µg/m³)'), findsOneWidget);
    expect(find.textContaining('PM2.5 (Partikel Halus)'), findsOneWidget);
    expect(find.textContaining('PM10 (Partikel Kasar)'), findsOneWidget);
    expect(find.textContaining('Ozon (O₃)'), findsOneWidget);
    expect(find.textContaining('Nitrogen Dioksida (NO₂)'), findsOneWidget);
    expect(find.textContaining('Sulfur Dioksida (SO₂)'), findsOneWidget);
    expect(find.textContaining('Karbon Monoksida (CO)'), findsOneWidget);

    // Verifikasi Tren 24 Jam & Prakiraan Hari
    expect(find.text('Tren 24 Jam ke Depan'), findsOneWidget);
    expect(find.textContaining('Prakiraan'), findsOneWidget);
  });

  testWidgets('2. Verifikasi Navigasi Pindah Kota dan Kecamatan',
      (WidgetTester tester) async {
    await tester.pumpWidget(buatWidgetPengujianAplikasi());
    await tester.pumpAndSettle();

    // Tentukan Tab Balikpapan dan Klik
    final tabBalikpapan = find.text('Balikpapan');
    expect(tabBalikpapan, findsOneWidget);
    await tester.tap(tabBalikpapan);
    await tester.pumpAndSettle();

    // Verifikasi Kecamatan pertama Balikpapan aktif
    expect(find.text('Balikpapan Barat'), findsWidgets);

    // Tentukan Tab Bontang dan Klik
    final tabBontang = find.text('Bontang');
    expect(tabBontang, findsOneWidget);
    await tester.tap(tabBontang);
    await tester.pumpAndSettle();

    // Verifikasi Kecamatan pertama Bontang aktif
    expect(find.text('Bontang Barat'), findsWidgets);
  });

  testWidgets('3. Verifikasi Modal Edukasi ISPU & Modal Pengaturan API',
      (WidgetTester tester) async {
    await tester.pumpWidget(buatWidgetPengujianAplikasi());
    await tester.pumpAndSettle();

    // Klik Tombol Edukasi ISPU di AppBar
    final tombolEdukasi = find.byIcon(Icons.info_outline_rounded);
    expect(tombolEdukasi, findsOneWidget);
    await tester.tap(tombolEdukasi);
    await tester.pumpAndSettle();

    // Verifikasi Modal Edukasi Terbuka
    expect(find.text('Tentang ISPU Permen LHK'), findsOneWidget);
    expect(find.text('0 - 50'), findsOneWidget);

    // Tutup Modal Edukasi
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();

    // Klik Tombol Pengaturan di AppBar
    final tombolPengaturan = find.byIcon(Icons.settings_outlined);
    expect(tombolPengaturan, findsOneWidget);
    await tester.tap(tombolPengaturan);
    await tester.pumpAndSettle();

    // Verifikasi Modal Pengaturan Terbuka
    expect(find.text('Pengaturan Sumber Data & API'), findsOneWidget);
    expect(find.textContaining('Otomatis'), findsWidgets);

    // Tutup Modal Pengaturan
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
  });

  testWidgets('4. Verifikasi Pop-up Dialog Polutan PM2.5',
      (WidgetTester tester) async {
    await tester.pumpWidget(buatWidgetPengujianAplikasi());
    await tester.pumpAndSettle();

    // Klik Kartu Polutan PM2.5
    final kartuPm25 = find.textContaining('PM2.5 (Partikel Halus)');
    expect(kartuPm25, findsOneWidget);
    await tester.tap(kartuPm25);
    await tester.pumpAndSettle();

    // Verifikasi Dialog Penjelasan Terbuka
    expect(find.textContaining('Partikel udara berukuran <2.5 mikron'),
        findsOneWidget);

    // Tutup Dialog
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
  });

  testWidgets('5. Verifikasi Fitur Toggle Mode Gelap',
      (WidgetTester tester) async {
    await tester.pumpWidget(buatWidgetPengujianAplikasi());
    await tester.pumpAndSettle();

    // Klik Tombol Mode Gelap di AppBar
    final tombolDark = find.byIcon(Icons.dark_mode_rounded);
    expect(tombolDark, findsOneWidget);
    await tester.tap(tombolDark);
    await tester.pumpAndSettle();

    // Verifikasi Ikon Berubah ke Light Mode
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
  });
}
