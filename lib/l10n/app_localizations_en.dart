// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tani Inventaris';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get language => 'Language';

  @override
  String get langSystem => 'Follow system';

  @override
  String get langIndonesian => 'Indonesian';

  @override
  String get langEnglish => 'English';

  @override
  String get searchHint => 'Search name / type…';

  @override
  String get reloadTip => 'Reload';

  @override
  String get exportTip => 'Export';

  @override
  String get countZero => 'No items yet';

  @override
  String get countOne => '1 item';

  @override
  String countMany(int n) {
    return '$n items';
  }

  @override
  String loadError(String error) {
    return 'Failed to load: $error';
  }

  @override
  String noResultsFor(String q) {
    return 'No results for \"$q\"';
  }

  @override
  String get emptyTitle => 'No plants recorded yet.';

  @override
  String get emptyFilteredHint => 'Try another keyword or clear the filter.';

  @override
  String get emptyFirstHint => 'Tap + to record your first plant.';

  @override
  String get deleteTitle => 'Delete item?';

  @override
  String deleteBody(String nama) {
    return '\"$nama\" will be deleted permanently.';
  }

  @override
  String get deleteConfirm => 'Delete';

  @override
  String get missingValue => '-';

  @override
  String get voiceTag => 'voice';

  @override
  String stockLine(int n) {
    return 'Stock $n';
  }

  @override
  String get fabAdd => 'Add';

  @override
  String exportAs(String f) {
    return 'Full inventory as .$f';
  }

  @override
  String get exportEmpty => 'No data to export yet.';

  @override
  String exportedAs(String name) {
    return 'Shared: $name';
  }

  @override
  String exportFailed(String e) {
    return 'Export failed: $e';
  }

  @override
  String get inputTitleNew => 'Record Plant';

  @override
  String get inputTitleEdit => 'Edit Plant';

  @override
  String get noCamera => 'No camera on this device.';

  @override
  String get camDenied =>
      'Camera permission denied. Open Settings > Apps > Tani Inventaris > Permissions, then try again.';

  @override
  String camFailed(String e) {
    return 'Could not open camera: $e';
  }

  @override
  String get modePhoto => 'Photo';

  @override
  String get modeVideo => 'Video';

  @override
  String get videoStop => 'Stop';

  @override
  String get videoRecord => 'Record';

  @override
  String snapCount(int n) {
    return 'Capture ($n)';
  }

  @override
  String captureFailed(String e) {
    return 'Could not capture: $e';
  }

  @override
  String get micDenied =>
      'Microphone permission denied. Enable it in Settings.';

  @override
  String voiceRecording(int n) {
    return 'Recording… ${n}s (say name, size, price)';
  }

  @override
  String voiceSavedSecs(int n) {
    return 'Voice note saved (${n}s)';
  }

  @override
  String get voiceSavedReady => 'Voice note saved (ready)';

  @override
  String get voicePrompt => 'Record a voice note (name, size, price)';

  @override
  String get voiceStopHint => 'Tap stop when done';

  @override
  String get fieldName => 'Plant name';

  @override
  String get fieldNameHint => 'e.g. Agave victoria';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldTypeHint => 'e.g. Ornamental';

  @override
  String get fieldSize => 'Size';

  @override
  String get fieldSizeHint => 'e.g. 20 cm pot';

  @override
  String get fieldPrice => 'Price (Rp)';

  @override
  String get fieldPriceHint => 'e.g. 50.000';

  @override
  String get fieldStock => 'Stock';

  @override
  String get fieldStockHint => 'e.g. 12';

  @override
  String get stockDown => 'Decrease stock';

  @override
  String get stockUp => 'Increase stock';

  @override
  String get fieldSku => 'SKU (optional)';

  @override
  String get fieldSkuHint => 'e.g. AGV-001';

  @override
  String get fieldLocation => 'Location (optional)';

  @override
  String get fieldLocationHint => 'e.g. Block A';

  @override
  String get nameRequired => 'Enter the plant name first.';

  @override
  String saveFailed(String e) {
    return 'Could not save: $e';
  }

  @override
  String get saving => 'Saving…';

  @override
  String get saveNew => 'Save to Inventory';

  @override
  String get saveEdit => 'Save Changes';

  @override
  String get phaseNote =>
      'Phase 1: AI off. Name, type, size, and price are entered manually. Phase 2: AI fills them in from photo + voice.';

  @override
  String lowStockChip(int n) {
    return 'Low stock ($n)';
  }

  @override
  String get lowStockTag => 'low';

  @override
  String get fieldStockMin => 'Minimum stock (optional)';

  @override
  String get fieldStockMinHint => 'e.g. 5, 0 = off';

  @override
  String get historyTitle => 'Stock history';

  @override
  String get historyEmpty => 'No movements recorded yet.';

  @override
  String get mutSeed => 'Opening stock';

  @override
  String get mutIn => 'Stock in';

  @override
  String get mutOut => 'Stock out';

  @override
  String get mutAdjust => 'Adjustment';

  @override
  String get mutRecordTitle => 'Record movement';

  @override
  String get mutQty => 'Quantity';

  @override
  String get mutNote => 'Note (optional)';

  @override
  String get mutSave => 'Record';

  @override
  String get mutRecorded => 'Movement recorded.';

  @override
  String get mutTypeIn => 'In';

  @override
  String get mutTypeOut => 'Out';

  @override
  String get menuHistory => 'Stock history';

  @override
  String get menuQr => 'QR label';

  @override
  String get qrTitle => 'QR label';

  @override
  String get qrShare => 'Share';

  @override
  String qrShareFail(String e) {
    return 'Could not share: $e';
  }

  @override
  String get scanTitle => 'Scan QR';

  @override
  String get scanHint => 'Point the camera at an item QR label';

  @override
  String get scanInvalid => 'This QR is not a Tani Inventaris label.';

  @override
  String scanNotFound(int id) {
    return 'Item id $id not found.';
  }

  @override
  String scanFound(String nama) {
    return 'Found: $nama';
  }

  @override
  String scanError(String e) {
    return 'Scan camera failed: $e';
  }
}
