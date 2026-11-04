import 'package:flutter_test/flutter_test.dart';
import 'package:tani_inventaris/models/item.dart';

void main() {
  test('toMap/fromMap round-trip menjaga semua field', () {
    final item = InvItem(
      id: 7,
      nama: 'Monstera',
      jenis: 'Hias',
      ukuran: 'Pot 20 cm',
      hargaRp: 25000,
      photoPaths: ['a.jpg', 'b.jpg'],
      voicePath: 'v.m4a',
      source: 'manual',
      createdAt: DateTime.utc(2026, 11, 5, 1, 2, 3),
    );
    final back = InvItem.fromMap(item.toMap());
    expect(back.id, 7);
    expect(back.nama, 'Monstera');
    expect(back.jenis, 'Hias');
    expect(back.ukuran, 'Pot 20 cm');
    expect(back.hargaRp, 25000);
    expect(back.photoPaths, ['a.jpg', 'b.jpg']);
    expect(back.voicePath, 'v.m4a');
    expect(back.source, 'manual');
    expect(back.createdAt, DateTime.utc(2026, 11, 5, 1, 2, 3));
  });

  test('fromMap memberi default utk kunci opsional yang hilang', () {
    final back = InvItem.fromMap({
      'nama': 'X',
      'createdAt': '2026-11-05T00:00:00.000',
    });
    expect(back.id, isNull);
    expect(back.nama, 'X');
    expect(back.jenis, '');
    expect(back.ukuran, '');
    expect(back.hargaRp, 0);
    expect(back.photoPaths, isEmpty);
    expect(back.voicePath, isNull);
    expect(back.source, 'manual');
  });
}
