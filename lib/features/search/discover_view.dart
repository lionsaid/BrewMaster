import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:brew_master/core/models/package.dart';
import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:brew_master/l10n/app_localizations.dart';
import 'package:brew_master/core/widgets/package_icon.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  final BrewService _brew = BrewService();
  final TextEditingController _controller = TextEditingController();
  final Map<String, bool> _installing = {}; // key by simple name
  final Map<String, String> _lastLine = {}; // key by simple name

  List<Package> _results = [];
  List<(String name, bool isCask)> _names = [];
  bool _searching = false;
  String _error = '';
  Timer? _debounce;

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _names = [];
        _error = '';
      });
      return;
    }
    setState(() { _searching = true; _error = ''; _results = []; _names = []; });
    try {
      // 先拿名字（快）
      final names = await _brew.searchNames(query, limit: 40);
      if (!mounted) return;
      setState(() => _names = names);
      // 再分批拉 info（懒加载）
      const batch = 10;
      for (var i = 0; i < names.length; i += batch) {
        final slice = names.sublist(i, (i + batch).clamp(0, names.length));
        final infos = await _brew.getPackagesInfo(slice.map((e) => e.$1).toList());
        if (!mounted) return;
        setState(() => _results.addAll(infos));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _install(Package p) async {
    final key = p.name; // use stable simple name as key
    if (_installing[key] == true) return;
    setState(() { _installing[key] = true; _lastLine[key] = ''; });
    final code = await _brew.streamInstallPackage(p.name, isCask: p.isCask, onLine: (l) => setState(() => _lastLine[key] = l));
    if (!mounted) return;
    setState(() { _installing[key] = false; });
    final t = AppLocalizations.of(context)!;
    if (code == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t.actionStart} ${p.name}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${t.actionInstall} ${p.name} failed (code $code)')));
    }
  }

  @override
  void dispose() { _debounce?.cancel(); _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索框（磨砂材质，与卡片统一）
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.only(left: 8,right: 8),
                decoration: BoxDecoration(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.25)
                          : Colors.white.withOpacity(0.45)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(children: [
                  const Icon(Icons.search, size: 22),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                              filled: false,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                            ),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(hintText: t.tabDiscover),
                        onChanged: _onQueryChanged,
                      ),
                    ),
                  ),
                  if (_searching)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  else if (_controller.text.isNotEmpty)
                    IconButton(
                      tooltip: t.actionClearSelection,
                      onPressed: () {
                        _controller.clear();
                        _onQueryChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_searching) const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 8),
          if (_error.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error, style: const TextStyle(color: Colors.red))),
          Expanded(
            child: _buildResults(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    if (_controller.text.trim().isEmpty) {
      return _buildDefaultSuggestions();
    }
    if (_searching && _names.isEmpty && _results.isEmpty) {
      return ListView.separated(
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _SkeletonCard(isDark: isDark),
      );
    }
    final merged = _names.map((e) {
      final exist = _results.firstWhere((p) => p.name == e.$1, orElse: () => Package(
        name: e.$1, fullName: e.$1, description: '', version: '', homepage: '', license: '', installed: false, isCask: e.$2,
      ));
      return exist;
    }).toList();
    if (merged.isEmpty) {
      final t = AppLocalizations.of(context)!;
      return Center(child: Text(t.servicesNoResults));
    }
    return ListView.separated(
      itemCount: merged.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = merged[index];
        final busy = (_installing[p.name] == true) || (_installing[p.fullName] == true);
        return _FrostedResultCard(
          isDark: isDark,
          package: p,
          busy: busy,
          lastLine: _lastLine[p.name] ?? '',
          onInstall: () => _install(p),
          onOpen: () { if (p.homepage.isNotEmpty) launchUrlString(p.homepage, mode: LaunchMode.externalApplication); },
        );
      },
    );
  }

  Widget _buildDefaultSuggestions() {
    final chips = [
      'git', 'node', 'ffmpeg', 'python', 'redis', 'nginx', 'docker', 'iterm2', 'visual-studio-code'
    ];
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.tabDiscover, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((k) => ActionChip(label: Text(k), onPressed: () { _controller.text = k; _search(k); })).toList(),
        ),
      ],
    );
  }
}

class _FrostedResultCard extends StatelessWidget {
  final bool isDark;
  final Package package;
  final bool busy;
  final String lastLine;
  final VoidCallback onInstall;
  final VoidCallback onOpen;
  const _FrostedResultCard({required this.isDark, required this.package, required this.busy, required this.lastLine, required this.onInstall, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final tint = isDark ? Colors.black.withOpacity(0.25) : Colors.white.withOpacity(0.45);
    final border = isDark ? Colors.white24 : Colors.white60;
    final tap = _tapFromFullName(package.fullName);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaviconOrTypeIcon(isCask: package.isCask, homepage: package.homepage.isEmpty ? 'https://example.com' : package.homepage, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(package.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    if (package.homepage.isNotEmpty)
                      TextButton(onPressed: onOpen, child: Text(AppLocalizations.of(context)!.labelHome)),
                  ]),
                  if (package.description.isNotEmpty)...[
                    const SizedBox(height: 4),
                    Text(package.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    _metaChip(package.isCask ? 'Cask' : 'Formulae'),
                    if (package.version.isNotEmpty) _metaChip('v${package.version}'),
                    if (tap != null) _metaChip(tap),
                  ]),
                  if (busy && lastLine.isNotEmpty)...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(minHeight: 4),
                    const SizedBox(height: 4),
                    Text(lastLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  ]
                ]),
              ),
              const SizedBox(width: 12),
              ActionButton(
                onPressed: busy || package.installed ? null : onInstall, 
                isPrimary: true,
                minWidth: 80,
                child: Text(package.installed 
                    ? AppLocalizations.of(context)!.actionInstalled 
                    : (busy 
                        ? AppLocalizations.of(context)!.actionInstalling 
                        : AppLocalizations.of(context)!.actionInstall)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _tapFromFullName(String full) {
    if (full.contains('/')) {
      return full.split('/').first;
    }
    return null;
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final bool isDark;
  const _SkeletonCard({required this.isDark});
  @override
  Widget build(BuildContext context) {
    final tint = isDark ? Colors.black.withOpacity(0.25) : Colors.white.withOpacity(0.45);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 88,
          decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
        ),
      ),
    );
  }
} 