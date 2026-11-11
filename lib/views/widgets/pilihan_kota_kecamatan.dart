import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/udara_model.dart';
import '../../viewmodels/udara_viewmodel.dart';

class PilihanKotaKecamatan extends StatelessWidget {
  const PilihanKotaKecamatan({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UdaraViewModel>();
    final KotaInduk kotaAktif = vm.kotaTerpilih;
    final Kecamatan kecAktif = vm.kecamatanTerpilih;
    final List<Kecamatan> daftarKec = Kecamatan.perKota(kotaAktif);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab Pemilihan Kota (Samarinda, Balikpapan, Bontang)
              Row(
                children: [
                  for (final KotaInduk k in KotaInduk.values)
                    Expanded(
                      child: InkWell(
                        onTap: () => context.read<UdaraViewModel>().pilihKota(k),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: k == kotaAktif
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Text(
                            k.nama.replaceAll('Kota ', ''),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: k == kotaAktif
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: k == kotaAktif
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Horizontal Scrolling Chips untuk Kecamatan
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  children: [
                    for (final Kecamatan kec in daftarKec)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          avatar: Icon(
                            Icons.location_city_rounded,
                            size: 14,
                            color: kec == kecAktif
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            kec.nama,
                            style: const TextStyle(fontSize: 12),
                          ),
                          selected: kec == kecAktif,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: kec == kecAktif
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                            fontWeight: kec == kecAktif
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) =>
                              context.read<UdaraViewModel>().pilihKecamatan(kec),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
