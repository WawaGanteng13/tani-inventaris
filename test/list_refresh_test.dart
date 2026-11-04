import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tani_inventaris/db/database.dart';
import 'package:tani_inventaris/l10n/app_localizations.dart';
import 'package:tani_inventaris/models/item.dart';
import 'package:tani_inventaris/screens/list_screen.dart';

/// Regresi bug stale-list: _reload memakai setState arrow yang mengembalikan
/// Future (`setState(() => _future = InvDb.all())`). Di build debug/test,
/// framework melempar "setState() callback argument returned a Future" dan
/// markNeedsBuild tidak berjalan, sehingga daftar macet di data lama sampai
/// restart. Tes ini merah sebelum fix, hijau sesudahnya.
///
/// Catatan: akses DB dibungkus tester.runAsync karena sqflite_ffi butuh
/// celah event-loop nyata yang tidak disediakan zona fake-async widget test
/// (tanpanya pumpAndSettle pertama tidak pernah settle).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final docs = await Directory.systemTemp.createTemp('tani-test-docs');
    const ch = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ch, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') return docs.path;
      return null;
    });
  });

  InvItem seed(String nama, int stok) => InvItem(
        nama: nama,
        jenis: 'Hias',
        ukuran: 'kecil',
        hargaRp: 10000,
        stok: stok,
        createdAt: DateTime.now(),
      );

  testWidgets('refresh setelah update menampilkan stok baru tanpa restart',
      (tester) async {
    final id =
        (await tester.runAsync(() => InvDb.insert(seed('Aggie', 1))))!;

    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('id'),
      home: ListScreen(),
    ));
    await tester.pump();
    await tester.runAsync(() => InvDb.all());
    await tester.pumpAndSettle();
    expect(find.textContaining('Stok 1'), findsOneWidget);

    final rows = (await tester.runAsync(() => InvDb.all()))!;
    final item = rows.firstWhere((r) => r.id == id);
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
          stok: 2,
          sku: item.sku,
          lokasi: item.lokasi,
        )));
    // Catatan: future reload yang dibuat listener revisi di dalam runAsync
    // tidak bisa selesai setelah kembali ke zona fake-async, jadi jangan
    // settle di sini. Tap refresh di bawah mengganti _future dengan future
    // baru yang BISA selesai (dibuat di zona fake + primer real-async).
    // Kedua jalur memanggil _reload yang sama; jabatan bug (closure setState
    // mengembalikan Future) tercakup oleh refresh manual ini.
    await tester.tap(find.byIcon(Icons.refresh));
    // Primer celah real-async: future ffi yang dibuat di zona fake-async
    // (gesture tap) butuh ini agar selesai; tanpa ini spinner tidak berhenti.
    await tester.runAsync(() => InvDb.all());
    await tester.pumpAndSettle();

    expect(find.textContaining('Stok 2'), findsOneWidget);
    expect(find.textContaining('Stok 1'), findsNothing);
  });
}
