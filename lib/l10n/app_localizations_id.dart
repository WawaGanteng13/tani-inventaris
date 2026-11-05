// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Tani Inventaris';

  @override
  String get retry => 'Coba lagi';

  @override
  String get cancel => 'Batal';

  @override
  String get language => 'Bahasa';

  @override
  String get langSystem => 'Ikuti sistem';

  @override
  String get langIndonesian => 'Bahasa Indonesia';

  @override
  String get langEnglish => 'Bahasa Inggris';

  @override
  String get searchHint => 'Cari nama / jenis…';

  @override
  String get reloadTip => 'Muat ulang';

  @override
  String get exportTip => 'Ekspor';

  @override
  String get countZero => 'Belum ada item';

  @override
  String get countOne => '1 item';

  @override
  String countMany(int n) {
    return '$n item';
  }

  @override
  String loadError(String error) {
    return 'Gagal memuat: $error';
  }

  @override
  String noResultsFor(String q) {
    return 'Tidak ada hasil untuk \"$q\"';
  }

  @override
  String get emptyTitle => 'Belum ada tanaman tercatat.';

  @override
  String get emptyFilteredHint => 'Coba kata kunci lain atau hapus filter.';

  @override
  String get emptyFirstHint => 'Ketuk + untuk mencatat tanaman pertama.';

  @override
  String get deleteTitle => 'Hapus item?';

  @override
  String deleteBody(String nama) {
    return '\"$nama\" akan dihapus permanen.';
  }

  @override
  String get deleteConfirm => 'Hapus';

  @override
  String get missingValue => '-';

  @override
  String get voiceTag => 'suara';

  @override
  String stockLine(int n) {
    return 'Stok $n';
  }

  @override
  String get fabAdd => 'Catat';

  @override
  String exportAs(String f) {
    return 'Inventaris lengkap sebagai .$f';
  }

  @override
  String get exportEmpty => 'Belum ada data untuk diekspor.';

  @override
  String exportedAs(String name) {
    return 'Dibagikan: $name';
  }

  @override
  String exportFailed(String e) {
    return 'Gagal mengekspor: $e';
  }

  @override
  String get inputTitleNew => 'Catat Tanaman';

  @override
  String get inputTitleEdit => 'Ubah Tanaman';

  @override
  String get noCamera => 'Tidak ada kamera di perangkat ini.';

  @override
  String get camDenied =>
      'Izin kamera ditolak. Buka Pengaturan > Aplikasi > Tani Inventaris > Izin, lalu coba lagi.';

  @override
  String camFailed(String e) {
    return 'Kamera gagal dibuka: $e';
  }

  @override
  String get modePhoto => 'Foto';

  @override
  String get modeVideo => 'Video';

  @override
  String get videoStop => 'Stop';

  @override
  String get videoRecord => 'Rekam';

  @override
  String snapCount(int n) {
    return 'Jepret ($n)';
  }

  @override
  String captureFailed(String e) {
    return 'Gagal mengambil gambar: $e';
  }

  @override
  String get micDenied => 'Izin mikrofon ditolak. Aktifkan di Pengaturan.';

  @override
  String voiceRecording(int n) {
    return 'Merekam… $n dtk (sebut nama, ukuran, harga)';
  }

  @override
  String voiceSavedSecs(int n) {
    return 'Voice-note tersimpan ($n dtk)';
  }

  @override
  String get voiceSavedReady => 'Voice-note tersimpan (siap)';

  @override
  String get voicePrompt => 'Rekam voice-note (nama, ukuran, harga)';

  @override
  String get voiceStopHint => 'Ketuk stop bila selesai';

  @override
  String get fieldName => 'Nama tanaman';

  @override
  String get fieldNameHint => 'mis. Agave victoria';

  @override
  String get fieldType => 'Jenis';

  @override
  String get fieldTypeHint => 'mis. Hias';

  @override
  String get fieldSize => 'Ukuran';

  @override
  String get fieldSizeHint => 'mis. Pot 20 cm';

  @override
  String get fieldPrice => 'Harga (Rp)';

  @override
  String get fieldPriceHint => 'mis. 50.000';

  @override
  String get fieldStock => 'Stok';

  @override
  String get fieldStockHint => 'mis. 12';

  @override
  String get stockDown => 'Kurangi stok';

  @override
  String get stockUp => 'Tambah stok';

  @override
  String get fieldSku => 'SKU (opsional)';

  @override
  String get fieldSkuHint => 'mis. AGV-001';

  @override
  String get fieldLocation => 'Lokasi (opsional)';

  @override
  String get fieldLocationHint => 'mis. Blok A';

  @override
  String get nameRequired => 'Isi nama tanaman dulu.';

  @override
  String saveFailed(String e) {
    return 'Gagal menyimpan: $e';
  }

  @override
  String get saving => 'Menyimpan…';

  @override
  String get saveNew => 'Simpan ke Inventaris';

  @override
  String get saveEdit => 'Simpan Perubahan';

  @override
  String get phaseNote =>
      'Fase 1: AI mati. Nama, jenis, ukuran, dan harga diisi manual. Fase 2: AI mengisi otomatis dari foto + voice.';

  @override
  String lowStockChip(int n) {
    return 'Stok menipis ($n)';
  }

  @override
  String get lowStockTag => 'menipis';

  @override
  String get fieldStockMin => 'Stok minimum (opsional)';

  @override
  String get fieldStockMinHint => 'mis. 5, 0 = mati';

  @override
  String get historyTitle => 'Riwayat Stok';

  @override
  String get historyEmpty => 'Belum ada mutasi tercatat.';

  @override
  String get mutSeed => 'Stok awal';

  @override
  String get mutIn => 'Masuk';

  @override
  String get mutOut => 'Keluar';

  @override
  String get mutAdjust => 'Penyesuaian';

  @override
  String get mutRecordTitle => 'Catat Mutasi';

  @override
  String get mutQty => 'Jumlah';

  @override
  String get mutNote => 'Catatan (opsional)';

  @override
  String get mutSave => 'Catat';

  @override
  String get mutRecorded => 'Mutasi tercatat.';

  @override
  String get mutTypeIn => 'Masuk';

  @override
  String get mutTypeOut => 'Keluar';

  @override
  String get menuHistory => 'Riwayat stok';

  @override
  String get menuQr => 'Label QR';

  @override
  String get qrTitle => 'Label QR';

  @override
  String get qrShare => 'Bagikan';

  @override
  String qrShareFail(String e) {
    return 'Gagal membagikan: $e';
  }

  @override
  String get scanTitle => 'Pindai QR';

  @override
  String get scanHint => 'Arahkan kamera ke label QR item';

  @override
  String get scanInvalid => 'QR ini bukan label Tani Inventaris.';

  @override
  String scanNotFound(int id) {
    return 'Item id $id tidak ditemukan.';
  }

  @override
  String scanFound(String nama) {
    return 'Ditemukan: $nama';
  }

  @override
  String scanError(String e) {
    return 'Kamera pindai gagal: $e';
  }
}
