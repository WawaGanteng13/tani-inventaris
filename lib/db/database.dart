import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';

/// SQLite lokal (app-private). Skema v1 milik tani-inventaris.
class InvDb {
  static Database? _db;

  static Future<Database> open() async {
    final existing = _db;
    if (existing != null) return existing;
    final dir = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      p.join(dir.path, 'tani_inventaris.db'),
      version: 1,
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
  createdAt TEXT NOT NULL
)'''),
    );
    _db = db;
    return db;
  }

  static Future<int> insert(InvItem item) async =>
      (await open()).insert('items', item.toMap());

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

  static Future<int> remove(int id) async =>
      (await open()).delete('items', where: 'id = ?', whereArgs: [id]);
}
