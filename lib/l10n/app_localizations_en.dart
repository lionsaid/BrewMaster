// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Brew Master';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabInstalled => 'Installed';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabUpdates => 'Updates';

  @override
  String get tabServices => 'Services';

  @override
  String get tabCleanup => 'Cleanup';

  @override
  String get tabRecommend => 'Recommend';

  @override
  String get tabSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsInstantHint => 'Changes take effect immediately. You can go back.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get langSystem => 'Follow system';

  @override
  String get langEnglish => 'English';

  @override
  String get langChineseSimplified => 'Chinese (Simplified)';

  @override
  String get langChineseTraditional => 'Chinese (Traditional)';

  @override
  String get actionCheckUpdates => 'Check updates';

  @override
  String get actionViewUpdates => 'View updates';

  @override
  String get actionCleanNow => 'Clean now';

  @override
  String get actionManageServices => 'Manage services';

  @override
  String get labelHome => 'Home';

  @override
  String get actionClose => 'Close';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionStart => 'Start';

  @override
  String get actionStop => 'Stop';

  @override
  String get actionRestart => 'Restart';

  @override
  String get actionViewLogsDir => 'Open logs directory';

  @override
  String get labelPorts => 'Ports:';

  @override
  String get labelResources => 'Resources:';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionUninstall => 'Uninstall';

  @override
  String get textIrreversible => 'This operation cannot be undone.';

  @override
  String get actionBulkUninstall => 'Bulk uninstall';

  @override
  String get actionClearSelection => 'Clear selection';

  @override
  String get actionOpenHomepage => 'Homepage ↗';

  @override
  String get actionReinstall => 'Reinstall';

  @override
  String get actionLoadFiles => 'Load file list (via brew ls)';

  @override
  String get actionLoadAlternatives => 'Load historical versions';

  @override
  String get actionInstallThisVersion => 'Install this version';

  @override
  String get titleManualExtractInstall => 'Manually extract and install a specific version';

  @override
  String get actionExtractInstall => 'Extract and install';

  @override
  String get warnMayUpgradeDeps => 'Dependencies may be upgraded';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionRetest => 'Re-run checks';

  @override
  String get actionSaveAndCheck => 'Save and check';

  @override
  String get actionOpenHomebrewSite => 'Open Homebrew website';

  @override
  String get actionIInstalledRecheck => 'I have installed, recheck';

  @override
  String get messageOpenHomepageFailed => 'Failed to open homepage link';

  @override
  String get dashboardFetching => 'Fetching…';

  @override
  String get dashboardPleaseWait => 'Please wait';

  @override
  String dashboardFoundUpdatesN(Object count) {
    return 'Found $count updates';
  }

  @override
  String get dashboardNoUpdates => 'No updates available';

  @override
  String get dashboardTapForDetails => 'Tap to view details';

  @override
  String get dashboardHealthOk => 'System healthy (all checks passed)';

  @override
  String dashboardFoundIssuesN(Object count) {
    return 'Found $count issues';
  }

  @override
  String get dashboardCleanupTitle => 'System cleanup';

  @override
  String get dashboardCalculating => 'Calculating…';

  @override
  String get dashboardNoCleanupNeeded => 'Nothing to clean';

  @override
  String dashboardCanFreeSize(Object size) {
    return 'Can free $size';
  }

  @override
  String get dashboardServicesTitle => 'Background services';

  @override
  String get dashboardRunning => 'Running:';

  @override
  String get dashboardStopped => 'Stopped:';

  @override
  String get updatesDialogTitle => 'May upgrade dependencies';

  @override
  String updatesDialogContentPrefix(Object name) {
    return 'Upgrading $name may also upgrade:\n';
  }

  @override
  String get updatesUpgradeAll => 'Upgrade all';

  @override
  String updatesUpgradeSelected(Object count) {
    return 'Upgrade selected ($count)';
  }

  @override
  String get updatesSearchHint => 'Search updates…';

  @override
  String get updatesSortByName => 'By name';

  @override
  String get updatesSortBySize => 'By size';

  @override
  String get updatesAllUpToDate => 'Great! Everything is up to date.';

  @override
  String updatesEstimatedDownload(Object size) {
    return 'Estimated download: $size';
  }

  @override
  String updatesMayAffectDeps(Object count) {
    return 'Note: may affect $count dependencies';
  }

  @override
  String get updatesViewChangelog => 'View changelog';

  @override
  String get updatesUpgrading => 'In progress';

  @override
  String get updatesUpgrade => 'Upgrade';

  @override
  String get updatesChecking => 'Checking for updates…';

  @override
  String get servicesNoResults => 'No matching services';

  @override
  String get servicesSearchHint => 'Search services…';

  @override
  String get servicesCopyPath => 'Copy path';

  @override
  String get servicesProcessing => 'Processing…';

  @override
  String get servicesDetails => 'Details';

  @override
  String get healthTitle => 'System Health Check';

  @override
  String get healthIntroOk => 'Your Homebrew environment passed all the checks below.';

  @override
  String get healthDoctorTitle => 'brew doctor found no issues';

  @override
  String get healthDoctorDescription => 'All checks passed';

  @override
  String get healthRepoTitle => 'Homebrew core repository status';

  @override
  String get healthPathTitle => 'System PATH configuration';

  @override
  String get healthXcodeTitle => 'Xcode command line tools';

  @override
  String get healthMissingTitle => 'Missing dependencies';

  @override
  String get healthChecking => 'Checking…';

  @override
  String get healthAnalyzing => 'Analyzing brew doctor output…';

  @override
  String get healthReadingPrefix => 'Reading prefix path…';

  @override
  String get healthCheckingPath => 'Checking PATH…';

  @override
  String get healthCheckingXcode => 'Checking installation status…';

  @override
  String get healthScanningDeps => 'Scanning missing dependencies…';

  @override
  String get healthNoMissingDeps => 'No missing dependencies found';

  @override
  String healthFoundIssues(Object count) {
    return 'Found $count issues';
  }

  @override
  String healthCheckFailed(Object error) {
    return 'Check failed: $error';
  }

  @override
  String get healthCheckComplete => 'Check complete ✅';

  @override
  String get healthCheckStart => 'Starting system health check...';

  @override
  String get healthExecuteDoctor => 'Execute: brew doctor';

  @override
  String get healthDoctorPassed => 'brew doctor passed';

  @override
  String healthDoctorWarnings(Object count) {
    return 'brew doctor found $count warnings (non-fatal)';
  }

  @override
  String get healthReadPrefix => 'Reading brew prefix...';

  @override
  String healthPrefix(Object prefix) {
    return 'Prefix: $prefix';
  }

  @override
  String healthCheckPath(Object prefix) {
    return 'Checking if PATH contains $prefix/bin...';
  }

  @override
  String healthPathContains(Object prefix) {
    return 'PATH contains $prefix/bin';
  }

  @override
  String healthPathNeedsAdjustment(Object prefix) {
    return 'Consider adding $prefix/bin to PATH';
  }

  @override
  String get healthPathPassed => 'PATH check passed';

  @override
  String get healthPathNeedsFix => 'PATH needs adjustment';

  @override
  String get healthCheckXcode => 'Checking Xcode command line tools...';

  @override
  String get healthXcodeNotInstalled => 'Not installed, recommend: xcode-select --install';

  @override
  String get healthXcodeInstalled => 'Installed';

  @override
  String get healthViewSuggestions => 'View suggestions';

  @override
  String get healthXcodeCLTPassed => 'Xcode CLT installed';

  @override
  String get healthXcodeCLTNotInstalled => 'Xcode CLT not installed';

  @override
  String get healthScanMissingDeps => 'Scanning missing dependencies...';

  @override
  String get healthNoMissingDepsFound => 'No missing dependencies found';

  @override
  String healthMissingDepsFound(Object count) {
    return 'Found $count missing dependencies';
  }

  @override
  String healthMissingDepsFoundLog(Object count) {
    return 'Found $count missing dependencies';
  }

  @override
  String healthError(Object error) {
    return 'Error: $error';
  }

  @override
  String get cleanupTitle => 'System cleanup';

  @override
  String cleanupTotal(Object size) {
    return 'Total can be freed: $size';
  }

  @override
  String get cleanupGroupCache => 'Cached downloads';

  @override
  String get cleanupGroupOutdated => 'Outdated packages';

  @override
  String get cleanupGroupUnlinked => 'Unlinked old versions';

  @override
  String get cleanupEmpty => 'Nothing to clean';

  @override
  String cleanupSelectedCount(Object count) {
    return 'Selected $count items';
  }

  @override
  String get cleanupDone => 'Cleanup completed';

  @override
  String get installedTitle => 'Installed packages';

  @override
  String get searchInstalledHint => 'Search installed packages…';

  @override
  String get selectPackagePlaceholder => 'Select a package to view details';

  @override
  String statusTotalPackages(Object count) {
    return 'Total $count packages';
  }

  @override
  String statusLastRefresh(Object time) {
    return 'Last refresh: $time';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterFormulae => 'Formulae';

  @override
  String get filterCasks => 'Casks';

  @override
  String get actionViewDetails => 'View details';

  @override
  String get actionCopyPath => 'Copy path';

  @override
  String get actionInstallInProgress => 'Installing…';

  @override
  String get actionLastOutput => 'Last output:';

  @override
  String get actionLoadFailed => 'Load failed:';

  @override
  String get actionNoFilesFound => 'No files found';

  @override
  String actionUninstallConfirm(Object name) {
    return 'Uninstall $name?';
  }

  @override
  String actionBulkUninstallConfirm(Object count) {
    return 'Uninstall selected $count packages?';
  }

  @override
  String get actionHomepage => 'Homepage:';

  @override
  String get actionLicense => 'License:';

  @override
  String get actionInfo => 'Info';

  @override
  String get actionFiles => 'Files';

  @override
  String get actionOptions => 'Options';

  @override
  String get actionDependencies => 'Dependencies';

  @override
  String get actionHistoricalVersions => 'Historical versions';

  @override
  String get actionNoVersionedFormulae => 'No versioned formulae found.';

  @override
  String get actionExtractInstallHint => 'Tip: Many formulae don\'t maintain versioned aliases. You can use \"Extract and install\" below to specify a version directly.';

  @override
  String get actionCaskNotSupported => 'Historical versions and compilation options are currently only supported for Formulae.';

  @override
  String get actionLearnMore => 'Learn more';

  @override
  String get actionInstall => 'Install';

  @override
  String get actionInstalling => 'Installing…';

  @override
  String get actionInstalled => 'Installed';

  @override
  String get splashWelcome => 'Welcome to Brew Master';

  @override
  String get splashNoBrew => 'Homebrew is not detected. You can install it or specify the brew path below.';

  @override
  String get hintBrewPath => 'Custom brew path (optional)';

  @override
  String dashboardHelloUser(Object name) {
    return 'Hello, $name';
  }

  @override
  String packagesSelectedCount(Object count) {
    return 'Selected $count packages';
  }

  @override
  String get commonNone => 'None';

  @override
  String updatesEta(Object time) {
    return 'ETA $time';
  }

  @override
  String updatesAlsoUpgrading(Object names) {
    return 'Also upgrading: $names';
  }

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get labelThisWeekFeatured => 'This week\'s featured';

  @override
  String get settingsPerformance => 'Performance mode';

  @override
  String get tapsTitle => 'Taps';

  @override
  String get tapsEmpty => 'No taps yet';

  @override
  String get textExtractPrinciple => 'Extract the bottle from Homebrew\'s Git history and install it manually.';

  @override
  String get depsNone => 'No dependency relationships';
}
