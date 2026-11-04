import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/item.dart';

/// Generator export murni (tanpa plugin platform) agar bisa diuji di host.
/// Kolom: No, Nama, Jenis, Ukuran, Harga (Rp), Foto, Dibuat.
List<String> get exportHeader =>
    ['No', 'Nama', 'Jenis', 'Ukuran', 'Harga (Rp)', 'Foto', 'Dibuat'];

String _fmtDate(DateTime d) {
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
}

List<List<Object>> _rows(List<InvItem> items) => [
      for (var i = 0; i < items.length; i++)
        [
          i + 1,
          items[i].nama,
          items[i].jenis,
          items[i].ukuran,
          items[i].hargaRp,
          items[i].photoPaths.length,
          _fmtDate(items[i].createdAt),
        ],
    ];

String exportFileName(String ext) {
  final n = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return 'tani-inventaris-${n.year}${two(n.month)}${two(n.day)}-'
      '${two(n.hour)}${two(n.minute)}.$ext';
}

/// XLSX via excel_plus. Harga dan No sebagai angka (bukan teks).
Uint8List buildXlsx(List<InvItem> items) {
  final excel = Excel.createExcel();
  final sheet = excel['Sheet1'];
  final head = exportHeader;
  for (var c = 0; c < head.length; c++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
        .value = TextCellValue(head[c]);
  }
  final rows = _rows(items);
  for (var r = 0; r < rows.length; r++) {
    for (var c = 0; c < rows[r].length; c++) {
      final v = rows[r][c];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
          .value = v is int ? IntCellValue(v) : TextCellValue(v.toString());
    }
  }
  final bytes = excel.encode();
  if (bytes == null) throw StateError('Gagal menyusun XLSX');
  return Uint8List.fromList(bytes);
}

/// PDF satu tabel + judul.
Future<Uint8List> buildPdf(List<InvItem> items) async {
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      header: (_) => pw.Text('Tani Inventaris',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      build: (_) => [
        pw.TableHelper.fromTextArray(
          headers: exportHeader,
          data: _rows(items).map((r) => r.map((v) => v.toString()).toList()).toList(),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Diekspor ${_fmtDate(DateTime.now())} - ${items.length} item',
            style: const pw.TextStyle(fontSize: 10)),
      ],
    ),
  );
  return doc.save();
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _cell(String text, {bool bold = false}) =>
    '<w:tc><w:p><w:r>${bold ? '<w:rPr><w:b/></w:rPr>' : ''}'
    '<w:t xml:space="preserve">${_esc(text)}</w:t></w:r></w:p></w:tc>';

/// DOCX minimal valid (zip + document.xml tulis-tangan, tanpa template).
Uint8List buildDocx(List<InvItem> items) {
  const borders = '<w:tblBorders><w:top w:val="single" w:sz="4"/>'
      '<w:left w:val="single" w:sz="4"/><w:bottom w:val="single" w:sz="4"/>'
      '<w:right w:val="single" w:sz="4"/><w:insideH w:val="single" w:sz="4"/>'
      '<w:insideV w:val="single" w:sz="4"/></w:tblBorders>';
  final buf = StringBuffer()
    ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:body><w:p><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr>'
        '<w:t xml:space="preserve">Tani Inventaris</w:t></w:r></w:p>'
        '<w:tbl><w:tblPr>$borders</w:tblPr><w:tr>');
  for (final h in exportHeader) {
    buf.write(_cell(h, bold: true));
  }
  buf.write('</w:tr>');
  for (final r in _rows(items)) {
    buf.write('<w:tr>');
    for (final v in r) {
      buf.write(_cell(v.toString()));
    }
    buf.write('</w:tr>');
  }
  buf.write('</w:tbl><w:p><w:r><w:t xml:space="preserve">'
      'Diekspor ${_fmtDate(DateTime.now())} - ${items.length} item'
      '</w:t></w:r></w:p><w:sectPr/></w:body></w:document>');

  const contentTypes =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>';
  const rels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>';

  final archive = Archive()
    ..addFile(ArchiveFile('[Content_Types].xml',
        contentTypes.length, utf8.encode(contentTypes)))
    ..addFile(
        ArchiveFile('_rels/.rels', rels.length, utf8.encode(rels)))
    ..addFile(ArchiveFile('word/document.xml', buf.length,
        utf8.encode(buf.toString())));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
