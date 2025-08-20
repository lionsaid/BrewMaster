import 'package:brew_master/core/models/package.dart';
import 'package:brew_master/core/services/brew_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brew_master/core/models/package_dependencies.dart';
import 'package:brew_master/features/packages/widgets/dependency_graph_view.dart';
import 'package:brew_master/core/widgets/package_icon.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class PackageDetailView extends StatefulWidget {
  final Package package;
  final VoidCallback onUninstall;
  final VoidCallback? onReinstall;
  final VoidCallback? onPinToggle;
  final VoidCallback? onOpenHomepage;

  const PackageDetailView({super.key, required this.package, required this.onUninstall, this.onReinstall, this.onPinToggle, this.onOpenHomepage});

  @override
  State<PackageDetailView> createState() => _PackageDetailViewState();
}

class _PackageDetailViewState extends State<PackageDetailView> with TickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this)..addListener(_onTabChanged);
  final BrewService _brew = BrewService();
  Future<PackageDependencies>? _dependenciesFuture;

  bool _loadingFiles = false;
  List<String>? _files;
  String? _filesError;

  List<String>? _versionedAlternatives;
  bool _loadingAlternatives = false;
  String _installLog = '';
  bool _installing = false;

  @override
  void initState() {
    super.initState();
    if (!widget.package.isCask) {
      Future.microtask(_loadAlternatives);
    }
    _loadDependencies();
  }

  @override
  void didUpdateWidget(covariant PackageDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.package.name != widget.package.name || oldWidget.package.isCask != widget.package.isCask) {
      _loadingFiles = false;
      _files = null;
      _filesError = null;
      _versionedAlternatives = null;
      _loadingAlternatives = false;
      _installLog = '';
      _installing = false;
      _tabController.index = 0;
      if (!widget.package.isCask) {
        Future.microtask(_loadAlternatives);
      }
      // 关键：包变化时重新加载依赖
      _dependenciesFuture = null;
      _loadDependencies();
      setState(() {});
    }
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_loadingFiles && _files == null) {
      _loadFiles();
    }
    if (_tabController.index == 2 && _versionedAlternatives == null && !_loadingAlternatives && !widget.package.isCask) {
      _loadAlternatives();
    }
    // 进入依赖关系页（索引3）时，若未加载则加载
    if (_tabController.index == 3 && _dependenciesFuture == null) {
      _loadDependencies();
    }
  }

  Future<void> _loadFiles() async {
    setState(() { _loadingFiles = true; _filesError = null; });
    try {
      final list = await _brew.listFiles(widget.package.name, isCask: widget.package.isCask);
      setState(() => _files = list);
    } catch (e) {
      setState(() => _filesError = e.toString());
    } finally { setState(() => _loadingFiles = false); }
  }

  Future<void> _loadAlternatives() async {
    setState(() => _loadingAlternatives = true);
    try {
      final list = await _brew.getVersionedAlternatives(widget.package.name);
      setState(() => _versionedAlternatives = list);
    } finally {
      setState(() => _loadingAlternatives = false);
    }
  }

  Future<void> _installVersioned(String name) async {
    setState(() { _installing = true; _installLog = ''; });
    try {
      await _brew.streamInstallPackage(name, onLine: (l) => setState(() => _installLog = l));
    } finally {
      setState(() => _installing = false);
    }
  }

  Future<void> _extractAndInstallVersion(String version) async {
    if (version.isEmpty) return;
    setState(() { _installing = true; _installLog = ''; });
    try {
      await _brew.extractAndInstallSpecificVersion(widget.package.name, version, onLine: (l) => setState(() => _installLog = l));
    } finally {
      setState(() => _installing = false);
    }
  }

  Future<void> _loadDependencies() async {
    setState(() {
      _dependenciesFuture = Future.wait([
        _brew.getDependencies(widget.package.name),
        _brew.getDependents(widget.package.name),
      ]).then((results) {
        return PackageDependencies(
          packageName: widget.package.name,
          dependencies: results[0],
          dependents: results[1],
        );
      });
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.package;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaviconOrTypeIcon(isCask: widget.package.isCask, homepage: widget.package.homepage, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.fullName, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  Text('v${p.version}', style: textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (p.homepage.isNotEmpty)
                  ActionButton(
                    onPressed: widget.onOpenHomepage, 
                    minWidth: 90,
                    child: Text(AppLocalizations.of(context)!.actionOpenHomepage),
                  ),
                ActionButton(
                  onPressed: widget.onReinstall, 
                  minWidth: 90,
                  child: Text(AppLocalizations.of(context)!.actionReinstall),
                ),
                ActionIconButton(
                  onPressed: widget.onUninstall, 
                  icon: const Icon(Icons.delete_outline), 
                  label: Text(AppLocalizations.of(context)!.actionUninstall), 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  minWidth: 90,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TabBar(controller: _tabController, labelColor: Theme.of(context).colorScheme.primary, tabs: [
          Tab(text: AppLocalizations.of(context)!.actionInfo),
          Tab(text: AppLocalizations.of(context)!.actionFiles),
          Tab(text: AppLocalizations.of(context)!.actionOptions),
          Tab(text: AppLocalizations.of(context)!.actionDependencies),
        ]),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(p, textTheme),
              _buildFilesTab(),
              _buildOptionsTab(),
              _buildDependenciesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab(Package p, TextTheme textTheme) {
    return ListView(children: [
      if (p.description.isNotEmpty) ...[Text(p.description), const SizedBox(height: 12)],
      if (p.homepage.isNotEmpty) ...[Text('${AppLocalizations.of(context)!.actionHomepage} ${p.homepage}', style: textTheme.bodySmall), const SizedBox(height: 8)],
      Text('${AppLocalizations.of(context)!.actionLicense} ${p.license}')
    ]);
  }

  Widget _buildFilesTab() {
    if (_loadingFiles) return const Center(child: CircularProgressIndicator());
    if (_filesError != null) return Center(child: Text('${AppLocalizations.of(context)!.actionLoadFailed} $_filesError'));
    final files = _files;
    if (files == null) {
      return Center(child: TextButton(onPressed: _loadFiles, child: Text(AppLocalizations.of(context)!.actionLoadFiles)));
    }
    if (files.isEmpty) return Center(child: Text(AppLocalizations.of(context)!.actionNoFilesFound));
    return ListView.separated(
      itemCount: files.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) => ListTile(
        title: Text(files[i]),
        trailing: IconButton(icon: const Icon(Icons.copy), tooltip: AppLocalizations.of(context)!.actionCopyPath, onPressed: () => Clipboard.setData(ClipboardData(text: files[i]))),
      ),
    );
  }

  Widget _buildOptionsTab() {
    if (widget.package.isCask) {
      return Center(child: Text(AppLocalizations.of(context)!.actionCaskNotSupported));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(AppLocalizations.of(context)!.actionHistoricalVersions, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          if (_loadingAlternatives) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
        ]),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              if (_versionedAlternatives == null) ...[
                TextButton(onPressed: _loadAlternatives, child: Text(AppLocalizations.of(context)!.actionLoadAlternatives)),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context)!.actionExtractInstallHint, style: const TextStyle(color: Colors.grey)),
              ] else if (_versionedAlternatives!.isEmpty) ...[
                Text(AppLocalizations.of(context)!.actionNoVersionedFormulae, style: const TextStyle(color: Colors.grey)),
              ] else ...[
                ..._versionedAlternatives!.map((vName) => ListTile(
                      title: Text(vName),
                      trailing: ActionButton(
                        onPressed: _installing ? null : () => _installVersioned(vName), 
                        isPrimary: true,
                        minWidth: 100,
                        child: Text(AppLocalizations.of(context)!.actionInstallThisVersion),
                      ),
                    )),
              ],
              const Divider(),
              _buildExtractSection(),
              if (_installing || _installLog.isNotEmpty) ...[
                const Divider(),
                Text(_installing ? AppLocalizations.of(context)!.actionInstallInProgress : AppLocalizations.of(context)!.actionLastOutput),
                Text(_installLog, maxLines: 2, overflow: TextOverflow.ellipsis),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExtractSection() {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.titleManualExtractInstall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: '例如 2.41 或 2.41.0'))),
              const SizedBox(width: 8),
              ActionButton(
                onPressed: _installing ? null : () => _extractAndInstallVersion(controller.text.trim()), 
                isPrimary: true,
                minWidth: 100,
                child: Text(AppLocalizations.of(context)!.actionExtractInstall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.textExtractPrinciple, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDependenciesTab() {
    return FutureBuilder<PackageDependencies>(
      future: _dependenciesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${AppLocalizations.of(context)!.actionLoadFailed} ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final deps = snapshot.data!;
          return DependencyGraphView(dependencies: deps);
        } else {
          return Center(child: Text(AppLocalizations.of(context)!.actionNoFilesFound));
        }
      },
    );
  }
} 