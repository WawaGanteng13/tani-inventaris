import 'package:flutter_test/flutter_test.dart';
import 'package:tani_inventaris/models/item.dart';
import 'package:tani_inventaris/qr/qr_payload.dart';

void main() {
  InvItem item({int? id = 7, String sku = 'AGV-001'}) => InvItem(
        id: id,
        nama: 'Agave',
        jenis: 'Hias',
        ukuran: 'kecil',
        hargaRp: 50000,
        createdAt: DateTime.utc(2026, 11, 5),
        sku: sku,
      );

  test('encode/decode round-trip', () {
    final p = parseQrPayload(encodeQrPayload(item()));
    expect(p, isNotNull);
    expect(p!.id, 7);
    expect(p.sku, 'AGV-001');
  });

  test('sku mengandung titik-dua tetap utuh', () {
    final p = parseQrPayload(encodeQrPayload(item(sku: 'A:B:C')));
    expect(p, isNotNull);
    expect(p!.id, 7);
    expect(p.sku, 'A:B:C');
  });

  test('input asing/korup menghasilkan null', () {
    expect(parseQrPayload(''), isNull);
    expect(parseQrPayload('halo'), isNull);
    expect(parseQrPayload('taniinv:1'), isNull);
    expect(parseQrPayload('other:1:7:X'), isNull);
    expect(parseQrPayload('taniinv:2:7:X'), isNull);
    expect(parseQrPayload('taniinv:1:x:X'), isNull);
    expect(parseQrPayload('taniinv:1:0:X'), isNull);
    expect(parseQrPayload('taniinv:1:-3:X'), isNull);
  });
}
