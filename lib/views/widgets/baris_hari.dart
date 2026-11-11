import 'package:flutter/material.dart';

import '../../models/udara_model.dart';
import 'kartu_utama.dart';

class BarisHari extends StatelessWidget {
  const BarisHari({super.key, required this.namaHari, required this.titik});

  final String namaHari;
  final List<PengamatanUdara> titik;

  @override
  Widget build(BuildContext context) {
    final PengamatanUdara terburuk = titik.reduce(
          (a, b) => a.ispu >= b.ispu ? a : b,
    );
    final double pm25Maks = titik
        .map((p) => p.pm25)
        .reduce((a, b) => a > b ? a : b);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: terburuk.tingkat.warna.withAlpha(40),
        child: Icon(terburuk.tingkat.ikon, color: terburuk.tingkat.warna),
      ),
      title: Text(
        namaHari,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Kondisi: ${terburuk.tingkat.label} · PM2.5 maks ${angkaRapi(pm25Maks)} µg/m³',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: terburuk.tingkat.warna.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'ISPU ${terburuk.ispu}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: terburuk.tingkat.warna,
          ),
        ),
      ),
    );
  }
}
