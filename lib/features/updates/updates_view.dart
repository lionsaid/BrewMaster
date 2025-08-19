import 'package:brew_master/core/models/outdated_package.dart';
import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:brew_master/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdatesView extends StatefulWidget {
  const UpdatesView({super.key});

  @override
  State<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<UpdatesView> {
  final BrewService _brew = BrewService();
  bool _loading = true; // initial page load
  bool _updating = false; // upgrading in progress
  bool _checking = false; // brew update overlay
  List<OutdatedPackage> _items = [];
  String? _upgradingName;
  String _lastLine = '';
  String _extraNote = '';
  final Set<String> _inProgress = <String>{}; // per-row guard
  final Set<String> _selected = <String>{}; // multi-select

  // enrich caches
  final Map<String, String?> _sizeCache = {}; // human readable size
  final Map<String, Uri?> _changelogCache = {};
  final Map<String, int> _depImpact = {}; // how many deps also outdated

  // search/sort
  String _keyword = '';
  String _sort = 'name'; // name | size

  // Progress parsing state
  double? _pct; // 0..1, null = indeterminate
  DateTime? _pctStart;
  String _etaText = '';

  @override
  void initState() {
    super.initState();
    _loadOutdated();
  }

  Future<void> _loadOutdated({bool background = false}) async {
    if (!background) setState(() => _loading = true);
    try {
      final list = await _brew.getOutdatedPackages();
      setState(() => _items = list);
      // prefetch enrich info in background
      for (final p in list) {
        _brew.getEstimatedBottleSize(p.name).then((v) => mounted ? setState(() => _sizeCache[p.name] = v) : null);
        _brew.getChangeLogUrl(p.name).then((u) => mounted ? setState(() => _changelogCache[p.name] = u) : null);
        _brew.listDependencies(p.name).then((deps) async {
          final outdatedNames = await _brew.listOutdatedNames();
          final count = deps.where((d) => outdatedNames.contains(d)).length;
          if (mounted) setState(() => _depImpact[p.name] = count);
        });
      }
    } finally {
      if (!background) setState(() => _loading = false);
    }
  }

  Future<void> _brewUpdate() async {
    setState(() => _checking = true);
    try {
      await _brew.updateBrewMetadata();
      await _loadOutdated(background: true); // keep list visible
    } finally {
      setState(() => _checking = false);
    }
  }

  Future<void> _upgradeAll() async {
    final targets = _selected.isEmpty ? _items.map((e) => e.name).toList() : _selected.toList();
    if (targets.isEmpty) return;
    setState(() => _updating = true);
    try {
      for (final n in targets) {
        final p = _items.firstWhere((e) => e.name == n);
        await _upgradeOne(p, suppressGuard: true);
      }
      await _loadOutdated(background: true);
    } finally {
      setState(() => _updating = false);
    }
  }

  Future<void> _upgradeOne(OutdatedPackage p, {bool suppressGuard = false}) async {
    // debounce: prevent duplicate taps
    if (_inProgress.contains(p.name) || _checking || _updating) return;

    if (!suppressGuard) {
      // Guard: show confirm if homebrew plans to pull more (detected via deps intersection with outdated set)
      final outdatedNames = await _brew.listOutdatedNames();
      final deps = await _brew.listDependencies(p.name);
      final alsoOutdated = deps.where((d) => outdatedNames.contains(d)).toList();

      if (alsoOutdated.isNotEmpty) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.updatesDialogTitle),
            content: Text(AppLocalizations.of(context)!.updatesDialogContentPrefix(p.name) + alsoOutdated.join(', ')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.actionCancel)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.actionContinue)),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

    setState(() {
      _inProgress.add(p.name);
      _updating = true;
      _upgradingName = p.name;
      _lastLine = '';
      _extraNote = '';
      _pct = null;
      _pctStart = null;
      _etaText = '';
    });
    try {
      final updatedAlso = <String>{};
      await _brew.streamUpgradePackage(p.name, isCask: p.isCask, onLine: (line) {
        final match = RegExp(r'^Upgrading\s+([\w@+\-\.]+)', caseSensitive: false).firstMatch(line);
        if (match != null) {
          final n = match.group(1)!;
          if (n != p.name) updatedAlso.add(n);
        }
        // Parse percentage like ' 21.3%' or ' 80%'
        final pctMatch = RegExp(r'(\d{1,3}(?:\.\d+)?)%').firstMatch(line);
        if (pctMatch != null) {
          final v = double.tryParse(pctMatch.group(1)!);
          if (v != null) {
            final newPct = (v.clamp(0, 100)) / 100.0;
            if (_pctStart == null) _pctStart = DateTime.now();
            _pct = newPct;
            final elapsed = DateTime.now().difference(_pctStart!).inMilliseconds / 1000.0;
            if (newPct > 0.01) {
              final remaining = elapsed * (1 / newPct - 1);
              final mins = remaining ~/ 60;
              final secs = (remaining % 60).round();
              _etaText = '约剩余 ${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
            } else {
              _etaText = '';
            }
          }
        }
        if (line.toLowerCase().contains('pouring') || line.toLowerCase().contains('installing')) {
          _pct = null;
          _etaText = '';
        }
        setState(() => _lastLine = line);
      });
      if (updatedAlso.isNotEmpty) {
        setState(() => _extraNote = '同时升级: ${updatedAlso.join(', ')}');
      }
      await _loadOutdated(background: true);
    } finally {
      setState(() {
        _inProgress.remove(p.name);
        _updating = false;
        _upgradingName = null;
        _lastLine = '';
        _pct = null;
        _etaText = '';
      });
    }
  }

  List<OutdatedPackage> get _filteredSorted {
    var list = _items.where((e) => _keyword.isEmpty || e.name.toLowerCase().contains(_keyword)).toList();
    if (_sort == 'size') {
      list.sort((a, b) => (_sizeCache[b.name]?.length ?? 0).compareTo(_sizeCache[a.name]?.length ?? 0));
    } else {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final content = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FrostCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ActionButton(
                    onPressed: (_updating || _checking) ? null : _brewUpdate, 
                    isPrimary: true,
                    minWidth: 100,
                    child: Text(AppLocalizations.of(context)!.actionCheckUpdates),
                  ),
                  const SizedBox(width: 12),
                  ActionButton(
                    onPressed: (_updating || _checking) ? null : _upgradeAll, 
                    isPrimary: true,
                    minWidth: 120,
                    child: Text(_selected.isEmpty ? AppLocalizations.of(context)!.updatesUpgradeAll : AppLocalizations.of(context)!.updatesUpgradeSelected(_selected.length)),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.updatesSearchHint, prefixIcon: const Icon(Icons.search)),
                      onChanged: (v) => setState(() => _keyword = v.trim().toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _sort,
                    items: [
                      DropdownMenuItem(value: 'name', child: Text(AppLocalizations.of(context)!.updatesSortByName)),
                      DropdownMenuItem(value: 'size', child: Text(AppLocalizations.of(context)!.updatesSortBySize)),
                    ],
                    onChanged: (v) => setState(() => _sort = v ?? 'name'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FrostCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _items.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.updatesAllUpToDate))
                    : ListView.separated(
                        itemCount: _filteredSorted.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final p = _filteredSorted[index];
                          final current = (p.installedVersions.isNotEmpty ? p.installedVersions.first : '—');
                          final upgrading = _upgradingName == p.name;
                          final busy = _inProgress.contains(p.name) || _checking || (_updating && !upgrading);
                          final size = _sizeCache[p.name];
                          final depCount = _depImpact[p.name];
                          final changelog = _changelogCache[p.name];
                          final checked = _selected.contains(p.name);
                          return ListTile(
                            leading: Checkbox(value: checked, onChanged: busy ? null : (v) => setState(() => v == true ? _selected.add(p.name) : _selected.remove(p.name))),
                            title: Row(children: [Expanded(child: Text(p.name)), const SizedBox(width: 8), Text('$current -> ${p.currentVersion}')]),
                            subtitle: upgrading
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_pct == null)
                                        const LinearProgressIndicator(minHeight: 6)
                                      else ...[
                                        LinearProgressIndicator(value: _pct, minHeight: 6),
                                        if (_etaText.isNotEmpty) ...[const SizedBox(height: 4), Text(_etaText, style: const TextStyle(fontSize: 12))]
                                      ],
                                      if (_lastLine.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(_lastLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                      ],
                                      if (_extraNote.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(_extraNote, style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                      ]
                                    ],
                                  )
                                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    if (size != null) Text(AppLocalizations.of(context)!.updatesEstimatedDownload(size)),
                                    if (depCount != null && depCount > 0) Text(AppLocalizations.of(context)!.updatesMayAffectDeps(depCount), style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                    if (changelog != null)
                                      InkWell(onTap: () => launchUrlString(changelog.toString(), mode: LaunchMode.externalApplication), child: Text(AppLocalizations.of(context)!.updatesViewChangelog, style: const TextStyle(color: Color(0xFF5865F2), decoration: TextDecoration.underline))),
                                  ]),
                            trailing: ActionButton(
                        onPressed: busy ? null : () => _upgradeOne(p), 
                        isPrimary: true,
                        minWidth: 80,
                        child: Text(upgrading ? AppLocalizations.of(context)!.updatesUpgrading : AppLocalizations.of(context)!.updatesUpgrade),
                      ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        content,
        if (_checking)
          Positioned.fill(
            child: Container(
              color: Colors.white70,
                child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                      Text(AppLocalizations.of(context)!.updatesChecking)
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
} 