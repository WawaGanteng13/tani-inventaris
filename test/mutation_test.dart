import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tani_inventaris/db/database.dart';
import 'package:tani_inventaris/models/item.dart';
import 'package:tani_inventaris/models/mutation.dart';

/// Riwayat mutasi stok: seed saat insert, adjust saat update mengubah stok,
/// in/out via adjustStock (dijepit >= 0), query lowStock, dan hapus berantai.
///
/// Catatan: seperti list_refresh_test, akses DB dibungkus tester.runAsync
/// karena sqflite_ffi butuh celah event-loop nyata.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final docs = await Directory.systemTemp.createTemp('tani-mut-test-docs');
    const ch = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ch, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') return docs.path;
      return null;
    });
  });

  InvItem seed(String nama, int stok, {int stokMin = 0}) => InvItem(
        nama: nama,
        jenis: 'Hias',
        ukuran: 'kecil',
        hargaRp: 10000,
        stok: stok,
        stokMin: stokMin,
        createdAt: DateTime.now(),
      );

  Future<InvItem> byName(WidgetTester tester, String nama) async {
    final rows = (await tester.runAsync(() => InvDb.all()))!;
    return rows.firstWhere((r) => r.nama == nama);
  }

  test('StockMutation toMap/fromMap round-trip', () {
    final m = StockMutation(
      id: 3,
      itemId: 7,
      delta: -2,
      stokBefore: 5,
      stokAfter: 3,
      kind: 'out',
      note: 'jual',
      createdAt: DateTime.utc(2026, 11, 5, 1, 2, 3),
    );
    final back = StockMutation.fromMap(m.toMap());
    expect(back.id, 3);
    expect(back.itemId, 7);
    expect(back.delta, -2);
    expect(back.stokBefore, 5);
    expect(back.stokAfter, 3);
    expect(back.kind, 'out');
    expect(back.note, 'jual');
    expect(back.createdAt, DateTime.utc(2026, 11, 5, 1, 2, 3));
  });

  testWidgets('insert mencatat seed bila stok awal != 0', (tester) async {
    final id =
        (await tester.runAsync(() => InvDb.insert(seed('MutSeed', 4))))!;
    final muts = (await tester.runAsync(() => InvDb.mutationsFor(id)))!;
    expect(muts, hasLength(1));
    expect(muts.first.kind, 'seed');
    expect(muts.first.delta, 4);
    expect(muts.first.stokBefore, 0);
    expect(muts.first.stokAfter, 4);
  });

  testWidgets('insert stok 0 tidak mencatat mutasi', (tester) async {
    final id =
        (await tester.runAsync(() => InvDb.insert(seed('MutNol', 0))))!;
    final muts = (await tester.runAsync(() => InvDb.mutationsFor(id)))!;
    expect(muts, isEmpty);
  });

  testWidgets('update mencatat adjust hanya bila stok berubah',
      (tester) async {
    final id =
        (await tester.runAsync(() => InvDb.insert(seed('MutAdj', 10))))!;
    var item = await byName(tester, 'MutAdj');
    // Ubah non-stok: tidak ada mutasi baru (tetap 1 seed).
    await tester.runAsync(() => InvDb.update(InvItem(
          id: item.id,
          nama: item.nama,
          jenis: 'Sukulen',
          ukuran: item.ukuran,
          hargaRp: item.hargaRp,
          photoPaths: item.photoPaths,
          voicePath: item.voicePath,
          source: item.source,
          createdAt: item.createdAt,
          stok: 10,
          sku: item.sku,
          lokasi: item.lokasi,
          stokMin: item.stokMin,
        )));
    var muts = (await tester.runAsync(() => InvDb.mutationsFor(id)))!;
    expect(muts, hasLength(1));

    // Ubah stok: tercatat sebagai adjust, urutan terbaru dulu.
    item = await byName(tester, 'MutAdj');
    await tester.runAsync(() => InvDb.update(InvItem(
          id: item.id,
          nama: item.nama,
          jenis: item.jenis,
          ukuran: item.ukuran,
          hargaRp: item.hargaRp,
          photoPaths: item.photoPaths,
          voicePath: item.voicePath,
          source: item.source,
          createdAt: item.createdAt,
          stok: 7,
          sku: item.sku,
          lokasi: item.lokasi,
          stokMin: item.stokMin,
        )));
    muts = (await tester.runAsync(() => InvDb.mutationsFor(id)))!;
    expect(muts, hasLength(2));
    expect(muts.first.kind, 'adjust');
    expect(muts.first.delta, -3);
    expect(muts.first.stokBefore, 10);
    expect(muts.first.stokAfter, 7);
  });

  testWidgets('adjustStock in/out + jepit di 0 + id asing', (tester) async {
    final id =
        (await tester.runAsync(() => InvDb.insert(seed('MutMove', 5))))!;
    int? after = await tester.runAsync<int?>(
        () => InvDb.adjustStock(id, 3, note: 'kulak'));
    expect(after, 8);
    after = await tester.runAsync<int?>(() => InvDb.adjustStock(id, -2));
    expect(after, 6);
    // Keluar melebihi stok: dijepit 0, delta aktual tercatat.
    after = await tester.runAsync<int?>(() => InvDb.adjustStock(id, -99));
    expect(after, 0);
    final item = (await tester.runAsync(() => InvDb.byId(id)))!;
    expect(item.stok, 0);

    final muts = (await tester.runAsync(() => InvDb.mutationsFor(id)))!;
    expect(muts.map((m) => m.kind), ['out', 'out', 'in', 'seed']);
    expect(muts.first.delta, -6);
    expect(muts.first.stokAfter, 0);
    expect(muts[2].note, 'kulak');

    // Item tidak ada: null dan tidak ada baris yatim.
    final missing =
        await tester.runAsync<int?>(() => InvDb.adjustStock(999999, 5));
    expect(missing, isNull);
    final orphan =
        (await tester.runAsync(() => InvDb.mutationsFor(999999)))!;
    expect(orphan, isEmpty);
  });

  testWidgets('lowStock hanya item berambang yang tersentuh', (tester) async {
    await tester.runAsync(() => InvDb.insert(seed('MutLow1', 2, stokMin: 5)));
    await tester.runAsync(() => InvDb.insert(seed('MutLow2', 5, stokMin: 5)));
    await tester.runAsync(() => InvDb.insert(seed('MutOk', 9, stokMin: 5)));
    await tester.runAsync(() => InvDb.insert(seed('MutNoMin', 1)));
    final low = (await tester.runAsync(() => InvDb.lowStock()))!;
    final names = low.map((e) => e.nama).toSet();
    expect(names, containsAll(['MutLow1', 'MutLow2']));
    expect(names, isNot(contains('MutOk')));
    expect(names, isNot(contains('MutNoMin')));
    expect(low.firstWhere((e) => e.nama == 'MutLow1').stok, 2);
  });

  testWidgets('remove menghapus mutasi itemnya juga', (tester) async {
    final id =
        (await tester.runAsync(() => InvDb.insert(seed('MutDel', 3))))!;
    await tester.runAsync(() => InvDb.adjustStock(id, 1));
    var muts = (await tester.runAsync(() => InvDb.mutationsFor(id)))!;
    expect(muts, hasLength(2));
    await tester.runAsync(() => InvDb.remove(id));
    muts = (await tester.runAsync(() => InvDb.mutationsFor(id)))!;
    expect(muts, isEmpty);
    expect(await tester.runAsync(() => InvDb.byId(id)), isNull);
  });
}
