import 'package:flutter/material.dart';

import '../../models/udara_model.dart';

class ModalEdukasiIspu extends StatelessWidget {
  const ModalEdukasiIspu({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme gayaTeks = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.school_rounded, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'Tentang ISPU Permen LHK',
                style: gayaTeks.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Indeks Standar Pencemar Udara (ISPU) adalah angka tanpa satuan yang menggambarkan kondisi kualitas udara ambien di lokasi tertentu berdasarkan dampak terhadap kesehatan manusia.',
          ),
          const SizedBox(height: 16),
          Text('Rentang Kategori ISPU:', style: gayaTeks.titleSmall),
          const SizedBox(height: 8),
          for (final TingkatUdara t in TingkatUdara.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: t.warna,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: Text(
                      t.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.warna,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t == TingkatUdara.baik
                          ? '0 - 50'
                          : t == TingkatUdara.sedang
                          ? '51 - 100'
                          : t == TingkatUdara.tidakSehat
                          ? '101 - 200'
                          : t == TingkatUdara.sangatTidakSehat
                          ? '201 - 300'
                          : '> 300',
                      style: gayaTeks.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mengerti'),
            ),
          ),
        ],
      ),
    );
  }
}
