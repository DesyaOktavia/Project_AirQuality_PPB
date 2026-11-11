import 'package:flutter/material.dart';

import '../../models/udara_model.dart';

class SkalaUdara extends StatelessWidget {
  const SkalaUdara({super.key, required this.aktif});

  final TingkatUdara aktif;

  @override
  Widget build(BuildContext context) {
    final TextTheme gayaTeks = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            for (final TingkatUdara t in TingkatUdara.values)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: t == aktif ? 14 : 8,
                  decoration: BoxDecoration(
                    color: t.warna.withAlpha(t == aktif ? 255 : 80),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: t == aktif
                        ? [
                      BoxShadow(
                        color: t.warna.withAlpha(120),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                        : null,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final TingkatUdara t in TingkatUdara.values)
              Expanded(
                child: Text(
                  t.label,
                  textAlign: TextAlign.center,
                  style: gayaTeks.labelSmall?.copyWith(
                    fontWeight:
                    t == aktif ? FontWeight.bold : FontWeight.normal,
                    color: t == aktif ? t.warna : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
