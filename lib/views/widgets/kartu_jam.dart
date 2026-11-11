import 'package:flutter/material.dart';

import '../../models/udara_model.dart';
import 'kartu_utama.dart';

class KartuJam extends StatelessWidget {
  const KartuJam({super.key, required this.pengamatan});

  final PengamatanUdara pengamatan;

  @override
  Widget build(BuildContext context) {
    final TextTheme gayaTeks = Theme.of(context).textTheme;
    final PengamatanUdara p = pengamatan;
    final TingkatUdara t = p.tingkat;

    return Container(
      width: 96,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                jamMenit(p.waktuLokal),
                style: gayaTeks.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: t.warna.withAlpha(40),
                child: Icon(
                  t.ikon,
                  size: 22,
                  color: t.warna,
                ),
              ),
              Text(
                'ISPU ${p.ispu}',
                style: gayaTeks.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                t.label,
                style: gayaTeks.labelSmall?.copyWith(
                  fontSize: 10,
                  color: t.warna,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
