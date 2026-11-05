import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tani_inventaris/l10n/app_localizations.dart';

import '../models/item.dart';
import '../qr/qr_payload.dart';

/// Label QR per item: tampil + bagikan PNG (untuk cetak/tempel rak).
class QrLabelSheet extends StatelessWidget {
  const QrLabelSheet({super.key, required this.item});

  final InvItem item;

  Future<void> _share(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    try {
      final painter = QrPainter(
        data: encodeQrPayload(item),
        version: QrVersions.auto,
        gapless: false,
      );
      final pic = await painter.toImageData(1024);
      if (pic == null) throw StateError('qr-render-null');
      final bytes = Uint8List.sublistView(pic);
      final name =
          'qr-${item.sku.isEmpty ? 'item-${item.id}' : item.sku}.png';
      await SharePlus.instance.share(ShareParams(files: [
        XFile.fromData(bytes, name: name, mimeType: 'image/png'),
      ]));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.qrShareFail('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.qrTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(item.nama, style: Theme.of(context).textTheme.bodyLarge),
            if (item.sku.isNotEmpty)
              Text(item.sku, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: encodeQrPayload(item),
                version: QrVersions.auto,
                size: 220,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _share(context),
              icon: const Icon(Icons.ios_share),
              label: Text(t.qrShare),
            ),
          ],
        ),
      ),
    );
  }
}
