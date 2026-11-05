/// Satu baris riwayat stok (mutasi). Hanya soal stok, bukan harga/nama.
///
/// [kind]: 'seed' (stok awal saat item dibuat), 'in' (masuk), 'out'
/// (keluar), 'adjust' (penyesuaian via layar ubah).
class StockMutation {
  final int? id;
  final int itemId;
  final int delta;
  final int stokBefore;
  final int stokAfter;
  final String kind;
  final String note;
  final DateTime createdAt;

  const StockMutation({
    this.id,
    required this.itemId,
    required this.delta,
    required this.stokBefore,
    required this.stokAfter,
    required this.kind,
    this.note = '',
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'itemId': itemId,
        'delta': delta,
        'stokBefore': stokBefore,
        'stokAfter': stokAfter,
        'kind': kind,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  static StockMutation fromMap(Map<String, Object?> m) => StockMutation(
        id: m['id'] as int?,
        itemId: (m['itemId'] ?? 0) as int,
        delta: (m['delta'] ?? 0) as int,
        stokBefore: (m['stokBefore'] ?? 0) as int,
        stokAfter: (m['stokAfter'] ?? 0) as int,
        kind: (m['kind'] ?? 'adjust') as String,
        note: (m['note'] ?? '') as String,
        createdAt: DateTime.parse((m['createdAt'] ?? '') as String),
      );
}
