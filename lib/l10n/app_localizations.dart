import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en'),
  ];

  /// The application title shown in the task switcher and app bar.
  ///
  /// In en, this message translates to:
  /// **'TinyTunes'**
  String get appTitle;

  /// App bar tooltip for the message center.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTooltip;

  /// App bar tooltip for Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// Empty-state title when the playlist queue has no entries.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty.'**
  String get queueEmpty;

  /// Primary button on the empty queue state to add a music folder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolderAction;

  /// Settings screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section header for theme mode.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// Theme mode option that follows the OS.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Theme mode option for light appearance.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme mode option for dark appearance.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Settings section header for app about info.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// About row showing the app version string.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAboutVersion(String version);

  /// Message center app bar title.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// Empty state when the session message list has no entries.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get messagesEmpty;

  /// Banner while a forget-folder operation is in progress.
  ///
  /// In en, this message translates to:
  /// **'Forgetting folder…'**
  String get forgettingProgress;

  /// Home strip when a library root grant is revoked.
  ///
  /// In en, this message translates to:
  /// **'Access lost: {folderName}'**
  String revokedRootBanner(String folderName);

  /// Button on a revoked-root strip to forget that folder.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get forgetRevokedRootAction;

  /// Semantics label for the previous transport control.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get transportPrevious;

  /// Semantics label for the play/pause transport control.
  ///
  /// In en, this message translates to:
  /// **'Play or pause'**
  String get transportPlayPause;

  /// Semantics label for the next transport control.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get transportNext;

  /// Semantics label for the shuffle toggle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get transportShuffle;

  /// Semantics label when repeat is off.
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get transportRepeatOff;

  /// Semantics label when repeat one is active.
  ///
  /// In en, this message translates to:
  /// **'Repeat one'**
  String get transportRepeatOne;

  /// Semantics label when repeat all is active.
  ///
  /// In en, this message translates to:
  /// **'Repeat all'**
  String get transportRepeatAll;

  /// Tooltip to expand the system volume slider.
  ///
  /// In en, this message translates to:
  /// **'Show volume'**
  String get transportVolumeExpand;

  /// Tooltip to collapse the system volume slider.
  ///
  /// In en, this message translates to:
  /// **'Hide volume'**
  String get transportVolumeCollapse;

  /// Tooltip for adding a music folder to the library.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolderTooltip;

  /// Tooltip for the playlist overflow menu.
  ///
  /// In en, this message translates to:
  /// **'Playlist actions'**
  String get playlistMenuTooltip;

  /// Menu action that clears the queue only.
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get clearQueue;

  /// Menu action to re-scan a library root.
  ///
  /// In en, this message translates to:
  /// **'Re-scan folder'**
  String get rescanFolder;

  /// Menu action to forget a library root.
  ///
  /// In en, this message translates to:
  /// **'Forget folder'**
  String get forgetFolder;

  /// Tooltip for removing one queue row.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get removeFromQueueTooltip;

  /// Button to cancel an in-flight library scan.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelScan;

  /// Scan progress banner with files processed so far.
  ///
  /// In en, this message translates to:
  /// **'Scanning… {count}'**
  String scanningProgress(int count);

  /// Confirm dialog title for clearing the queue.
  ///
  /// In en, this message translates to:
  /// **'Clear queue?'**
  String get clearQueueTitle;

  /// Confirm dialog body for clearing the queue.
  ///
  /// In en, this message translates to:
  /// **'Removes all songs from the queue. Your library folders stay.'**
  String get clearQueueBody;

  /// Confirm dialog title for forgetting a library root.
  ///
  /// In en, this message translates to:
  /// **'Forget folder?'**
  String get forgetFolderTitle;

  /// Confirm dialog body for forgetting a library root.
  ///
  /// In en, this message translates to:
  /// **'Removes this folder from the library and its songs from the queue.'**
  String get forgetFolderBody;

  /// Positive button on destructive confirm dialogs.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// Negative button on dialogs.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// Title when picking a library root for re-scan or forget.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get pickFolderTitle;

  /// Shown when re-scan/forget is chosen but no roots exist.
  ///
  /// In en, this message translates to:
  /// **'No library folders yet.'**
  String get noLibraryFolders;

  /// Message/toast when a library scan starts.
  ///
  /// In en, this message translates to:
  /// **'Scanning library…'**
  String get libraryScanStarted;

  /// Message/toast when a library scan finishes successfully.
  ///
  /// In en, this message translates to:
  /// **'Library scan complete.'**
  String get libraryScanComplete;

  /// Message/toast when the user cancels a scan.
  ///
  /// In en, this message translates to:
  /// **'Library scan cancelled.'**
  String get libraryScanCancelled;

  /// Message/toast when a library scan fails.
  ///
  /// In en, this message translates to:
  /// **'Library scan failed.'**
  String get libraryScanFailed;

  /// Message/toast when a persisted folder grant is missing.
  ///
  /// In en, this message translates to:
  /// **'Folder access was revoked.'**
  String get libraryRootRevoked;

  /// Message/toast after forgetting a folder.
  ///
  /// In en, this message translates to:
  /// **'Folder forgotten.'**
  String get libraryForgetComplete;

  /// Message/toast when grant release fails after DB delete.
  ///
  /// In en, this message translates to:
  /// **'Folder removed locally, but access release failed.'**
  String get libraryForgetFailed;

  /// Subtitle when a track has no artist tag.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// Message when resolve/SAF cannot open the current track.
  ///
  /// In en, this message translates to:
  /// **'Track file is missing or inaccessible.'**
  String get playerFileMissing;

  /// Message when the audio engine fails to load a source.
  ///
  /// In en, this message translates to:
  /// **'Could not load track for playback.'**
  String get playerLoadFailed;

  /// Info when cold-start resume entry was removed from the queue.
  ///
  /// In en, this message translates to:
  /// **'Previous track is no longer in the queue.'**
  String get playerRestoreSkipped;

  /// Error when consecutive missing/load skips hit the N=5 bound.
  ///
  /// In en, this message translates to:
  /// **'Stopped after several unplayable tracks in a row.'**
  String get playerSkipBoundReached;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
