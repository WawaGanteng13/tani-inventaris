import 'dart:convert';

/// Satu baris inventaris. Fase 1: diisi manual (foto + voice + harga).
/// Fase 2: [source] = 'ai' saat baris ditulis AI dari foto/voice.
class InvItem {
  final int? id;
  final String nama;
  final String jenis;
  final String ukuran;
  final int hargaRp;
  final List<String> photoPaths;
  final String? voicePath;
  final String source;
  final DateTime createdAt;
  final int stok;
  final String sku;
  final String lokasi;

  const InvItem({
    this.id,
    required this.nama,
    required this.jenis,
    required this.ukuran,
    required this.hargaRp,
    this.photoPaths = const [],
    this.voicePath,
    this.source = 'manual',
    required this.createdAt,
    this.stok = 0,
    this.sku = '',
    this.lokasi = '',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nama': nama,
        'jenis': jenis,
        'ukuran': ukuran,
        'hargaRp': hargaRp,
        'photoPaths': jsonEncode(photoPaths),
        'voicePath': voicePath,
        'source': source,
        'createdAt': createdAt.toIso8601String(),
        'stok': stok,
        'sku': sku,
        'lokasi': lokasi,
      };

  static InvItem fromMap(Map<String, Object?> m) => InvItem(
        id: m['id'] as int?,
        nama: (m['nama'] ?? '') as String,
        jenis: (m['jenis'] ?? '') as String,
        ukuran: (m['ukuran'] ?? '') as String,
        hargaRp: (m['hargaRp'] ?? 0) as int,
        photoPaths: List<String>.from(
            jsonDecode((m['photoPaths'] ?? '[]') as String) as List),
        voicePath: m['voicePath'] as String?,
        source: (m['source'] ?? 'manual') as String,
        createdAt: DateTime.parse((m['createdAt'] ?? '') as String),
        stok: (m['stok'] ?? 0) as int,
        sku: (m['sku'] ?? '') as String,
        lokasi: (m['lokasi'] ?? '') as String,
      );
}
