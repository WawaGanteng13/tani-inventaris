import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tani_inventaris/export/export.dart';
import 'package:tani_inventaris/models/item.dart';

List<InvItem> _sample() => [
      InvItem(
        nama: 'Monstera Test',
        jenis: 'Hias',
        ukuran: 'Pot 20',
        hargaRp: 25000,
        photoPaths: ['a.jpg'],
        createdAt: DateTime.utc(2026, 11, 5),
      ),
      InvItem(
        nama: 'Agave & Co <uji>',
        jenis: '',
        ukuran: '',
        hargaRp: 0,
        createdAt: DateTime.utc(2026, 11, 4, 10, 30),
      ),
    ];

void main() {
  test('xlsx valid dan bisa dibaca kembali', () {
    final bytes = buildXlsx(_sample());
    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.take(2)), 'PK');
    final back = Excel.decodeBytes(bytes);
    final sheet = back['Sheet1'];
    expect(sheet.cell(CellIndex.indexByString('A1')).value.toString(), 'No');
    expect(sheet.cell(CellIndex.indexByString('B2')).value.toString(),
        'Monstera Test');
    expect(sheet.cell(CellIndex.indexByString('B3')).value.toString(),
        'Agave & Co <uji>');
  });

  test('pdf diawali magic %PDF', () async {
    final bytes = await buildPdf(_sample());
    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('docx valid, berisi document.xml + nama item (escaped)', () {
    final bytes = buildDocx(_sample());
    expect(bytes.length, greaterThan(500));
    expect(String.fromCharCodes(bytes.take(2)), 'PK');
    final archive = ZipDecoder().decodeBytes(bytes);
    final doc = archive.findFile('word/document.xml');
    expect(doc, isNotNull);
    final xml = utf8.decode(doc!.content as List<int>);
    expect(xml, contains('Monstera Test'));
    expect(xml, contains('Agave &amp; Co &lt;uji&gt;'));
  });

  test('nama file export unik per menit', () {
    final a = exportFileName('xlsx');
    expect(a, startsWith('tani-inventaris-'));
    expect(a, endsWith('.xlsx'));
  });
}
