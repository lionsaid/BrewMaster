import 'package:brew_master/core/models/service_item.dart';
import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:brew_master/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  final BrewService _brew = BrewService();
  bool _loading = true;
  late _ServicesDataSource _dataSource;
  final Set<String> _busy = <String>{};
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _brew.listServices();
      if (!mounted) return;
      _dataSource = _ServicesDataSource(
        context: context,
        services: list,
        busy: _busy,
        onStart: (n) => _operate(n, () => _brew.startService(n)),
        onStop: (n) => _operate(n, () => _brew.stopService(n)),
        onRestart: (n) => _operate(n, () => _brew.restartService(n)),
      );
      setState(() {});
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _operate(String name, Future<void> Function() action) async {
    if (_busy.contains(name)) return;
    setState(() => _busy.add(name));
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.servicesProcessing} $name')));
      await _load();
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${AppLocalizations.of(context)!.actionLoadFailed}'),
          content: SizedBox(width: 560, child: Text(e.toString())),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.actionClose))],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(name));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _dataSource.services.where((s) => _keyword.isEmpty || s.name.toLowerCase().contains(_keyword)).toList();
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.splitscreen, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.servicesNoResults, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            ActionButton(
              onPressed: _load, 
              isPrimary: true,
              minWidth: 80,
              child: Text(AppLocalizations.of(context)!.actionRefresh),
            ),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: AppLocalizations.of(context)!.servicesSearchHint), onChanged: (v) => setState(() => _keyword = v.trim().toLowerCase()))),
            const SizedBox(width: 12),
            ActionButton(
              onPressed: _load, 
              isPrimary: true,
              minWidth: 80,
              child: Text(AppLocalizations.of(context)!.actionRefresh),
            ),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child:  LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final cross = width < 700 ? 1 : width < 1100 ? 2 : 3;
                  final cardWidth = (width - (cross - 1) * 16) / cross;
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: filtered.map((s) {
                        final busy = _busy.contains(s.name);
                        final canStart = s.status != ServiceStatus.started && !busy;
                        final canStop = s.status == ServiceStatus.started && !busy;
                        final canRestart = s.status == ServiceStatus.started && !busy;
                        return SizedBox(
                          width: cardWidth,
                          child: FrostCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _statusChip(s.status, busy: busy, context: context),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    const Icon(Icons.person, size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(s.user ?? '—'),
                                  ]),
                                  const SizedBox(height: 6),
                                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    const Icon(Icons.description_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(s.filePath ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis)),
                                    if ((s.filePath ?? '').isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      IconButton(tooltip: AppLocalizations.of(context)!.actionCopyPath, icon: const Icon(Icons.copy, size: 18), onPressed: () => Clipboard.setData(ClipboardData(text: s.filePath!))),
                                    ]
                                  ]),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    ActionButton(
                                      onPressed: canStart ? () => _operate(s.name, () => _brew.startService(s.name)) : null,
                                      isPrimary: true,
                                      minWidth: 70,
                                      child: busy && s.status != ServiceStatus.started 
                                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                          : Text(AppLocalizations.of(context)!.actionStart),
                                    ),
                                    const SizedBox(width: 8),
                                    ActionButton(
                                      onPressed: canStop ? () => _operate(s.name, () => _brew.stopService(s.name)) : null,
                                      minWidth: 70,
                                      child: busy && s.status == ServiceStatus.started 
                                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) 
                                          : Text(AppLocalizations.of(context)!.actionStop),
                                    ),
                                    const SizedBox(width: 8),
                                    ActionButton(
                                      onPressed: canRestart ? () => _operate(s.name, () => _brew.restartService(s.name)) : null,
                                      minWidth: 70,
                                      child: busy && s.status == ServiceStatus.started 
                                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) 
                                          : Text(AppLocalizations.of(context)!.actionRestart),
                                    ),
                                  ]),
                                  const SizedBox(height: 8),
                                  // Expandable details
                                  _ServiceDetails(name: s.name, brew: _brew),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ActionIconButton(
                                      onPressed: () => _brew.openLogsDirectory(s.name), 
                                      icon: const Icon(Icons.folder_open), 
                                      label: Text(AppLocalizations.of(context)!.actionViewLogsDir),
                                      minWidth: 120,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ServicesDataSource {
  final BuildContext context;
  final List<ServiceItem> services;
  final Set<String> busy;
  final void Function(String name) onStart;
  final void Function(String name) onStop;
  final void Function(String name) onRestart;

  _ServicesDataSource({
    required this.context,
    required this.services,
    required this.busy,
    required this.onStart,
    required this.onStop,
    required this.onRestart,
  });
}

IconData _serviceIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('postgres')) return Icons.storage_rounded;
  if (n.contains('redis')) return Icons.memory_rounded;
  if (n.contains('mysql')) return Icons.table_chart_rounded;
  if (n.contains('nginx')) return Icons.public_rounded;
  if (n.contains('httpd') || n.contains('apache')) return Icons.web_rounded;
  return Icons.settings_rounded;
}

Widget _statusChip(ServiceStatus status, {bool busy = false, required BuildContext context}) {
  if (busy) {
    return Row(children: [
      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), 
      const SizedBox(width: 6), 
      Text(AppLocalizations.of(context)!.servicesProcessing)
    ]);
  }
  Color fg;
  Color bg;
  String label;
  switch (status) {
    case ServiceStatus.started:
      fg = const Color(0xFF166534);
      bg = const Color(0xFFDCFCE7);
      label = 'started';
      break;
    case ServiceStatus.stopped:
      fg = const Color(0xFF991B1B);
      bg = const Color(0xFFFEE2E2);
      label = 'stopped';
      break;
    case ServiceStatus.error:
      fg = const Color(0xFFB91C1C);
      bg = const Color(0xFFFCA5A5);
      label = 'error';
      break;
    case ServiceStatus.unknown:
      fg = const Color(0xFF92400E);
      bg = const Color(0xFFFDE68A);
      label = 'unknown';
      break;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800)),
  );
}

class _ServiceDetails extends StatefulWidget {
  final String name;
  final BrewService brew;
  const _ServiceDetails({required this.name, required this.brew});
  @override
  State<_ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<_ServiceDetails> {
  bool _open = false;
  List<int>? _ports;
  (double cpu, double mem)? _res;
  bool _loading = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ports = await widget.brew.listServiceListeningPorts(widget.name);
      final res = await widget.brew.getProcessCpuMem(widget.name);
      if (!mounted) return;
      setState(() { _ports = ports; _res = res; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: _open,
      onExpansionChanged: (v) { setState(() => _open = v); if (v && _ports == null && !_loading) _load(); },
              title: Text(AppLocalizations.of(context)!.actionViewDetails, style: const TextStyle(fontWeight: FontWeight.w700)),
      childrenPadding: EdgeInsets.zero,
      children: [
        if (_loading) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator(minHeight: 2)) else
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(AppLocalizations.of(context)!.labelPorts),
                if (_ports == null) Text(AppLocalizations.of(context)!.labelHome.replaceAll('Home', AppLocalizations.of(context)!.commonNone)) else Expanded(child: Text(_ports!.isEmpty ? AppLocalizations.of(context)!.commonNone : _ports!.join(', '))),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Text(AppLocalizations.of(context)!.labelResources),
                Expanded(child: Text(_res == null ? AppLocalizations.of(context)!.commonNone : 'CPU ${_res!.$1.toStringAsFixed(1)}% · MEM ${_res!.$2.toStringAsFixed(1)}%')),
              ]),
            ]),
          )
      ],
    );
  }
} 