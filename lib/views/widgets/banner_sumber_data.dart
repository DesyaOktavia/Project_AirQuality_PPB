import 'package:flutter/material.dart';

import '../../models/udara_model.dart';
import 'modal_pengaturan.dart';

class BannerSumberData extends StatelessWidget {
  const BannerSumberData({
    super.key,
    required this.sumber,
    this.catatan,
  });

  final SumberData sumber;
  final String? catatan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: sumber.warna.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sumber.warna.withAlpha(80)),
      ),
      child: Row(
        children: [
          Text(sumber.simbol, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              catatan ?? 'Sumber: ${sumber.label}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sumber.warna,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const ModalPengaturan(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Text(
                    'Ubah',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: sumber.warna,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 14, color: sumber.warna),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
