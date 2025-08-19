import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

// Your models - these should match your project structure
import '../models/outdated_package.dart';
import '../models/package.dart';
import '../models/service_item.dart';

/// ## BrewService - A Robust Service for Homebrew Interaction
///
/// This service implements a "find once, use forever" strategy for locating the
/// Homebrew executable.
///
/// It finds a valid `brew` path upon first request and caches it. All subsequent
/// commands use this confirmed, absolute path, making the service resilient to
/// inconsistent `PATH` environments and preventing crashes related to process execution.
class BrewService {
  /// Caches the found, valid, absolute path to the `brew` executable.
  String? _brewPath;

  /// Finds and caches a valid `brew` executable path.
  ///
  /// This is the primary method for ensuring Homebrew is available. It checks
  /// common locations and verifies that the found executable is runnable. The result
  /// is stored in `_brewPath` for all other methods to use.
  Future<bool> isBrewInstalled() async {
    // If we've already found a valid path, return true immediately.
    if (_brewPath != null && await File(_brewPath!).exists()) {
      return true;
    }

    print('[BrewService] Searching for a valid brew executable...');
    try {
      // 1. Check `which brew` first.
      String whichResult = '';
      try {
        final r = await Process.run('which', ['brew']);
        if (r.exitCode == 0) {
          whichResult = r.stdout.toString().trim();
        }
      } catch (e) {
        print('[BrewService] The `which brew` command failed: $e');
      }

      // 2. Get user-preferred path from settings.
      final override = await _getPreferredBrewPath();

      // 3. Build a unique list of candidate paths to check.
      final candidates = <String>{
        if (override != null && override.isNotEmpty) override,
        if (whichResult.isNotEmpty) whichResult,
        '/opt/homebrew/bin/brew', // Apple Silicon default
        '/usr/local/bin/brew',   // Intel default
      }.toList();

      print('[BrewService] Candidates to check: $candidates');

      // 4. Loop through candidates and find the first one that works.
      for (final path in candidates) {
        try {
          if (await File(path).exists()) {
            final v = await Process.run(path, ['--version']);
            if (v.exitCode == 0) {
              print('[BrewService] Found valid brew executable at: $path');
              _brewPath = path; // Critical: Store the valid path.
              return true;
            }
          }
        } catch (_) {
          // Ignore errors for a specific candidate and try the next one.
        }
      }

      // If the loop completes without returning, no valid brew was found.
      print('[BrewService] No valid brew executable found.');
      _brewPath = null;
      return false;
    } catch (_) {
      _brewPath = null;
      return false;
    }
  }

  /// A diagnostic method to probe all candidate paths and return their results.
  Future<List<(String path, int exit, String out)>> probeBrewCandidates() async {
    String whichResult = '';
    try {
      final r = await Process.run('which', ['brew']);
      if (r.exitCode == 0) whichResult = r.stdout.toString().trim();
    } catch (e) {
      print('[BrewService] `which brew` command failed in probeBrewCandidates: $e');
    }
    final override = await _getPreferredBrewPath();
    final cands = <String>{
      if (override != null && override.isNotEmpty) override,
      if (whichResult.isNotEmpty) whichResult,
      '/opt/homebrew/bin/brew',
      '/usr/local/bin/brew',
    }.toList();

    final results = <(String, int, String)>[];
    for (final p in cands) {
      try {
        if (!await File(p).exists()) {
          results.add((p, 404, 'File not found'));
          continue;
        }
        final r = await Process.run(p, ['--version']);
        results.add((p, r.exitCode, (r.stdout.toString() + r.stderr.toString())));
      } catch (e) {
        results.add((p, 127, e.toString()));
      }
    }
    return results;
  }

  /// Gets the user-defined custom path for brew.
  Future<String?> _getPreferredBrewPath() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('brew.custom_path');
  }

  /// Sets a user-defined custom path for brew, clearing the cached path to force a re-check.
  Future<void> setPreferredBrewPath(String? path) async {
    final sp = await SharedPreferences.getInstance();
    _brewPath = null; // Clear cache to force re-detection on next call.
    if (path == null || path.trim().isEmpty) {
      await sp.remove('brew.custom_path');
    } else {
      await sp.setString('brew.custom_path', path.trim());
    }
  }

  /// Core private method to run any brew command using the cached `_brewPath`.
  Future<ProcessResult> _runBrewCommand(List<String> args, {bool allowNonZero = false}) async {
    // Ensure the brew path is known before running any command.
    if (_brewPath == null) {
      if (!await isBrewInstalled()) {
        // If brew cannot be found, throw a clear, catchable exception.
        throw BrewCommandException('Homebrew executable could not be found. Please check your installation.');
      }
    }

    print('[BrewService] Running command: $_brewPath ${args.join(' ')}');
    ProcessResult result = await Process.run(_brewPath!, args);

    // Retry logic for flaky Homebrew API
    bool needsRetry = result.exitCode != 0 &&
        (result.stderr.toString().contains('Cannot download non-corrupt') ||
            result.stdout.toString().contains('Cannot download non-corrupt'));
    if (needsRetry) {
      print('[BrewService] Retrying command with API disabled...');
      final env = {'HOMEBREW_NO_INSTALL_FROM_API': '1', 'HOMEBREW_NO_GITHUB_API': '1'};
      result = await Process.run(_brewPath!, args, environment: env);
    }

    if (result.exitCode != 0 && !allowNonZero) {
      throw BrewCommandException('Error running "brew ${args.join(' ')}":\n${result.stderr}${result.stdout}');
    }
    return result;
  }

  /// Core private method to start a streaming process using the cached `_brewPath`.
  Future<Process> _startWithPty(List<String> brewArgs) async {
    if (_brewPath == null) {
      if (!await isBrewInstalled()) {
        throw BrewCommandException('Homebrew executable could not be found. Please check your installation.');
      }
    }

    // On macOS, the BSD 'script' command does not support '-c'; using it will output
    // "script: -c: No such file or directory". Start the process directly instead.
    return await Process.start(_brewPath!, brewArgs);
  }

  // =======================================================================
  // All public methods below this line now automatically use the robust
  // _runBrewCommand and _startWithPty methods. Your original methods are preserved.
  // =======================================================================

  Future<void> updateBrewMetadata() async {
    await _runBrewCommand(['update']);
  }

  Future<Map<String, dynamic>> getPackageInfoJson(String name) async {
    final res = await _runBrewCommand(['info', '--json=v2', name], allowNonZero: true);
    return jsonDecode(res.stdout) as Map<String, dynamic>;
  }

  Future<List<Map<String, String>>> getFormulaOptions(String formulaName) async {
    final json = await getPackageInfoJson(formulaName);
    final list = (json['formulae'] as List?)?.cast<Map<String, dynamic>>();
    if (list == null || list.isEmpty) return [];
    final opts = (list.first['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return opts
        .map((e) => {
      'option': (e['option'] ?? '').toString(),
      'description': (e['description'] ?? '').toString(),
    })
        .toList();
  }

  Future<String?> getCaskIconPngPath(String caskName) async {
    try {
      final res = await _runBrewCommand(['list', '--cask', '--verbose', caskName], allowNonZero: true);
      final lines = res.stdout.toString().split('\n');
      String? appPath = lines.firstWhere(
            (l) => l.trim().endsWith('.app') && l.contains('/Applications/'),
        orElse: () => '',
      );
      if (appPath.isEmpty) return null;
      final icnsPath = await _findIcnsInApp(appPath.trim());
      if (icnsPath == null) return null;
      final outPath = '/tmp/brewmaster_${caskName}.png';
      final conv = await Process.run('sips', ['-s', 'format', 'png', icnsPath, '--out', outPath]);
      if (conv.exitCode == 0 && await File(outPath).exists()) {
        return outPath;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _findIcnsInApp(String appPath) async {
    final dir = Directory('$appPath/Contents/Resources');
    if (!await dir.exists()) return null;
    final entries = await dir.list().toList();
    for (final e in entries) {
      if (e is File && e.path.toLowerCase().endsWith('.icns')) return e.path;
    }
    return null;
  }

  Future<List<String>> listDependencies(String packageName) async {
    final res = await _runBrewCommand(['deps', '--installed', packageName], allowNonZero: true);
    return res.stdout.toString().split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  Future<Set<String>> listOutdatedNames() async {
    final pkgs = await getOutdatedPackages();
    return pkgs.map((e) => e.name).toSet();
  }

  Future<List<String>> listFiles(String packageName, {required bool isCask}) async {
    if (isCask) {
      final res = await _runBrewCommand(['list', '--cask', packageName], allowNonZero: true);
      return res.stdout.toString().split('\n').where((e) => e.trim().isNotEmpty).toList();
    } else {
      final res = await _runBrewCommand(['list', '--verbose', packageName], allowNonZero: true);
      return res.stdout.toString().split('\n').where((e) => e.trim().isNotEmpty).toList();
    }
  }

  Future<void> reinstallPackage(String packageName, {required bool isCask}) async {
    final args = ['reinstall'];
    if (isCask) args.add('--cask');
    args.add(packageName);
    await _runBrewCommand(args);
  }

  Future<void> pinPackage(String packageName) async {
    await _runBrewCommand(['pin', packageName]);
  }

  Future<void> unpinPackage(String packageName) async {
    await _runBrewCommand(['unpin', packageName]);
  }

  Future<List<String>> getInstalledPackages({bool isCask = false}) async {
    final flag = isCask ? '--casks' : '--formulae';
    final result = await _runBrewCommand(['list', flag]);
    return result.stdout.toString().split('\n').where((s) => s.isNotEmpty).toList();
  }

  Future<List<String>> getVersionedAlternatives(String formulaName) async {
    final res = await _runBrewCommand(['info', '--json=v2', formulaName], allowNonZero: true);
    final json = jsonDecode(res.stdout) as Map<String, dynamic>;
    final list = (json['formulae'] as List?)?.cast<Map<String, dynamic>>();
    if (list == null || list.isEmpty) return [];
    final alt = (list.first['versioned_formulae'] as List?)?.cast<String>() ?? [];
    return alt;
  }

  Future<void> extractAndInstallSpecificVersion(String formulaName, String version,
      {String tap = 'local/versions', void Function(String line)? onLine}) async {
    try {
      final taps = await _runBrewCommand(['tap'], allowNonZero: true);
      if (!taps.stdout.toString().split('\n').any((t) => t.trim() == tap)) {
        await _runBrewCommand(['tap-new', tap]);
      }
    } catch (_) {}
    await _runBrewCommand(['extract', '--version=$version', formulaName, tap]);
    final extractedName = '$tap/${formulaName.toLowerCase()}@$version';
    await streamInstallPackage(extractedName, onLine: onLine);
  }

  Future<List<Package>> getPackagesInfo(List<String> packageNames, {bool isCask = false}) async {
    if (packageNames.isEmpty) {
      return [];
    }
    try {
      final result = await _runBrewCommand(['info', '--json=v2', ...packageNames]);
      final json = jsonDecode(result.stdout) as Map<String, dynamic>;
      final packages = <Package>[];
      final formulae = (json['formulae'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final packageJson in formulae) {
        packages.add(Package.fromJson(packageJson, isCask: false));
      }
      final casks = (json['casks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final packageJson in casks) {
        packages.add(Package.fromJson(packageJson, isCask: true));
      }
      return packages;
    } catch (_) {
      final List<Package> out = [];
      for (final name in packageNames) {
        try {
          final node = await getPackageInfoJson(name);
          final formulae = (node['formulae'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final casks = (node['casks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          if (formulae.isNotEmpty) {
            out.add(Package.fromJson(formulae.first, isCask: false));
          } else if (casks.isNotEmpty) {
            out.add(Package.fromJson(casks.first, isCask: true));
          }
        } catch (_) {}
      }
      return out;
    }
  }

  Future<List<Package>> searchPackages(String query, {int limit = 30}) async {
    if (query.trim().isEmpty) return [];
    final formulaeRes = await _runBrewCommand(['search', '--formulae', query], allowNonZero: true);
    final casksRes = await _runBrewCommand(['search', '--casks', query], allowNonZero: true);
    final fNames = formulaeRes.stdout.toString().split('\n').where((s) => s.trim().isNotEmpty).take(limit ~/ 2).toList();
    final cNames = casksRes.stdout.toString().split('\n').where((s) => s.trim().isNotEmpty).take(limit ~/ 2).toList();
    final names = [...fNames, ...cNames];
    if (names.isEmpty) return [];
    return getPackagesInfo(names);
  }

  // 仅返回搜索到的名称与是否为 cask，用于懒加载详情
  Future<List<(String name, bool isCask)>> searchNames(String query, {int limit = 40}) async {
    if (query.trim().isEmpty) return [];
    final half = (limit / 2).floor();
    final formulaeRes = await _runBrewCommand(['search', '--formulae', query], allowNonZero: true);
    final casksRes = await _runBrewCommand(['search', '--casks', query], allowNonZero: true);
    final f = formulaeRes.stdout.toString().split('\n').where((s) => s.trim().isNotEmpty).take(half).map((e) => (e.trim(), false));
    final c = casksRes.stdout.toString().split('\n').where((s) => s.trim().isNotEmpty).take(half).map((e) => (e.trim(), true));
    return [...f, ...c];
  }

  // ====== Services helpers (non-brew commands) ======
  Future<List<int>> listServiceListeningPorts(String name) async {
    try {
      final res = await Process.run('bash', ['-lc', 'lsof -nP -iTCP -sTCP:LISTEN | grep -i ${_escape(name)} || true']);
      final lines = res.stdout.toString().split('\n');
      final ports = <int>{};
      // 仅匹配 ]:PORT 或 非双冒号的 :PORT，避免把 IPv6 ::1 的“1”当作端口
      final re = RegExp(r'(?:\]:(\d+)|(?<!:):(\d+))');
      for (final l in lines) {
        for (final m in re.allMatches(l)) {
          final grp = m.group(1) ?? m.group(2);
          final p = int.tryParse(grp ?? '');
          if (p != null) ports.add(p);
        }
      }
      return ports.toList()..sort();
    } catch (_) { return []; }
  }

  Future<(double cpu, double mem)?> getProcessCpuMem(String name) async {
    try {
      final res = await Process.run('bash', ['-lc', 'ps -axo %cpu,%mem,comm | grep -i ${_escape(name)} | grep -v grep | head -n 1']);
      final line = res.stdout.toString().trim();
      if (line.isEmpty) return null;
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final cpu = double.tryParse(parts[0]) ?? 0;
        final mem = double.tryParse(parts[1]) ?? 0;
        return (cpu, mem);
      }
      return null;
    } catch (_) { return null; }
  }

  Future<void> openLogsDirectory([String? name]) async {
    try {
      final home = Platform.environment['HOME'] ?? '';
      final dir = '$home/Library/Logs';
      await Process.run('open', [dir]);
    } catch (_) {}
  }

  String _escape(String s) => s.replaceAll("'", "'\\''");

  Future<int> streamInstallPackage(String name, {bool isCask = false, void Function(String line)? onLine}) async {
    final args = <String>['install'];
    if (isCask) args.add('--cask');
    args.add(name);
    final process = await _startWithPty(args);
    final completer = Completer<int>();
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) => onLine?.call(line));
    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) => onLine?.call(line));
    process.exitCode.then((code) => completer.complete(code));
    return completer.future;
  }

  Future<int> streamUpgradePackage(String packageName, {bool isCask = false, void Function(String line)? onLine}) async {
    final args = <String>['upgrade'];
    if (isCask) args.add('--cask');
    args.add(packageName);
    final process = await _startWithPty(args);
    final completer = Completer<int>();
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) => onLine?.call(line));
    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) => onLine?.call(line));
    process.exitCode.then((code) => completer.complete(code));
    return completer.future;
  }

  Future<List<OutdatedPackage>> getOutdatedPackages() async {
    try {
      final result = await _runBrewCommand(['outdated', '--json']);
      final json = jsonDecode(result.stdout) as Map<String, dynamic>;
      final formulae = (json['formulae'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final casks = (json['casks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return [
        ...formulae.map((e) => OutdatedPackage.fromJson(e, isCask: false)),
        ...casks.map((e) => OutdatedPackage.fromJson(e, isCask: true)),
      ];
    } catch (e) {
      final result = await _runBrewCommand(['outdated'], allowNonZero: true);
      final lines = result.stdout.toString().split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.isEmpty) return [];
      final caskNames = await getInstalledPackages(isCask: true).then((l) => l.toSet());
      final list = <OutdatedPackage>[];
      final re = RegExp(r'^(?<name>[\w@+\-.]+)\s+(?<from>\S+)\s+->\s+(?<to>\S+)');
      for (final l in lines) {
        final m = re.firstMatch(l);
        if (m == null) continue;
        final name = m.namedGroup('name')!;
        final from = m.namedGroup('from')!;
        final to = m.namedGroup('to')!;
        list.add(OutdatedPackage(name: name, installedVersions: [from], currentVersion: to, isCask: caskNames.contains(name)));
      }
      return list;
    }
  }

  Future<void> upgradePackage(String packageName) async {
    try {
      await _runBrewCommand(['upgrade', packageName]);
    } on BrewCommandException {
      await _runBrewCommand(['upgrade', '--cask', packageName]);
    }
  }

  Future<void> upgradeAllPackages() async {
    await _runBrewCommand(['upgrade']);
  }

  Future<void> uninstallPackage(String packageName, {required bool isCask}) async {
    final args = ['uninstall', packageName];
    if (isCask) {
      args.add('--cask');
    }
    await _runBrewCommand(args);
  }

  Future<int> countInstalledFormulae() async {
    final result = await _runBrewCommand(['list', '--formulae']);
    return result.stdout.toString().split('\n').where((s) => s.isNotEmpty).length;
  }

  Future<int> countInstalledCasks() async {
    final result = await _runBrewCommand(['list', '--casks']);
    return result.stdout.toString().split('\n').where((s) => s.isNotEmpty).length;
  }

  Future<int> countTaps() async {
    final result = await _runBrewCommand(['tap']);
    return result.stdout.toString().split('\n').where((s) => s.isNotEmpty).length;
  }

  Future<int> countOutdated() async {
    try {
      final result = await _runBrewCommand(['outdated', '--json']);
      final json = jsonDecode(result.stdout) as Map<String, dynamic>;
      final f = (json['formulae'] as List?)?.length ?? 0;
      final c = (json['casks'] as List?)?.length ?? 0;
      return f + c;
    } catch (_) {
      final list = await getOutdatedPackages();
      return list.length;
    }
  }

  Future<bool> isDoctorHealthy() async {
    final res = await _runBrewCommand(['doctor'], allowNonZero: true);
    final out = (res.stdout.toString() + res.stderr.toString()).toLowerCase();
    if (out.contains('ready to brew')) return true;
    return false;
  }

  Future<int> doctorIssuesCount() async {
    final res = await _runBrewCommand(['doctor'], allowNonZero: true);
    final text = (res.stdout.toString() + res.stderr.toString());
    final warnings = RegExp(r'^Warning:', multiLine: true).allMatches(text).length;
    return warnings;
  }

  Future<String> doctorRaw() async {
    final res = await _runBrewCommand(['doctor'], allowNonZero: true);
    return (res.stdout.toString() + res.stderr.toString());
  }

  Future<void> cleanupAll() async {
    await _runBrewCommand(['cleanup']);
  }

  Future<void> cleanupFormula(String name) async {
    await _runBrewCommand(['cleanup', name]);
  }

  Future<void> cleanupCache() async {
    await _runBrewCommand(['cleanup', '-s']);
  }

  Future<String> getBrewPrefix() async {
    final res = await _runBrewCommand(['--prefix']);
    return res.stdout.toString().trim();
  }

  Future<bool> isPathConfigured() async {
    try {
      final prefix = await getBrewPrefix();
      final path = Platform.environment['PATH'] ?? '';
      return path.split(':').any((p) => p == '$prefix/bin');
    } catch (_) {
      return false;
    }
  }

  Future<bool> isXcodeCLTInstalled() async {
    try {
      final res = await Process.run('xcode-select', ['-p']);
      return (res.exitCode == 0) && res.stdout.toString().toString().trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> listMissingDependencies() async {
    final res = await _runBrewCommand(['missing'], allowNonZero: true);
    final text = (res.stdout.toString() + res.stderr.toString()).trim();
    if (text.isEmpty) return const [];
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return lines;
  }

  Future<String> getCleanupPreviewSize() async {
    try {
      final result = await _runBrewCommand(['cleanup', '-n']);
      final out = result.stdout.toString();
      final regex = RegExp(r'(?:free|free up|would free).*?(\d+[\.,]?\d*\s*(?:kb|mb|gb|tb))', caseSensitive: false);
      final m = regex.firstMatch(out);
      if (m != null) {
        return m.group(1)!.toUpperCase().replaceAll(' ', ' ');
      }
      if (out.toLowerCase().contains('nothing to clean')) {
        return '0 B';
      }
      return '—';
    } catch (_) {
      return '—';
    }
  }

  Future<String> getCleanupPreviewText() async {
    try {
      final result = await _runBrewCommand(['cleanup', '-n']);
      final out = result.stdout.toString();
      if (out.trim().isEmpty) return 'Nothing to clean.';
      return out;
    } catch (e) {
      return e.toString();
    }
  }

  Future<(int running, int stoppedOrErrored)> getServicesSummary() async {
    try {
      final result = await _runBrewCommand(['services', 'list']);
      final lines = result.stdout.toString().split('\n');
      int running = 0;
      int stopped = 0;
      for (final line in lines.skip(1)) {
        if (line.trim().isEmpty) continue;
        final cols = line.trim().split(RegExp(r'\s+'));
        if (cols.length >= 2) {
          final status = cols[1].toLowerCase();
          if (status.contains('started') || status.contains('running')) {
            running++;
          } else {
            stopped++;
          }
        }
      }
      return (running, stopped);
    } catch (_) {
      return (0, 0);
    }
  }

  Future<List<ServiceItem>> listServices() async {
    try {
      final result = await _runBrewCommand(['services', 'list'], allowNonZero: true);
      final lines = result.stdout.toString().split('\n');
      final items = <ServiceItem>[];
      for (final line in lines.skip(1)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final cols = trimmed.split(RegExp(r'\s+'));
        if (cols.isEmpty) continue;
        final name = cols[0];
        String statusText = cols.length > 1 ? cols[1].toLowerCase() : 'unknown';
        String? user = cols.length > 2 ? cols[2] : null;
        String? filePath;
        if (cols.length > 3) {
          final firstThree = RegExp('^\\s*${RegExp.escape(cols[0])}\\s+${RegExp.escape(cols[1])}\\s+${RegExp.escape(cols[2])}\\s*');
          filePath = trimmed.replaceFirst(firstThree, '');
          if (filePath.isEmpty) filePath = null;
        }
        final status = statusText.contains('started') || statusText.contains('running')
            ? ServiceStatus.started
            : statusText.contains('stopped') || statusText.contains('none')
            ? ServiceStatus.stopped
            : statusText.contains('error')
            ? ServiceStatus.error
            : ServiceStatus.unknown;
        items.add(ServiceItem(name: name, status: status, user: user, filePath: filePath));
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> startService(String name) async {
    await _runBrewCommand(['services', 'start', name]);
  }

  Future<void> stopService(String name) async {
    await _runBrewCommand(['services', 'stop', name]);
  }

  Future<void> restartService(String name) async {
    await _runBrewCommand(['services', 'restart', name]);
  }

  Future<String?> getEstimatedBottleSize(String name) async {
    try {
      final info = await getPackageInfoJson(name);
      final formulae = (info['formulae'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final casks = (info['casks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      Map<String, dynamic>? node;
      if (formulae.isNotEmpty) node = formulae.first;
      if (node == null && casks.isNotEmpty) node = casks.first;
      if (node == null) return null;
      final bottle = node['bottle'];
      if (bottle is Map) {
        final stable = bottle['stable'];
        if (stable is Map) {
          final files = stable['files'];
          if (files is Map) {
            for (final v in files.values) {
              if (v is Map && v['size'] != null) {
                final bytes = (v['size'] as num).toDouble();
                return _humanBytes(bytes);
              }
            }
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Uri?> getChangeLogUrl(String name) async {
    try {
      final info = await getPackageInfoJson(name);
      final formulae = (info['formulae'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final casks = (info['casks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      Map<String, dynamic>? node;
      if (formulae.isNotEmpty) node = formulae.first;
      if (node == null && casks.isNotEmpty) node = casks.first;
      if (node == null) return null;
      final home = (node['homepage'] ?? '').toString();
      if (home.contains('github.com')) {
        final repo = RegExp(r'https?://github\.com/([\w\-]+)/([\w\-]+)').firstMatch(home);
        if (repo != null) {
          final owner = repo.group(1)!;
          final r = repo.group(2)!;
          return Uri.parse('https://github.com/$owner/$r/releases');
        }
      }
      return Uri.tryParse(home);
    } catch (_) {
      return null;
    }
  }

  String _humanBytes(double bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double v = bytes;
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(v < 10 ? 1 : 0)} ${units[i]}';
  }

  Future<Set<String>> _safeListCasks() async {
    try {
      final res = await _runBrewCommand(['list', '--casks'], allowNonZero: true);
      return res.stdout.toString().split('\n').where((e) => e.trim().isNotEmpty).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  // Return a list of all current taps
  Future<List<String>> listTaps() async {
    final result = await _runBrewCommand(['tap', '-', '-', 'read'], allowNonZero: true);
    return result.stdout.toString().split('\n').where((l) => l.isNotEmpty).toList();
  }

  // Get direct dependencies of a package
  Future<List<String>> getDependencies(String name) async {
    final result = await _runBrewCommand(['deps', name], allowNonZero: true);
    return result.stdout.toString().split('\n').where((l) => l.isNotEmpty).toList();
  }

  // Get packages that directly depend on a package
  Future<List<String>> getDependents(String name) async {
    final result = await _runBrewCommand(['uses', '--installed', name], allowNonZero: true);
    return result.stdout.toString().split('\n').where((l) => l.isNotEmpty).toList();
  }

  // 列出已安装的 formulae 或 casks 以及其版本（快速）
  Future<Map<String, String>> listInstalledVersions({required bool isCask}) async {
    final args = <String>['list', isCask ? '--cask' : '--formulae', '--versions'];
    final result = await _runBrewCommand(args, allowNonZero: true);
    final lines = result.stdout.toString().split('\n');
    final map = <String, String>{};
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      // 形如: name v1 v2 ... 取最后一个作为当前版本
      final parts = line.split(RegExp(r'\s+'));
      if (parts.isEmpty) continue;
      if (parts.length == 1) {
        map[parts.first] = '';
      } else {
        map[parts.first] = parts.last;
      }
    }
    return map;
  }

  // 批量获取包详情（沿用现有 info 能力）
  Future<List<Package>> getPackagesInfoBatch(List<String> names) async {
    return getPackagesInfo(names);
  }
}

class BrewCommandException implements Exception {
  final String message;
  BrewCommandException(this.message);

  @override
  String toString() => message;
}