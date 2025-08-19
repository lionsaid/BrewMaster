import 'dart:io';

import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:brew_master/features/home/home_view.dart';
import 'package:brew_master/features/services/services_view.dart';
import 'package:brew_master/features/taps/taps_view.dart';
import 'package:flutter/material.dart';
import 'widgets/metric_card.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, this.onOpenHealth});
  final VoidCallback? onOpenHealth;

  @override
  State<DashboardView> createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> {
  final BrewService _brew = BrewService();

  bool _checking = false;
  bool _cleaning = false;
  bool _showingCleanupPreview = false;

  int? _formulae;
  int? _casks;
  int? _taps;
  int? _outdated;
  bool? _doctorOk;
  int? _doctorIssues;
  String? _cleanupSize;
  int? _svcRunning;
  int? _svcStopped;

  void reload() { _load(); }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    // 并发拉取，各自就绪各自刷新
    _brew.countInstalledFormulae().then((v){ if(mounted) setState(()=>_formulae=v); });
    _brew.countInstalledCasks().then((v){ if(mounted) setState(()=>_casks=v); });
    _brew.countTaps().then((v){ if(mounted) setState(()=>_taps=v); });
    _brew.countOutdated().then((v){ if(mounted) setState(()=>_outdated=v); });
    _brew.isDoctorHealthy().then((v){ if(mounted) setState(()=>_doctorOk=v); });
    _brew.doctorIssuesCount().then((v){ if(mounted) setState(()=>_doctorIssues=v); });
    _brew.getCleanupPreviewSize().then((v){ if(mounted) setState(()=>_cleanupSize=v); });
    _brew.getServicesSummary().then((pair){ if(mounted) setState((){ _svcRunning=pair.$1; _svcStopped=pair.$2; }); });
  }

  Future<void> _checkUpdates() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      await _brew.updateBrewMetadata();
      await _load();
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  String get _username => Platform.environment['USER'] ?? '朋友';

  void _goInstalled(BuildContext context, {String filter = 'all'}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeView(initialIndex: 1, packagesInitialFilter: filter)));
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.blueGrey);
    final t = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(children: [
              Text('BrewMaster', style: title),
              const Spacer(),
              Text('你好，$_username！', style: title),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ActionButton(
                    onPressed: _checking ? null : _checkUpdates,
                    isPrimary: true,
                    minWidth: 100,
                    child: _checking
                        ? Row(children: [const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.updatesChecking)])
                        : Text(t.actionCheckUpdates),
                  ),
                ),
              ),
            ]),
          ),
        ),
        // Metrics row
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 100,
            ),
            delegate: SliverChildListDelegate([
              InkWell(onTap: () => _goInstalled(context, filter: 'formulae'), child: MetricCard(icon: Icons.science_outlined, label: 'Formulae', value: _formulae?.toString() ?? '…')),
              InkWell(onTap: () => _goInstalled(context, filter: 'casks'), child: MetricCard(icon: Icons.apps_outlined, label: 'Casks', value: _casks?.toString() ?? '…')),
              InkWell(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TapsView())), child: MetricCard(icon: Icons.merge_type_outlined, label: 'Taps', value: _taps?.toString() ?? '…')),
            ]),
          ),
        ),
        // Main cards 2x3 (consistent height)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 180,
            ),
            delegate: SliverChildListDelegate([
              // Updates card
              FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(_outdated == null ? t.dashboardFetching : (_outdated! > 0 ? t.dashboardFoundUpdatesN(_outdated!) : t.dashboardNoUpdates), style: title?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(_outdated == null ? t.dashboardPleaseWait : (_outdated! > 0 ? t.dashboardTapForDetails : '')),
                    ])),
                    const SizedBox(width: 12),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ActionButton(
                          onPressed: (_outdated ?? 0) > 0 ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeView(initialIndex: 4))) : null,
                          isPrimary: true,
                          minWidth: 100,
                          child: Text(t.actionViewUpdates),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              // Doctor card
              FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(children: [
                    Icon((_doctorOk ?? true) && (_doctorIssues ?? 0) == 0 ? Icons.check_circle : Icons.warning_amber_rounded, color: (_doctorOk ?? true) && (_doctorIssues ?? 0) == 0 ? Colors.green : Colors.orange, size: 28),
                    const SizedBox(width: 12),
                     Expanded(child: Text(_doctorOk == null ? AppLocalizations.of(context)!.updatesChecking : ((_doctorOk! && (_doctorIssues ?? 0) == 0) ? t.dashboardHealthOk : t.dashboardFoundIssuesN(_doctorIssues ?? 0)))),
                    ActionButton(
                      onPressed: widget.onOpenHealth,
                      minWidth: 100,
                      child: Text((_doctorIssues ?? 0) > 0 ? '查看并修复' : t.actionViewUpdates),
                    )
                  ]),
                ),
              ),
              // Cleanup card
              FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(t.dashboardCleanupTitle, style: title?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(_cleanupSize == null ? t.dashboardCalculating : (_cleanupSize == '0 B' ? t.dashboardNoCleanupNeeded : t.dashboardCanFreeSize(_cleanupSize!))),
                    ])),
                    const SizedBox(width: 12),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ActionButton(
                          onPressed: (_cleanupSize != null && _cleanupSize != '0 B') ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeView(initialIndex: 7))) : null,
                          isPrimary: true,
                          minWidth: 100,
                          child: Text(t.actionCleanNow),
                        ),
                      ),
                    ),                  ]),
                ),
              ),
              // Services card
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServicesView())),
                child: FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(t.dashboardServicesTitle, style: title),
                          const SizedBox(height: 2),
                          Row(children: [
                            Expanded(
                              child: Text(
                                '✅ ${t.dashboardRunning} ${_svcRunning?.toString() ?? '…'}',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '⏹️ ${t.dashboardStopped} ${_svcStopped?.toString() ?? '…'}',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                        ]),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                                                  child: ActionButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeView(initialIndex: 5))),
                          isPrimary: true,
                          minWidth: 100,
                          child: Text(t.actionManageServices),
                        ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
            ]),
          ),
        ),
      ],
    );
  }
} 