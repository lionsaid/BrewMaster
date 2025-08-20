import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class CleanupView extends StatefulWidget {
  const CleanupView({super.key});
  @override
  State<CleanupView> createState() => _CleanupViewState();
}

class _CleanupViewState extends State<CleanupView> {
  final BrewService _brew = BrewService();
  bool _loading = true;
  String _totalText = '0 B';
  final List<_Group> _groups = [];
  final Map<String, bool> _selected = {}; // key = item id

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final total = await _brew.getCleanupPreviewSize();
      _totalText = total;
      final text = await _brew.getCleanupPreviewText();
      _parsePreview(text);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _parseSizeToBytes(String s) {
    final m = RegExp(r'(\d+(?:\.\d+)?)\s*(B|KB|MB|GB|TB)', caseSensitive: false).firstMatch(s);
    if (m == null) return 0;
    final num v = double.tryParse(m.group(1)!) ?? 0;
    final unit = m.group(2)!.toUpperCase();
    final idx = ['B','KB','MB','GB','TB'].indexOf(unit);
    return v.toDouble() * (idx < 0 ? 1 : (1 << (10 * idx)));
  }

  String _bytesToHuman(double bytes) {
    const units = ['B','KB','MB','GB','TB'];
    int i = 0; double v = bytes;
    while (v >= 1024 && i < units.length - 1) { v /= 1024; i++; }
    return '${v.toStringAsFixed(v < 10 ? 1 : 0)} ${units[i]}';
  }

  void _parsePreview(String text) {
    _groups.clear();
    final cacheItems = <_Item>[];
    final outdated = <_Item>[];
    final unlinked = <_Item>[];

    for (final raw in text.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final sizeMatch = RegExp(r'(\d+(?:\.\d+)?\s*(?:B|KB|MB|GB|TB))', caseSensitive: false).firstMatch(line);
      final size = sizeMatch?.group(1) ?? '';
      final lower = line.toLowerCase();
      // More lenient classification rules
      final isCache = lower.contains('cache') || lower.contains('caches/homebrew') || lower.contains('/downloads/');
      final isUnlinked = lower.contains('unlinked') || lower.contains('pruned');
      final isOutdated = lower.contains('would remove') || lower.contains('/cellar/') || lower.contains('/caskroom/') || lower.contains('old versions') || lower.contains('outdated');

      if (isCache) {
        cacheItems.add(_Item(id: line, name: line, size: size));
      } else if (isUnlinked) {
        unlinked.add(_Item(id: line, name: line, size: size));
      } else if (isOutdated) {
        outdated.add(_Item(id: line, name: line, size: size));
      }
    }

    String _summary(List<_Item> items) {
      if (items.isEmpty) return '0 items';
      final total = items.fold<double>(0, (p, e) => p + _parseSizeToBytes(e.size));
              return '${items.length} items · ${total > 0 ? _bytesToHuman(total) : '—'}';
    }

    _groups.addAll([
              _Group(title: 'Cached downloads', sizeText: _summary(cacheItems), items: cacheItems),
        _Group(title: 'Outdated packages', sizeText: _summary(outdated), items: outdated),
        _Group(title: 'Unlinked old versions', sizeText: _summary(unlinked), items: unlinked),
    ]);

    for (final g in _groups) {
      for (final it in g.items) {
        _selected[it.id] = false;
      }
    }
  }

  int get _selectedCount => _selected.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final t = AppLocalizations.of(context)!;
    final header = FrostCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Text(t.cleanupTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(t.cleanupTotal(_totalText), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
      ),
    );

    final list = Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 80, top: 16),
        itemCount: _groups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final g = _groups[i];
          final allSelected = g.items.isNotEmpty && g.items.every((e) => _selected[e.id] == true);
          return FrostCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                   title: Row(children: [
                    Expanded(child: Text('${g.title} (${g.sizeText})', style: const TextStyle(fontWeight: FontWeight.w700))),
                    Checkbox(
                      value: allSelected,
                      onChanged: (v) => setState(() {
                        for (final it in g.items) {
                          _selected[it.id] = v ?? false;
                        }
                      }),
                    )
                  ]),
                   children: g.items.isEmpty
                       ? [ListTile(title: Text(t.cleanupEmpty))]
                      : g.items.map((it) {
                          return ListTile(
                            leading: Checkbox(
                              value: _selected[it.id] == true,
                              onChanged: (v) => setState(() => _selected[it.id] = v ?? false),
                            ),
                            title: Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Text(it.size.isEmpty ? '—' : it.size),
                          );
                        }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );

    final footer = Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: FrostCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Expanded(child: Text(t.cleanupSelectedCount(_selectedCount))),
            ActionButton(
              onPressed: _selectedCount == 0 ? null : _doCleanup,
              isPrimary: true,
              minWidth: 100,
              child: Text(AppLocalizations.of(context)!.actionCleanNow),
            )
          ]),
        ),
      ),
    );

    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [header, list]),
      ),
      footer,
    ]);
  }

  Future<void> _doCleanup() async {
    final t = AppLocalizations.of(context)!;
    final ids = _selected.entries.where((e) => e.value).map((e) => e.key).toList();
    if (ids.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _brew.cleanupAll();
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.cleanupDone)));
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }
}

class _Group {
  final String title;
  final String sizeText;
  final List<_Item> items;
  _Group({required this.title, required this.sizeText, required this.items});
}

class _Item {
  final String id;
  final String name;
  final String size;
  _Item({required this.id, required this.name, required this.size});
} 