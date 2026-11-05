import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';
import '../models/mutation.dart';

/// SQLite lokal (app-private). Skema v3 milik tani-inventaris.
class InvDb {
  static Database? _db;

  /// Naik tiap tulis DB; ListScreen me-refresh otomatis. Anti-stale:
  /// refresh terpicu alur tulis yang sama (pasti setelah commit),
  /// tidak bergantung sinyal navigasi.
  static final ValueNotifier<int> revision = ValueNotifier(0);
  static void refresh() => revision.value++;
  static Future<Database>? _opening;

  static Future<Database> open() {
    final existing = _db;
    if (existing != null) return Future.value(existing);
    return _opening ??= _openInternal().whenComplete(() => _opening = null);
  }

  static Future<void> _createMutations(DatabaseExecutor d) => d.execute('''
CREATE TABLE mutations(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  itemId INTEGER NOT NULL,
  delta INTEGER NOT NULL,
  stokBefore INTEGER NOT NULL,
  stokAfter INTEGER NOT NULL,
  kind TEXT NOT NULL,
  note TEXT NOT NULL DEFAULT '',
  createdAt TEXT NOT NULL
)''');

  static Future<Database> _openInternal() async {
    final dir = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      p.join(dir.path, 'tani_inventaris.db'),
      version: 3,
      onCreate: (d, _) async {
        await d.execute('''
CREATE TABLE items(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama TEXT NOT NULL,
  jenis TEXT NOT NULL DEFAULT '',
  ukuran TEXT NOT NULL DEFAULT '',
  hargaRp INTEGER NOT NULL DEFAULT 0,
  photoPaths TEXT NOT NULL DEFAULT '[]',
  voicePath TEXT,
  source TEXT NOT NULL DEFAULT 'manual',
  createdAt TEXT NOT NULL,
  stok INTEGER NOT NULL DEFAULT 0,
  sku TEXT NOT NULL DEFAULT '',
  lokasi TEXT NOT NULL DEFAULT '',
  stokMin INTEGER NOT NULL DEFAULT 0
)''');
        await _createMutations(d);
      },
      onUpgrade: (d, oldV, _) async {
        if (oldV < 2) {
          await d.execute(
              'ALTER TABLE items ADD COLUMN stok INTEGER NOT NULL DEFAULT 0');
          await d.execute(
              "ALTER TABLE items ADD COLUMN sku TEXT NOT NULL DEFAULT ''");
          await d.execute(
              "ALTER TABLE items ADD COLUMN lokasi TEXT NOT NULL DEFAULT ''");
        }
        if (oldV < 3) {
          await d.execute(
              'ALTER TABLE items ADD COLUMN stokMin INTEGER NOT NULL DEFAULT 0');
          await _createMutations(d);
        }
      },
    );
    _db = db;
    return db;
  }

  static Future<int> _insertMutation(
      DatabaseExecutor d, StockMutation m) async {
    final map = m.toMap()..remove('id');
    return d.insert('mutations', map);
  }

  static Future<int> insert(InvItem item) async {
    final db = await open();
    final id = await db.transaction((txn) async {
      final newId = await txn.insert('items', item.toMap());
      if (item.stok != 0) {
        await _insertMutation(
            txn,
            StockMutation(
              itemId: newId,
              delta: item.stok,
              stokBefore: 0,
              stokAfter: item.stok,
              kind: 'seed',
              createdAt: DateTime.now(),
            ));
      }
      return newId;
    });
    refresh();
    return id;
  }

  static Future<int> update(InvItem item) async {
    final db = await open();
    final n = await db.transaction((txn) async {
      final old = await txn.query('items',
          columns: ['stok'], where: 'id = ?', whereArgs: [item.id]);
      final count = await txn.update('items', item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
      if (count > 0 && old.isNotEmpty) {
        final before = (old.first['stok'] ?? 0) as int;
        if (before != item.stok) {
          await _insertMutation(
              txn,
              StockMutation(
                itemId: item.id!,
                delta: item.stok - before,
                stokBefore: before,
                stokAfter: item.stok,
                kind: 'adjust',
                createdAt: DateTime.now(),
              ));
        }
      }
      return count;
    });
    refresh();
    return n;
  }

  /// Ubah stok relatif (delta bisa negatif). Hasil dijepit >= 0; mutasi
  /// mencatat delta aktual yang terjadi. Kembalikan stok akhir, atau null
  /// bila item tidak ada.
  static Future<int?> adjustStock(int itemId, int delta,
      {String note = ''}) async {
    if (delta == 0) return (await byId(itemId))?.stok;
    final db = await open();
    final after = await db.transaction((txn) async {
      final rows = await txn.query('items',
          columns: ['stok'], where: 'id = ?', whereArgs: [itemId]);
      if (rows.isEmpty) return null;
      final before = (rows.first['stok'] ?? 0) as int;
      final target = before + delta < 0 ? 0 : before + delta;
      await txn.update('items', {'stok': target},
          where: 'id = ?', whereArgs: [itemId]);
      await _insertMutation(
          txn,
          StockMutation(
            itemId: itemId,
            delta: target - before,
            stokBefore: before,
            stokAfter: target,
            kind: delta > 0 ? 'in' : 'out',
            note: note,
            createdAt: DateTime.now(),
          ));
      return target;
    });
    if (after != null) refresh();
    return after;
  }

  static Future<List<InvItem>> all({String query = ''}) async {
    final db = await open();
    final rows = query.trim().isEmpty
        ? await db.query('items', orderBy: 'id DESC')
        : await db.query('items',
            where: 'nama LIKE ? OR jenis LIKE ?',
            whereArgs: ['%$query%', '%$query%'],
            orderBy: 'id DESC');
    return rows.map(InvItem.fromMap).toList();
  }

  static Future<InvItem?> byId(int id) async {
    final rows = await (await open())
        .query('items', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : InvItem.fromMap(rows.first);
  }

  /// Item yang ambangnya dipasang dan stoknya sudah menyentuh/melewatinya.
  static Future<List<InvItem>> lowStock() async {
    final rows = await (await open()).query('items',
        where: 'stokMin > 0 AND stok <= stokMin', orderBy: 'stok ASC');
    return rows.map(InvItem.fromMap).toList();
  }

  static Future<List<StockMutation>> mutationsFor(int itemId) async {
    final rows = await (await open()).query('mutations',
        where: 'itemId = ?', whereArgs: [itemId], orderBy: 'id DESC');
    return rows.map(StockMutation.fromMap).toList();
  }

  static Future<int> remove(int id) async {
    final db = await open();
    final n = await db.transaction((txn) async {
      await txn.delete('mutations', where: 'itemId = ?', whereArgs: [id]);
      return txn.delete('items', where: 'id = ?', whereArgs: [id]);
    });
    refresh();
    return n;
  }
}
