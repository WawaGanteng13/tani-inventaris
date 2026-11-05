import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tani_inventaris/db/database.dart';
import 'package:tani_inventaris/l10n/app_localizations.dart';
import 'package:tani_inventaris/models/item.dart';
import 'package:tani_inventaris/screens/history_screen.dart';
import 'package:tani_inventaris/screens/list_screen.dart';

/// Widget: badge + chip filter stok menipis, dan layar riwayat mutasi.
///
/// Primer runAsync mengikuti pola list_refresh_test (ffi butuh celah
/// event-loop nyata).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final docs = await Directory.systemTemp.createTemp('tani-low-test-docs');
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

  Widget wrap(Widget home) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('id'),
        home: home,
      );

  testWidgets('badge menipis + chip memfilter daftar', (tester) async {
    await tester.runAsync(() => InvDb.insert(seed('LowA', 2, stokMin: 5)));
    await tester.runAsync(() => InvDb.insert(seed('OkB', 9, stokMin: 5)));

    await tester.pumpWidget(wrap(const ListScreen()));
    await tester.pump();
    await tester.runAsync(() => InvDb.all());
    await tester.pumpAndSettle();

    expect(find.text('LowA'), findsOneWidget);
    expect(find.text('OkB'), findsOneWidget);
    expect(find.text('Stok menipis (1)'), findsOneWidget);
    // Tag hanya di baris yang tersentuh ambang (chip 'Stok menipis'
    // tidak memakai '·' sehingga tidak ikut cocok).
    expect(find.textContaining('· menipis', findRichText: true),
        findsOneWidget);

    await tester.tap(find.text('Stok menipis (1)'));
    await tester.pumpAndSettle();
    expect(find.text('LowA'), findsOneWidget);
    expect(find.text('OkB'), findsNothing);

    await tester.tap(find.text('Stok menipis (1)'));
    await tester.pumpAndSettle();
    expect(find.text('OkB'), findsOneWidget);
  });

  testWidgets('riwayat menampilkan mutasi + catat menambah baris',
      (tester) async {
    final id =
        (await tester.runAsync(() => InvDb.insert(seed('HistC', 5))))!;
    await tester.runAsync<int?>(() => InvDb.adjustStock(id, 3, note: 'kulak'));
    final item = (await tester.runAsync(() => InvDb.byId(id)))!;

    await tester.pumpWidget(wrap(HistoryScreen(item: item)));
    await tester.pump();
    await tester.runAsync(() => Future.wait([
          InvDb.byId(id),
          InvDb.mutationsFor(id),
        ]));
    await tester.pumpAndSettle();

    expect(find.text('HistC'), findsOneWidget);
    expect(find.textContaining('Stok 8'), findsOneWidget);
    expect(find.textContaining('Masuk'), findsWidgets);
    expect(find.textContaining('+3'), findsOneWidget);
    expect(find.textContaining('kulak'), findsOneWidget);
    expect(find.textContaining('Stok awal'), findsOneWidget);

    // Catat keluar 2 via sheet.
    await tester.tap(find.text('Catat Mutasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '2');
    await tester.pump();
    await tester.tap(find.text('Catat'));
    await tester.pump();
    // Primer 1: simpan selesai → refresh → _onRev me-reload (_load baru
    // dibuat di ujung jendela). Primer 2: _load itu ikut selesai.
    Future<List<Object?>> prime() => Future.wait([
          InvDb.byId(id),
          InvDb.mutationsFor(id),
        ]);
    await tester.runAsync(prime);
    await tester.pump();
    await tester.runAsync(prime);
    await tester.pumpAndSettle();

    expect(find.textContaining('Stok 6'), findsOneWidget);
    expect(find.textContaining('-2'), findsOneWidget);
    expect(find.textContaining('Keluar'), findsWidgets);
  });
}
