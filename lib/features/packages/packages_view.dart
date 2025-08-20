import 'package:brew_master/core/models/package.dart';
import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/features/packages/package_detail_view.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:brew_master/features/packages/widgets/package_list_item.dart'; // Import PackageListItem
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key, this.initialFilter});
  final String? initialFilter; // 'all' | 'formulae' | 'casks'

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  final BrewService _brewService = BrewService();
  List<Package> _packages = [];
  Package? _selectedPackage;
  bool _isLoading = true;

  String _query = '';
  String _filter = 'all'; // all | formulae | casks

  final Set<String> _selectedNames = <String>{};
  DateTime? _lastRefreshedAt;

  int _bgEpoch = 0; // Used to cancel old background batches

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _filter = widget.initialFilter!;
    }
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    try {
      final currentEpoch = DateTime.now().microsecondsSinceEpoch;
      // Record epoch to cancel old background batches
      _bgEpoch = currentEpoch;
              // 1) Quickly get installed name->version
      final formulae = await _brewService.listInstalledVersions(isCask: false);
      final casks = await _brewService.listInstalledVersions(isCask: true);
      final outdatedNames = await _brewService.listOutdatedNames();

              // First quickly render basic information
      final initial = <Package>[];
      for (final e in formulae.entries) {
        initial.add(Package(
          name: e.key,
          fullName: e.key,
          description: '',
          version: e.value.replaceFirst(RegExp('^v'), ''),
          homepage: '',
          license: '',
          installed: true,
          isCask: false,
          isOutdated: outdatedNames.contains(e.key),
        ));
      }
      for (final e in casks.entries) {
        initial.add(Package(
          name: e.key,
          fullName: e.key,
          description: '',
          version: e.value.replaceFirst(RegExp('^v'), ''),
          homepage: '',
          license: '',
          installed: true,
          isCask: true,
          isOutdated: outdatedNames.contains(e.key),
        ));
      }
      initial.sort((a,b)=>a.name.compareTo(b.name));
      setState(() { _packages = initial; _isLoading = false; _lastRefreshedAt = DateTime.now(); });

              // 2) Background complete details (batch, avoid lag)
      final allNames = initial.map((e)=>e.name).toList();
      const batchSize = 15;
      for (var i = 0; i < allNames.length; i += batchSize) {
        final slice = allNames.sublist(i, i + batchSize > allNames.length ? allNames.length : i + batchSize);
        try {
          final infos = await _brewService.getPackagesInfoBatch(slice);
          if (!mounted) return;
          setState(() {
            for (final p in infos) {
              final idx = _packages.indexWhere((e) => e.name == p.name);
              if (idx >= 0) {
                _packages[idx] = Package(
                  name: p.name,
                  fullName: p.fullName,
                  description: p.description,
                  version: p.version,
                  homepage: p.homepage,
                  license: p.license,
                  installed: p.installed,
                  isCask: p.isCask,
                  isOutdated: outdatedNames.contains(p.name),
                );
              }
            }
          });
        } catch (_) { /* Ignore single batch failure, continue */ }
      }
    } on BrewCommandException catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uninstallPackage(Package package) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.actionUninstallConfirm(package.name)),
        content: Text(t.textIrreversible),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.actionCancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t.actionUninstall)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _brewService.uninstallPackage(package.name, isCask: package.isCask);
      await _loadPackages();
      setState(() => _selectedPackage = null);
    } on BrewCommandException catch (e) {
      // ignore: avoid_print
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bulkUninstall() async {
    if (_selectedNames.isEmpty) return;
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.actionBulkUninstallConfirm(_selectedNames.length)),
        content: Text(t.textIrreversible),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.actionCancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t.actionUninstall)),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      // Execute uninstall (serial)
      for (final name in _selectedNames) {
        final p = _packages.firstWhere((e) => e.name == name);
        await _brewService.uninstallPackage(p.name, isCask: p.isCask);
      }
      _selectedNames.clear();
      await _loadPackages();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Package> get _filtered {
    final lower = _query.toLowerCase();
    return _packages.where((p) {
      final matchQuery = lower.isEmpty || p.name.toLowerCase().contains(lower) || p.description.toLowerCase().contains(lower);
      final matchFilter = _filter == 'all' || (_filter == 'formulae' && !p.isCask) || (_filter == 'casks' && p.isCask);
      return matchQuery && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final total = _packages.length;
    final last = _lastRefreshedAt == null ? '-' : '${_lastRefreshedAt!.hour.toString().padLeft(2, '0')}:${_lastRefreshedAt!.minute.toString().padLeft(2, '0')}';

    final listPane = FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add Padding
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: t.searchInstalledHint, prefixIcon: const Icon(Icons.search)),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 12),
                // Replace CupertinoSegmentedControl with ToggleButtons for custom styling
                ToggleButtons(
                  isSelected: [
                    _filter == 'all',
                    _filter == 'formulae',
                    _filter == 'casks',
                  ],
                  onPressed: (int index) {
                    setState(() {
                      if (index == 0) _filter = 'all';
                      if (index == 1) _filter = 'formulae';
                      if (index == 2) _filter = 'casks';
                    });
                  },
                  borderRadius: BorderRadius.circular(8.0), // Match TextField's border radius
                  borderColor: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  selectedBorderColor: Theme.of(context).colorScheme.primary,
                  fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  color: Theme.of(context).colorScheme.onSurface,
                  constraints: const BoxConstraints(minHeight: 48.0), // Adjust height to match TextField
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(t.filterAll)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(t.filterFormulae)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(t.filterCasks)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedNames.isNotEmpty)
              Row(
                children: [
                  Text(t.packagesSelectedCount(_selectedNames.length)),
                  const SizedBox(width: 8),
                  ActionButton(
                    onPressed: _bulkUninstall, 
                    isPrimary: true,
                    minWidth: 100,
                    child: Text(t.actionBulkUninstall),
                  ),
                  const Spacer(),
                  TextButton(onPressed: () => setState(() => _selectedNames.clear()), child: Text(t.actionClearSelection)),
                ],
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final package = _filtered[index];
                  final selected = _selectedPackage?.name == package.name;
                  final checked = _selectedNames.contains(package.name);
                  return PackageListItem(
                    package: package,
                    selected: checked,
                    onToggleSelected: () {
                      setState(() {
                        // If current selected item is different from clicked item, update selected item and clear batch selection
                        if (_selectedPackage?.name != package.name) {
                          _selectedPackage = package;
                                                      _selectedNames.clear(); // Clear batch selection to avoid confusion
                        } else {
                                                      _selectedPackage = null; // Click again to deselect
                        }
                                                  // Batch selection logic, mutually exclusive with single selection
                        if (checked) {
                          _selectedNames.remove(package.name);
                        } else {
                          _selectedNames.add(package.name);
                        }
                      });
                    },
                    onUninstall: () => _uninstallPackage(package),
                    onReinstall: () async {
                      await _brewService.reinstallPackage(package.name, isCask: package.isCask);
                      await _loadPackages();
                    },
                    onOpenHomepage: () => _launchUrl(package.homepage),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    final detailPane = FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _selectedPackage == null
            ? Center(child: Text(t.selectPackagePlaceholder))
            : PackageDetailView(
              package: _selectedPackage!,
              onUninstall: () => _uninstallPackage(_selectedPackage!),
              onReinstall: () async {
                await _brewService.reinstallPackage(_selectedPackage!.name, isCask: _selectedPackage!.isCask);
                await _loadPackages();
              },
              onPinToggle: () async {
                try { await _brewService.pinPackage(_selectedPackage!.name); } catch (_) { await _brewService.unpinPackage(_selectedPackage!.name); }
              },
              onOpenHomepage: () => _launchUrl(_selectedPackage!.homepage),
            ),
    ));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column( // Use Column as the main layout to manage children
        children: [
          Row( // Header row
            children: [
              Text(t.installedTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              ActionButton(
                onPressed: _loadPackages, 
                isPrimary: true,
                minWidth: 80,
                child: Text(t.actionRefresh),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded( // The main content area should expand
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 980;
                if (narrow) {
                  return Column( // Stack panes vertically
                    children: [
                      Expanded(child: listPane),
                      const SizedBox(height: 16),
                      Expanded(child: detailPane),
                    ],
                  );
                } else {
                  // Adaptive detail panel width: occupies ~56% of available width, limited between 560-900
                  final target = constraints.maxWidth * 0.56;
                  final detailWidth = target.clamp(560.0, 900.0) as double;
                  return Row( // Place panes side-by-side
                    crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                    children: [
                      Expanded(child: listPane), // List pane expands
                      if (_selectedPackage != null) ...[
                        const SizedBox(width: 16),
                        SizedBox(width: detailWidth, child: detailPane), // Wider, responsive detail pane
                      ],
                    ],
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          // Bottom status bar
          Row(
            children: [
              Text(t.statusTotalPackages(total)),
              const SizedBox(width: 12),
              Text(t.statusLastRefresh(last)),
              const Spacer(),
              if (_selectedNames.isNotEmpty) Text(t.packagesSelectedCount(_selectedNames.length))
            ],
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    if (url.isEmpty) return;
    final ok = await launchUrlString(url, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.messageOpenHomepageFailed)));
    }
  }
} 