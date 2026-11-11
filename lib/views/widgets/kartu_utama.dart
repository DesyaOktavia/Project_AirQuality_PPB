import 'package:flutter/material.dart';

import '../../models/udara_model.dart';

String duaDigit(int angka) => angka.toString().padLeft(2, '0');

String jamMenit(DateTime waktu) =>
    '${duaDigit(waktu.hour)}.${duaDigit(waktu.minute)}';

String angkaRapi(double? nilai) {
  if (nilai == null) return '-';
  return nilai >= 100 ? nilai.round().toString() : nilai.toStringAsFixed(1);
}

class KartuUtama extends StatelessWidget {
  const KartuUtama({
    super.key,
    required this.kecamatan,
    required this.pengamatan,
    required this.diperbarui,
  });

  final Kecamatan kecamatan;
  final PengamatanUdara pengamatan;
  final DateTime diperbarui;

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;
    final TextTheme gayaTeks = Theme.of(context).textTheme;
    final PengamatanUdara p = pengamatan;
    final TingkatUdara t = p.tingkat;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              t.warna.withAlpha(60),
              warna.surfaceContainerLow,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: t.warna),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Kec. ${kecamatan.nama}, ${kecamatan.kota.nama}',
                    style: gayaTeks.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: t.warna.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.warna.withAlpha(100)),
                  ),
                  child: Text(
                    'AQI: ${p.aqi}/5',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: t.warna,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: (p.ispu / 300).clamp(0.05, 1.0).toDouble(),
                    strokeWidth: 14,
                    strokeCap: StrokeCap.round,
                    color: t.warna,
                    backgroundColor: t.warna.withAlpha(40),
                    semanticsLabel: 'ISPU ${p.ispu}: ${t.label}',
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.ikon, size: 44, color: t.warna),
                        Text(
                          '${p.ispu}',
                          style: gayaTeks.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'ISPU',
                          style: gayaTeks.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Udara ${t.label}',
              style: gayaTeks.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: t.warna,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'PM2.5: ${angkaRapi(p.pm25)} µg/m³ · PM10: ${angkaRapi(p.pm10)} µg/m³',
              style: gayaTeks.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: warna.surface.withAlpha(220),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.warna.withAlpha(50)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.health_and_safety_outlined,
                      size: 22, color: t.warna),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saran Kesehatan:',
                          style: gayaTeks.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: t.warna,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(t.saran, style: gayaTeks.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Koordinat: ${kecamatan.lintang}, ${kecamatan.bujur}',
                  style: gayaTeks.bodySmall,
                ),
                Text(
                  '${jamMenit(p.waktuLokal)} ${kecamatan.kota.zonaNama}',
                  style: gayaTeks.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
