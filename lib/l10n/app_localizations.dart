import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tani Inventaris'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get langSystem;

  /// No description provided for @langIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get langIndonesian;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name / type…'**
  String get searchHint;

  /// No description provided for @reloadTip.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reloadTip;

  /// No description provided for @exportTip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTip;

  /// No description provided for @countZero.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get countZero;

  /// No description provided for @countOne.
  ///
  /// In en, this message translates to:
  /// **'1 item'**
  String get countOne;

  /// No description provided for @countMany.
  ///
  /// In en, this message translates to:
  /// **'{n} items'**
  String countMany(int n);

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String loadError(String error);

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{q}\"'**
  String noResultsFor(String q);

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No plants recorded yet.'**
  String get emptyTitle;

  /// No description provided for @emptyFilteredHint.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword or clear the filter.'**
  String get emptyFilteredHint;

  /// No description provided for @emptyFirstHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record your first plant.'**
  String get emptyFirstHint;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{nama}\" will be deleted permanently.'**
  String deleteBody(String nama);

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirm;

  /// No description provided for @missingValue.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get missingValue;

  /// No description provided for @voiceTag.
  ///
  /// In en, this message translates to:
  /// **'voice'**
  String get voiceTag;

  /// No description provided for @stockLine.
  ///
  /// In en, this message translates to:
  /// **'Stock {n}'**
  String stockLine(int n);

  /// No description provided for @fabAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get fabAdd;

  /// No description provided for @exportAs.
  ///
  /// In en, this message translates to:
  /// **'Full inventory as .{f}'**
  String exportAs(String f);

  /// No description provided for @exportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data to export yet.'**
  String get exportEmpty;

  /// No description provided for @exportedAs.
  ///
  /// In en, this message translates to:
  /// **'Shared: {name}'**
  String exportedAs(String name);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {e}'**
  String exportFailed(String e);

  /// No description provided for @inputTitleNew.
  ///
  /// In en, this message translates to:
  /// **'Record Plant'**
  String get inputTitleNew;

  /// No description provided for @inputTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Plant'**
  String get inputTitleEdit;

  /// No description provided for @noCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera on this device.'**
  String get noCamera;

  /// No description provided for @camDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied. Open Settings > Apps > Tani Inventaris > Permissions, then try again.'**
  String get camDenied;

  /// No description provided for @camFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open camera: {e}'**
  String camFailed(String e);

  /// No description provided for @modePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get modePhoto;

  /// No description provided for @modeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get modeVideo;

  /// No description provided for @videoStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get videoStop;

  /// No description provided for @videoRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get videoRecord;

  /// No description provided for @snapCount.
  ///
  /// In en, this message translates to:
  /// **'Capture ({n})'**
  String snapCount(int n);

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not capture: {e}'**
  String captureFailed(String e);

  /// No description provided for @micDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied. Enable it in Settings.'**
  String get micDenied;

  /// No description provided for @voiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording… {n}s (say name, size, price)'**
  String voiceRecording(int n);

  /// No description provided for @voiceSavedSecs.
  ///
  /// In en, this message translates to:
  /// **'Voice note saved ({n}s)'**
  String voiceSavedSecs(int n);

  /// No description provided for @voiceSavedReady.
  ///
  /// In en, this message translates to:
  /// **'Voice note saved (ready)'**
  String get voiceSavedReady;

  /// No description provided for @voicePrompt.
  ///
  /// In en, this message translates to:
  /// **'Record a voice note (name, size, price)'**
  String get voicePrompt;

  /// No description provided for @voiceStopHint.
  ///
  /// In en, this message translates to:
  /// **'Tap stop when done'**
  String get voiceStopHint;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Plant name'**
  String get fieldName;

  /// No description provided for @fieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Agave victoria'**
  String get fieldNameHint;

  /// No description provided for @fieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// No description provided for @fieldTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ornamental'**
  String get fieldTypeHint;

  /// No description provided for @fieldSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get fieldSize;

  /// No description provided for @fieldSizeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 20 cm pot'**
  String get fieldSizeHint;

  /// No description provided for @fieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (Rp)'**
  String get fieldPrice;

  /// No description provided for @fieldPriceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 50.000'**
  String get fieldPriceHint;

  /// No description provided for @fieldStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get fieldStock;

  /// No description provided for @fieldStockHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12'**
  String get fieldStockHint;

  /// No description provided for @stockDown.
  ///
  /// In en, this message translates to:
  /// **'Decrease stock'**
  String get stockDown;

  /// No description provided for @stockUp.
  ///
  /// In en, this message translates to:
  /// **'Increase stock'**
  String get stockUp;

  /// No description provided for @fieldSku.
  ///
  /// In en, this message translates to:
  /// **'SKU (optional)'**
  String get fieldSku;

  /// No description provided for @fieldSkuHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AGV-001'**
  String get fieldSkuHint;

  /// No description provided for @fieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get fieldLocation;

  /// No description provided for @fieldLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Block A'**
  String get fieldLocationHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the plant name first.'**
  String get nameRequired;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {e}'**
  String saveFailed(String e);

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @saveNew.
  ///
  /// In en, this message translates to:
  /// **'Save to Inventory'**
  String get saveNew;

  /// No description provided for @saveEdit.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveEdit;

  /// No description provided for @phaseNote.
  ///
  /// In en, this message translates to:
  /// **'Phase 1: AI off. Name, type, size, and price are entered manually. Phase 2: AI fills them in from photo + voice.'**
  String get phaseNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
