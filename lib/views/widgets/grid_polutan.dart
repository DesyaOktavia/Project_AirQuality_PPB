import 'package:flutter/material.dart';

import '../../models/udara_model.dart';
import 'kartu_utama.dart';

class GridPolutan extends StatelessWidget {
  const GridPolutan({super.key, required this.pengamatan});

  final PengamatanUdara pengamatan;

  @override
  Widget build(BuildContext context) {
    final PengamatanUdara p = pengamatan;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double lebar = constraints.maxWidth;
        int jumlahKolom = 2;
        double rasioAspek = 2.1;

        if (lebar > 900) {
          jumlahKolom = 3;
          rasioAspek = 2.8;
        } else if (lebar > 600) {
          jumlahKolom = 3;
          rasioAspek = 2.4;
        } else {
          jumlahKolom = 2;
          rasioAspek = 2.1;
        }

        return GridView.count(
          crossAxisCount: jumlahKolom,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: rasioAspek,
          children: [
            KotakPolutan(
              nama: 'PM2.5 (Partikel Halus)',
              nilai: angkaRapi(p.pm25),
              keterangan:
              '${(p.pm25 / 15).toStringAsFixed(1)}× batas WHO (15 µg/m³)',
              penjelasan:
              'Partikel udara berukuran <2.5 mikron. Dapat menembus paru-paru dan pembuluh darah.',
              warnaIndikator: p.pm25 > 55
                  ? Colors.red
                  : (p.pm25 > 15 ? Colors.amber : Colors.green),
            ),
            KotakPolutan(
              nama: 'PM10 (Partikel Kasar)',
              nilai: angkaRapi(p.pm10),
              keterangan:
              '${(p.pm10 / 45).toStringAsFixed(1)}× batas WHO (45 µg/m³)',
              penjelasan:
              'Debu kasar dan partikel debu jalanan berukuran <10 mikron.',
              warnaIndikator: p.pm10 > 150
                  ? Colors.red
                  : (p.pm10 > 45 ? Colors.amber : Colors.green),
            ),
            KotakPolutan(
              nama: 'Ozon (O₃)',
              nilai: angkaRapi(p.o3),
              penjelasan:
              'Gas ozon permukaan. Dapat iritasi saluran pernapasan pada kadar tinggi.',
            ),
            KotakPolutan(
              nama: 'Nitrogen Dioksida (NO₂)',
              nilai: angkaRapi(p.no2),
              penjelasan: 'Gas buang kendaraan bermotor dan emisi industri.',
            ),
            KotakPolutan(
              nama: 'Sulfur Dioksida (SO₂)',
              nilai: angkaRapi(p.so2),
              penjelasan: 'Hasil pembakaran bahan bakar fosil dan industri.',
            ),
            KotakPolutan(
              nama: 'Karbon Monoksida (CO)',
              nilai: angkaRapi(p.co),
              penjelasan:
              'Gas tidak berwarna dari pembakaran tidak sempurna kendaraan.',
            ),
          ],
        );
      },
    );
  }
}

class KotakPolutan extends StatelessWidget {
  const KotakPolutan({
    super.key,
    required this.nama,
    required this.nilai,
    this.keterangan,
    this.penjelasan,
    this.warnaIndikator,
  });

  final String nama;
  final String nilai;
  final String? keterangan;
  final String? penjelasan;
  final Color? warnaIndikator;

  @override
  Widget build(BuildContext context) {
    final TextTheme gayaTeks = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(120),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: penjelasan == null
            ? null
            : () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(nama),
              content: Text(penjelasan!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      nama,
                      style: gayaTeks.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (warnaIndikator != null)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: warnaIndikator,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              Text.rich(
                TextSpan(
                  text: nilai,
                  style: gayaTeks.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: ' µg/m³',
                      style: gayaTeks.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (keterangan != null)
                Text(
                  keterangan!,
                  style: gayaTeks.labelSmall?.copyWith(
                    color: warnaIndikator ?? Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  'Parameter Standar',
                  style: gayaTeks.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
