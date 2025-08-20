import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Brew Master'**
  String get appTitle;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @tabInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get tabInstalled;

  /// No description provided for @tabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get tabDiscover;

  /// No description provided for @tabUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get tabUpdates;

  /// No description provided for @tabServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get tabServices;

  /// No description provided for @tabCleanup.
  ///
  /// In en, this message translates to:
  /// **'Cleanup'**
  String get tabCleanup;

  /// No description provided for @tabRecommend.
  ///
  /// In en, this message translates to:
  /// **'Recommend'**
  String get tabRecommend;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsInstantHint.
  ///
  /// In en, this message translates to:
  /// **'Changes take effect immediately. You can go back.'**
  String get settingsInstantHint;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get langSystem;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get langChineseSimplified;

  /// No description provided for @langChineseTraditional.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Traditional)'**
  String get langChineseTraditional;

  /// No description provided for @actionCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check updates'**
  String get actionCheckUpdates;

  /// No description provided for @actionViewUpdates.
  ///
  /// In en, this message translates to:
  /// **'View updates'**
  String get actionViewUpdates;

  /// No description provided for @actionCleanNow.
  ///
  /// In en, this message translates to:
  /// **'Clean now'**
  String get actionCleanNow;

  /// No description provided for @actionManageServices.
  ///
  /// In en, this message translates to:
  /// **'Manage services'**
  String get actionManageServices;

  /// No description provided for @labelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get labelHome;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get actionStop;

  /// No description provided for @actionRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get actionRestart;

  /// No description provided for @actionViewLogsDir.
  ///
  /// In en, this message translates to:
  /// **'Open logs directory'**
  String get actionViewLogsDir;

  /// No description provided for @labelPorts.
  ///
  /// In en, this message translates to:
  /// **'Ports:'**
  String get labelPorts;

  /// No description provided for @labelResources.
  ///
  /// In en, this message translates to:
  /// **'Resources:'**
  String get labelResources;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionUninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get actionUninstall;

  /// No description provided for @textIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This operation cannot be undone.'**
  String get textIrreversible;

  /// No description provided for @actionBulkUninstall.
  ///
  /// In en, this message translates to:
  /// **'Bulk uninstall'**
  String get actionBulkUninstall;

  /// No description provided for @actionClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get actionClearSelection;

  /// No description provided for @actionOpenHomepage.
  ///
  /// In en, this message translates to:
  /// **'Homepage ↗'**
  String get actionOpenHomepage;

  /// No description provided for @actionReinstall.
  ///
  /// In en, this message translates to:
  /// **'Reinstall'**
  String get actionReinstall;

  /// No description provided for @actionLoadFiles.
  ///
  /// In en, this message translates to:
  /// **'Load file list (via brew ls)'**
  String get actionLoadFiles;

  /// No description provided for @actionLoadAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Load historical versions'**
  String get actionLoadAlternatives;

  /// No description provided for @actionInstallThisVersion.
  ///
  /// In en, this message translates to:
  /// **'Install this version'**
  String get actionInstallThisVersion;

  /// No description provided for @titleManualExtractInstall.
  ///
  /// In en, this message translates to:
  /// **'Manually extract and install a specific version'**
  String get titleManualExtractInstall;

  /// No description provided for @actionExtractInstall.
  ///
  /// In en, this message translates to:
  /// **'Extract and install'**
  String get actionExtractInstall;

  /// No description provided for @warnMayUpgradeDeps.
  ///
  /// In en, this message translates to:
  /// **'Dependencies may be upgraded'**
  String get warnMayUpgradeDeps;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionRetest.
  ///
  /// In en, this message translates to:
  /// **'Re-run checks'**
  String get actionRetest;

  /// No description provided for @actionSaveAndCheck.
  ///
  /// In en, this message translates to:
  /// **'Save and check'**
  String get actionSaveAndCheck;

  /// No description provided for @actionOpenHomebrewSite.
  ///
  /// In en, this message translates to:
  /// **'Open Homebrew website'**
  String get actionOpenHomebrewSite;

  /// No description provided for @actionIInstalledRecheck.
  ///
  /// In en, this message translates to:
  /// **'I have installed, recheck'**
  String get actionIInstalledRecheck;

  /// No description provided for @messageOpenHomepageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open homepage link'**
  String get messageOpenHomepageFailed;

  /// No description provided for @dashboardFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching…'**
  String get dashboardFetching;

  /// No description provided for @dashboardPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get dashboardPleaseWait;

  /// No description provided for @dashboardFoundUpdatesN.
  ///
  /// In en, this message translates to:
  /// **'Found {count} updates'**
  String dashboardFoundUpdatesN(Object count);

  /// No description provided for @dashboardNoUpdates.
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get dashboardNoUpdates;

  /// No description provided for @dashboardTapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get dashboardTapForDetails;

  /// No description provided for @dashboardHealthOk.
  ///
  /// In en, this message translates to:
  /// **'System healthy (all checks passed)'**
  String get dashboardHealthOk;

  /// No description provided for @dashboardFoundIssuesN.
  ///
  /// In en, this message translates to:
  /// **'Found {count} issues'**
  String dashboardFoundIssuesN(Object count);

  /// No description provided for @dashboardCleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'System cleanup'**
  String get dashboardCleanupTitle;

  /// No description provided for @dashboardCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating…'**
  String get dashboardCalculating;

  /// No description provided for @dashboardNoCleanupNeeded.
  ///
  /// In en, this message translates to:
  /// **'Nothing to clean'**
  String get dashboardNoCleanupNeeded;

  /// No description provided for @dashboardCanFreeSize.
  ///
  /// In en, this message translates to:
  /// **'Can free {size}'**
  String dashboardCanFreeSize(Object size);

  /// No description provided for @dashboardServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Background services'**
  String get dashboardServicesTitle;

  /// No description provided for @dashboardRunning.
  ///
  /// In en, this message translates to:
  /// **'Running:'**
  String get dashboardRunning;

  /// No description provided for @dashboardStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped:'**
  String get dashboardStopped;

  /// No description provided for @updatesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'May upgrade dependencies'**
  String get updatesDialogTitle;

  /// No description provided for @updatesDialogContentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Upgrading {name} may also upgrade:\n'**
  String updatesDialogContentPrefix(Object name);

  /// No description provided for @updatesUpgradeAll.
  ///
  /// In en, this message translates to:
  /// **'Upgrade all'**
  String get updatesUpgradeAll;

  /// No description provided for @updatesUpgradeSelected.
  ///
  /// In en, this message translates to:
  /// **'Upgrade selected ({count})'**
  String updatesUpgradeSelected(Object count);

  /// No description provided for @updatesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search updates…'**
  String get updatesSearchHint;

  /// No description provided for @updatesSortByName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get updatesSortByName;

  /// No description provided for @updatesSortBySize.
  ///
  /// In en, this message translates to:
  /// **'By size'**
  String get updatesSortBySize;

  /// No description provided for @updatesAllUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Great! Everything is up to date.'**
  String get updatesAllUpToDate;

  /// No description provided for @updatesEstimatedDownload.
  ///
  /// In en, this message translates to:
  /// **'Estimated download: {size}'**
  String updatesEstimatedDownload(Object size);

  /// No description provided for @updatesMayAffectDeps.
  ///
  /// In en, this message translates to:
  /// **'Note: may affect {count} dependencies'**
  String updatesMayAffectDeps(Object count);

  /// No description provided for @updatesViewChangelog.
  ///
  /// In en, this message translates to:
  /// **'View changelog'**
  String get updatesViewChangelog;

  /// No description provided for @updatesUpgrading.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get updatesUpgrading;

  /// No description provided for @updatesUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get updatesUpgrade;

  /// No description provided for @updatesChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updatesChecking;

  /// No description provided for @servicesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching services'**
  String get servicesNoResults;

  /// No description provided for @servicesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search services…'**
  String get servicesSearchHint;

  /// No description provided for @servicesCopyPath.
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get servicesCopyPath;

  /// No description provided for @servicesProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get servicesProcessing;

  /// No description provided for @servicesDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get servicesDetails;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'System Health Check'**
  String get healthTitle;

  /// No description provided for @healthIntroOk.
  ///
  /// In en, this message translates to:
  /// **'Your Homebrew environment passed all the checks below.'**
  String get healthIntroOk;

  /// No description provided for @healthDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'brew doctor found no issues'**
  String get healthDoctorTitle;

  /// No description provided for @healthDoctorDescription.
  ///
  /// In en, this message translates to:
  /// **'All checks passed'**
  String get healthDoctorDescription;

  /// No description provided for @healthRepoTitle.
  ///
  /// In en, this message translates to:
  /// **'Homebrew core repository status'**
  String get healthRepoTitle;

  /// No description provided for @healthPathTitle.
  ///
  /// In en, this message translates to:
  /// **'System PATH configuration'**
  String get healthPathTitle;

  /// No description provided for @healthXcodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Xcode command line tools'**
  String get healthXcodeTitle;

  /// No description provided for @healthMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing dependencies'**
  String get healthMissingTitle;

  /// No description provided for @healthChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get healthChecking;

  /// No description provided for @healthAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing brew doctor output…'**
  String get healthAnalyzing;

  /// No description provided for @healthReadingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reading prefix path…'**
  String get healthReadingPrefix;

  /// No description provided for @healthCheckingPath.
  ///
  /// In en, this message translates to:
  /// **'Checking PATH…'**
  String get healthCheckingPath;

  /// No description provided for @healthCheckingXcode.
  ///
  /// In en, this message translates to:
  /// **'Checking installation status…'**
  String get healthCheckingXcode;

  /// No description provided for @healthScanningDeps.
  ///
  /// In en, this message translates to:
  /// **'Scanning missing dependencies…'**
  String get healthScanningDeps;

  /// No description provided for @healthNoMissingDeps.
  ///
  /// In en, this message translates to:
  /// **'No missing dependencies found'**
  String get healthNoMissingDeps;

  /// No description provided for @healthFoundIssues.
  ///
  /// In en, this message translates to:
  /// **'Found {count} issues'**
  String healthFoundIssues(Object count);

  /// No description provided for @healthCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Check failed: {error}'**
  String healthCheckFailed(Object error);

  /// No description provided for @healthCheckComplete.
  ///
  /// In en, this message translates to:
  /// **'Check complete ✅'**
  String get healthCheckComplete;

  /// No description provided for @healthCheckStart.
  ///
  /// In en, this message translates to:
  /// **'Starting system health check...'**
  String get healthCheckStart;

  /// No description provided for @healthExecuteDoctor.
  ///
  /// In en, this message translates to:
  /// **'Execute: brew doctor'**
  String get healthExecuteDoctor;

  /// No description provided for @healthDoctorPassed.
  ///
  /// In en, this message translates to:
  /// **'brew doctor passed'**
  String get healthDoctorPassed;

  /// No description provided for @healthDoctorWarnings.
  ///
  /// In en, this message translates to:
  /// **'brew doctor found {count} warnings (non-fatal)'**
  String healthDoctorWarnings(Object count);

  /// No description provided for @healthReadPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reading brew prefix...'**
  String get healthReadPrefix;

  /// No description provided for @healthPrefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix: {prefix}'**
  String healthPrefix(Object prefix);

  /// No description provided for @healthCheckPath.
  ///
  /// In en, this message translates to:
  /// **'Checking if PATH contains {prefix}/bin...'**
  String healthCheckPath(Object prefix);

  /// No description provided for @healthPathContains.
  ///
  /// In en, this message translates to:
  /// **'PATH contains {prefix}/bin'**
  String healthPathContains(Object prefix);

  /// No description provided for @healthPathNeedsAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Consider adding {prefix}/bin to PATH'**
  String healthPathNeedsAdjustment(Object prefix);

  /// No description provided for @healthPathPassed.
  ///
  /// In en, this message translates to:
  /// **'PATH check passed'**
  String get healthPathPassed;

  /// No description provided for @healthPathNeedsFix.
  ///
  /// In en, this message translates to:
  /// **'PATH needs adjustment'**
  String get healthPathNeedsFix;

  /// No description provided for @healthCheckXcode.
  ///
  /// In en, this message translates to:
  /// **'Checking Xcode command line tools...'**
  String get healthCheckXcode;

  /// No description provided for @healthXcodeNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed, recommend: xcode-select --install'**
  String get healthXcodeNotInstalled;

  /// No description provided for @healthXcodeInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get healthXcodeInstalled;

  /// No description provided for @healthViewSuggestions.
  ///
  /// In en, this message translates to:
  /// **'View suggestions'**
  String get healthViewSuggestions;

  /// No description provided for @healthXcodeCLTPassed.
  ///
  /// In en, this message translates to:
  /// **'Xcode CLT installed'**
  String get healthXcodeCLTPassed;

  /// No description provided for @healthXcodeCLTNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Xcode CLT not installed'**
  String get healthXcodeCLTNotInstalled;

  /// No description provided for @healthScanMissingDeps.
  ///
  /// In en, this message translates to:
  /// **'Scanning missing dependencies...'**
  String get healthScanMissingDeps;

  /// No description provided for @healthNoMissingDepsFound.
  ///
  /// In en, this message translates to:
  /// **'No missing dependencies found'**
  String get healthNoMissingDepsFound;

  /// No description provided for @healthMissingDepsFound.
  ///
  /// In en, this message translates to:
  /// **'Found {count} missing dependencies'**
  String healthMissingDepsFound(Object count);

  /// No description provided for @healthMissingDepsFoundLog.
  ///
  /// In en, this message translates to:
  /// **'Found {count} missing dependencies'**
  String healthMissingDepsFoundLog(Object count);

  /// No description provided for @healthError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String healthError(Object error);

  /// No description provided for @cleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'System cleanup'**
  String get cleanupTitle;

  /// No description provided for @cleanupTotal.
  ///
  /// In en, this message translates to:
  /// **'Total can be freed: {size}'**
  String cleanupTotal(Object size);

  /// No description provided for @cleanupGroupCache.
  ///
  /// In en, this message translates to:
  /// **'Cached downloads'**
  String get cleanupGroupCache;

  /// No description provided for @cleanupGroupOutdated.
  ///
  /// In en, this message translates to:
  /// **'Outdated packages'**
  String get cleanupGroupOutdated;

  /// No description provided for @cleanupGroupUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Unlinked old versions'**
  String get cleanupGroupUnlinked;

  /// No description provided for @cleanupEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to clean'**
  String get cleanupEmpty;

  /// No description provided for @cleanupSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} items'**
  String cleanupSelectedCount(Object count);

  /// No description provided for @cleanupDone.
  ///
  /// In en, this message translates to:
  /// **'Cleanup completed'**
  String get cleanupDone;

  /// No description provided for @installedTitle.
  ///
  /// In en, this message translates to:
  /// **'Installed packages'**
  String get installedTitle;

  /// No description provided for @searchInstalledHint.
  ///
  /// In en, this message translates to:
  /// **'Search installed packages…'**
  String get searchInstalledHint;

  /// No description provided for @selectPackagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a package to view details'**
  String get selectPackagePlaceholder;

  /// No description provided for @statusTotalPackages.
  ///
  /// In en, this message translates to:
  /// **'Total {count} packages'**
  String statusTotalPackages(Object count);

  /// No description provided for @statusLastRefresh.
  ///
  /// In en, this message translates to:
  /// **'Last refresh: {time}'**
  String statusLastRefresh(Object time);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterFormulae.
  ///
  /// In en, this message translates to:
  /// **'Formulae'**
  String get filterFormulae;

  /// No description provided for @filterCasks.
  ///
  /// In en, this message translates to:
  /// **'Casks'**
  String get filterCasks;

  /// No description provided for @actionViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get actionViewDetails;

  /// No description provided for @actionCopyPath.
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get actionCopyPath;

  /// No description provided for @actionInstallInProgress.
  ///
  /// In en, this message translates to:
  /// **'Installing…'**
  String get actionInstallInProgress;

  /// No description provided for @actionLastOutput.
  ///
  /// In en, this message translates to:
  /// **'Last output:'**
  String get actionLastOutput;

  /// No description provided for @actionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed:'**
  String get actionLoadFailed;

  /// No description provided for @actionNoFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No files found'**
  String get actionNoFilesFound;

  /// No description provided for @actionUninstallConfirm.
  ///
  /// In en, this message translates to:
  /// **'Uninstall {name}?'**
  String actionUninstallConfirm(Object name);

  /// No description provided for @actionBulkUninstallConfirm.
  ///
  /// In en, this message translates to:
  /// **'Uninstall selected {count} packages?'**
  String actionBulkUninstallConfirm(Object count);

  /// No description provided for @actionHomepage.
  ///
  /// In en, this message translates to:
  /// **'Homepage:'**
  String get actionHomepage;

  /// No description provided for @actionLicense.
  ///
  /// In en, this message translates to:
  /// **'License:'**
  String get actionLicense;

  /// No description provided for @actionInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get actionInfo;

  /// No description provided for @actionFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get actionFiles;

  /// No description provided for @actionOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get actionOptions;

  /// No description provided for @actionDependencies.
  ///
  /// In en, this message translates to:
  /// **'Dependencies'**
  String get actionDependencies;

  /// No description provided for @actionHistoricalVersions.
  ///
  /// In en, this message translates to:
  /// **'Historical versions'**
  String get actionHistoricalVersions;

  /// No description provided for @actionNoVersionedFormulae.
  ///
  /// In en, this message translates to:
  /// **'No versioned formulae found.'**
  String get actionNoVersionedFormulae;

  /// No description provided for @actionExtractInstallHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: Many formulae don\'t maintain versioned aliases. You can use \"Extract and install\" below to specify a version directly.'**
  String get actionExtractInstallHint;

  /// No description provided for @actionCaskNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Historical versions and compilation options are currently only supported for Formulae.'**
  String get actionCaskNotSupported;

  /// No description provided for @actionLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get actionLearnMore;

  /// No description provided for @actionInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get actionInstall;

  /// No description provided for @actionInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing…'**
  String get actionInstalling;

  /// No description provided for @actionInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get actionInstalled;

  /// No description provided for @splashWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Brew Master'**
  String get splashWelcome;

  /// No description provided for @splashNoBrew.
  ///
  /// In en, this message translates to:
  /// **'Homebrew is not detected. You can install it or specify the brew path below.'**
  String get splashNoBrew;

  /// No description provided for @hintBrewPath.
  ///
  /// In en, this message translates to:
  /// **'Custom brew path (optional)'**
  String get hintBrewPath;

  /// No description provided for @dashboardHelloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String dashboardHelloUser(Object name);

  /// No description provided for @packagesSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} packages'**
  String packagesSelectedCount(Object count);

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @updatesEta.
  ///
  /// In en, this message translates to:
  /// **'ETA {time}'**
  String updatesEta(Object time);

  /// No description provided for @updatesAlsoUpgrading.
  ///
  /// In en, this message translates to:
  /// **'Also upgrading: {names}'**
  String updatesAlsoUpgrading(Object names);

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @labelThisWeekFeatured.
  ///
  /// In en, this message translates to:
  /// **'This week\'s featured'**
  String get labelThisWeekFeatured;

  /// No description provided for @settingsPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance mode'**
  String get settingsPerformance;

  /// No description provided for @tapsTitle.
  ///
  /// In en, this message translates to:
  /// **'Taps'**
  String get tapsTitle;

  /// No description provided for @tapsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No taps yet'**
  String get tapsEmpty;

  /// No description provided for @textExtractPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Extract the bottle from Homebrew\'s Git history and install it manually.'**
  String get textExtractPrinciple;

  /// No description provided for @depsNone.
  ///
  /// In en, this message translates to:
  /// **'No dependency relationships'**
  String get depsNone;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.scriptCode) {
    case 'Hant': return AppLocalizationsZhHant();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
