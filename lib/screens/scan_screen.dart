import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tani_inventaris/l10n/app_localizations.dart';

import '../db/database.dart';
import '../models/item.dart';
import '../qr/qr_payload.dart';

/// Pindai label QR item. Sukses: pop dengan [InvItem] yang ditemukan.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late final MobileScannerController _ctrl;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_busy) return;
    final raw = cap.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _busy = true;
    try {
      final t = AppLocalizations.of(context)!;
      final parsed = parseQrPayload(raw);
      if (parsed == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.scanInvalid)));
        await Future.delayed(const Duration(seconds: 2));
        return;
      }
      final item = await InvDb.byId(parsed.id);
      if (!mounted) return;
      if (item == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.scanNotFound(parsed.id))));
        await Future.delayed(const Duration(seconds: 2));
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.scanFound(item.nama))));
      Navigator.of(context).pop(item);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.scanTitle)),
      body: Stack(
        children: [
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
            errorBuilder: (ctx, err) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.scanError('${err.errorCode}'),
                    textAlign: TextAlign.center),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(t.scanHint,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
