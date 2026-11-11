import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/udara_model.dart';
import '../../viewmodels/udara_viewmodel.dart';

class ModalPengaturan extends StatefulWidget {
  const ModalPengaturan({super.key});

  @override
  State<ModalPengaturan> createState() => _ModalPengaturanState();
}

class _ModalPengaturanState extends State<ModalPengaturan> {
  late TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<UdaraViewModel>();
    _keyController = TextEditingController(text: vm.kunciCustom);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UdaraViewModel>();
    final TextTheme gayaTeks = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              const Icon(Icons.settings_rounded, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'Pengaturan Sumber Data & API',
                style: gayaTeks.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Pilih Mode Sumber Data:', style: gayaTeks.titleSmall),
          const SizedBox(height: 8),
          for (final ModeSumber mode in ModeSumber.values) ...[
            Card(
              elevation: mode == vm.modeSumber ? 2 : 0,
              color: mode == vm.modeSumber
                  ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withAlpha(120)
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: mode == vm.modeSumber
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withAlpha(80),
                  width: mode == vm.modeSumber ? 2 : 1,
                ),
              ),
              child: ListTile(
                dense: true,
                title: Text(
                  mode.label,
                  style: TextStyle(
                    fontWeight: mode == vm.modeSumber
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(mode.keterangan, style: gayaTeks.bodySmall),
                trailing: mode == vm.modeSumber
                    ? Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary)
                    : const Icon(Icons.circle_outlined),
                onTap: () => vm.ubahModeSumber(mode),
              ),
            ),
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 12),
          Text('Custom API Key OpenWeather:', style: gayaTeks.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _keyController,
            decoration: InputDecoration(
              hintText: 'Masukkan OpenWeather API Key...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check_circle),
                tooltip: 'Simpan Key',
                onPressed: () {
                  vm.updateKunciCustom(_keyController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('API Key berhasil diperbarui!')),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Selesai'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
