import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';

/// SQLite lokal (app-private). Skema v1 milik tani-inventaris.
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

  static Future<Database> _openInternal() async {
    final dir = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      p.join(dir.path, 'tani_inventaris.db'),
      version: 2,
      onCreate: (d, _) => d.execute('''
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
  lokasi TEXT NOT NULL DEFAULT ''
)'''),
      onUpgrade: (d, oldV, _) async {
        if (oldV < 2) {
          await d.execute(
              'ALTER TABLE items ADD COLUMN stok INTEGER NOT NULL DEFAULT 0');
          await d.execute(
              "ALTER TABLE items ADD COLUMN sku TEXT NOT NULL DEFAULT ''");
          await d.execute(
              "ALTER TABLE items ADD COLUMN lokasi TEXT NOT NULL DEFAULT ''");
        }
      },
    );
    _db = db;
    return db;
  }

  static Future<int> insert(InvItem item) async {
    final id = await (await open()).insert('items', item.toMap());
    refresh();
    return id;
  }

  static Future<int> update(InvItem item) async {
    final n = await (await open())
        .update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    refresh();
    return n;
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

  static Future<int> remove(int id) async {
    final n =
        await (await open()).delete('items', where: 'id = ?', whereArgs: [id]);
    refresh();
    return n;
  }
}
