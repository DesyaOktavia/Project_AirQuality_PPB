import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/udara_model.dart';
import '../viewmodels/udara_viewmodel.dart';
import 'widgets/banner_sumber_data.dart';
import 'widgets/baris_hari.dart';
import 'widgets/grid_polutan.dart';
import 'widgets/kartu_jam.dart';
import 'widgets/kartu_utama.dart';
import 'widgets/modal_edukasi.dart';
import 'widgets/modal_pengaturan.dart';
import 'widgets/pilihan_kota_kecamatan.dart';
import 'widgets/skala_udara.dart';

const List<String> namaHariIndonesia = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

/// Halaman Utama Aplikasi Udara
class HalamanUdara extends StatelessWidget {
  const HalamanUdara({super.key});

  @override
  Widget build(BuildContext context) {
    final UdaraViewModel vm = context.watch<UdaraViewModel>();

    final Widget isi = switch (vm.status) {
      StatusMuat.memuat => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data kualitas udara kecamatan...'),
          ],
        ),
      ),
      StatusMuat.gagal => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                vm.pesanGalat,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tips: Jika OpenWeather mengalami kendala/CORS, Anda bisa memilih mode Open-Meteo di Pengaturan.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.read<UdaraViewModel>().muat(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _tampilkanModalPengaturan(context),
                    icon: const Icon(Icons.settings),
                    label: const Text('Pengaturan API'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      StatusMuat.berhasil => RefreshIndicator(
        onRefresh: () => context.read<UdaraViewModel>().segarkan(),
        child: IsiUdara(data: vm.data!, diperbarui: vm.diperbarui!),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.air_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kecamatan ${vm.kecamatanTerpilih.nama}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${vm.kotaTerpilih.nama}, ${vm.kotaTerpilih.provinsi}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              vm.modeGelap
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: vm.modeGelap ? 'Mode Terang' : 'Mode Gelap',
            onPressed: () => context.read<UdaraViewModel>().toggleModeGelap(),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Edukasi ISPU',
            onPressed: () => _tampilkanModalEdukasi(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => _tampilkanModalPengaturan(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const PilihanKotaKecamatan(),
          Expanded(child: isi),
        ],
      ),
    );
  }

  void _tampilkanModalEdukasi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ModalEdukasiIspu(),
    );
  }

  void _tampilkanModalPengaturan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ModalPengaturan(),
    );
  }
}

class IsiUdara extends StatelessWidget {
  const IsiUdara({super.key, required this.data, required this.diperbarui});

  final DataUdara data;
  final DateTime diperbarui;

  String _namaHari(int urutan, DateTime tanggal) {
    if (urutan == 0) return 'Hari ini';
    if (urutan == 1) return 'Besok';
    return namaHariIndonesia[tanggal.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme gayaTeks = Theme.of(context).textTheme;
    final PengamatanUdara p = data.saatIni;
    final List<PengamatanUdara> mendatang = data.mendatang;
    final List<MapEntry<DateTime, List<PengamatanUdara>>> hari = data.perHari
        .entries
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            BannerSumberData(sumber: data.sumber, catatan: data.catatanSumber),
            const SizedBox(height: 12),
            KartuUtama(
                kecamatan: data.kecamatan, pengamatan: p, diperbarui: diperbarui),
            const SizedBox(height: 16),
            SkalaUdara(aktif: p.tingkat),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kandungan Polutan (µg/m³)', style: gayaTeks.titleMedium),
                TextButton.icon(
                  onPressed: () => _tampilkanModalEdukasi(context),
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: const Text('Info Standar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridPolutan(pengamatan: p),
            if (mendatang.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Tren 24 Jam ke Depan', style: gayaTeks.titleMedium),
              const SizedBox(height: 10),
              SizedBox(
                height: 136,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final PengamatanUdara j in mendatang)
                      KartuJam(pengamatan: j),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('Prakiraan ${hari.length} Hari', style: gayaTeks.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (int i = 0; i < hari.length; i++) ...[
                    BarisHari(
                      namaHari: _namaHari(i, hari[i].key),
                      titik: hari[i].value,
                    ),
                    if (i < hari.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh
                    .withAlpha(150),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Keterangan ISPU Permen LHK',
                        style: gayaTeks.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ISPU dihitung dari konsentrasi PM2.5 dan PM10 sesuai Permen LHK No. P.14/2020. Tarik layar ke bawah untuk menyegarkan data.',
                    style: gayaTeks.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tampilkanModalEdukasi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ModalEdukasiIspu(),
    );
  }
}