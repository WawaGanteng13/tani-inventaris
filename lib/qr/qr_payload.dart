import '../models/item.dart';

/// Payload label QR per item: `taniinv:1:<id>:<sku>`.
///
/// Murni (tanpa plugin) agar bisa diuji unit. [sku] boleh mengandung ':'
/// karena parse hanya memotong tiga ':' pertama.
String encodeQrPayload(InvItem item) =>
    'taniinv:1:${item.id ?? 0}:${item.sku}';

/// Kembalikan (id, sku) bila [text] label valid, else null.
({int id, String sku})? parseQrPayload(String text) {
  final parts = text.split(':');
  if (parts.length < 4) return null;
  if (parts[0] != 'taniinv' || parts[1] != '1') return null;
  final id = int.tryParse(parts[2]);
  if (id == null || id <= 0) return null;
  return (id: id, sku: parts.sublist(3).join(':'));
}
