import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class HealthView extends StatefulWidget {
  const HealthView({super.key});

  @override
  State<HealthView> createState() => _HealthViewState();
}

class _HealthViewState extends State<HealthView> {
  final BrewService _brew = BrewService();
  bool _loading = false; // we将用逐项加载动画，整体不再白屏
  final List<_HealthItem> _items = [];
  final List<String> _logs = [];
  final ScrollController _logScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeItems();
    // 延迟执行，确保 context 准备好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareAndRun();
    });
  }

  void _initializeItems() {
    _items.clear();
    _items.addAll([
      _HealthItem(key: 'doctor', title: '', description: '', status: _Status.pending),
      _HealthItem(key: 'repo', title: '', description: '', status: _Status.pending),
      _HealthItem(key: 'path', title: '', description: '', status: _Status.pending),
      _HealthItem(key: 'xcode', title: '', description: '', status: _Status.pending),
      _HealthItem(key: 'missing', title: '', description: '', status: _Status.pending),
    ]);
  }

  Future<void> _prepareAndRun() async {
    setState(() => _loading = true);
    _items.clear();
    _items.addAll([
      _HealthItem(key: 'doctor', title: AppLocalizations.of(context)!.healthDoctorTitle, description: AppLocalizations.of(context)!.healthAnalyzing, status: _Status.pending),
      _HealthItem(key: 'repo', title: AppLocalizations.of(context)!.healthRepoTitle, description: AppLocalizations.of(context)!.healthReadingPrefix, status: _Status.pending),
      _HealthItem(key: 'path', title: AppLocalizations.of(context)!.healthPathTitle, description: AppLocalizations.of(context)!.healthCheckingPath, status: _Status.pending),
      _HealthItem(key: 'xcode', title: AppLocalizations.of(context)!.healthXcodeTitle, description: AppLocalizations.of(context)!.healthCheckingXcode, status: _Status.pending),
      _HealthItem(key: 'missing', title: AppLocalizations.of(context)!.healthMissingTitle, description: AppLocalizations.of(context)!.healthScanningDeps, status: _Status.pending),
    ]);
    _logs
      ..clear()
      ..add('开始系统健康检查…');
    if (mounted) setState(() {});

    await _runStep('doctor', () async {
      _log('执行: brew doctor');
      final raw = await _brew.doctorRaw();
      final warnings = _parseDoctor(raw);
      final anyWarn = warnings.any((e) => e.status != _Status.ok);
      final doctor = _items.firstWhere((e) => e.key == 'doctor');
      doctor.details = raw;
      doctor.description = anyWarn ? AppLocalizations.of(context)!.healthFoundIssues(warnings.length) : AppLocalizations.of(context)!.healthDoctorDescription;
      doctor.status = anyWarn ? _Status.warn : _Status.ok;
      _log(anyWarn ? 'brew doctor 提示 ${warnings.length} 条信息（非致命）' : 'brew doctor 通过');
    });

    await _runStep('repo', () async {
      _log('读取 brew 前缀…');
      final prefix = await _brew.getBrewPrefix();
      final it = _items.firstWhere((e) => e.key == 'repo');
      it.description = 'Prefix: $prefix';
      it.status = _Status.ok;
      _log('前缀: $prefix');
    });

    await _runStep('path', () async {
      final prefix = await _brew.getBrewPrefix();
      _log('检查 PATH 是否包含 $prefix/bin …');
      final ok = await _brew.isPathConfigured();
      final it = _items.firstWhere((e) => e.key == 'path');
      it.description = ok ? 'PATH 中包含 $prefix/bin' : '建议将 $prefix/bin 加入 PATH';
      it.status = ok ? _Status.ok : _Status.warn;
      it.actionLabel = ok ? null : '查看建议';
      it.details = '请将如下路径加入到 PATH 中:\nexport PATH="${prefix}/bin:\$PATH"';
      _log(ok ? 'PATH 检查通过' : 'PATH 需要调整');
    });

    await _runStep('xcode', () async {
      _log('检查 Xcode 命令行工具…');
      final ok = await _brew.isXcodeCLTInstalled();
      final it = _items.firstWhere((e) => e.key == 'xcode');
      it.description = ok ? AppLocalizations.of(context)!.actionInstalled : '未安装，建议安装 xcode-select --install';
      it.status = ok ? _Status.ok : _Status.warn;
      it.actionLabel = ok ? null : '查看建议';
      it.details = '在终端执行：xcode-select --install';
      _log(ok ? 'Xcode CLT ${AppLocalizations.of(context)!.actionInstalled}' : 'Xcode CLT 未安装');
    });

    await _runStep('missing', () async {
      _log('扫描缺失依赖…');
      final list = await _brew.listMissingDependencies();
      final it = _items.firstWhere((e) => e.key == 'missing');
      if (list.isEmpty) {
        it.description = AppLocalizations.of(context)!.healthNoMissingDeps;
        it.status = _Status.ok;
        _log('未发现缺失依赖');
      } else {
        it.description = '存在 ${list.length} 个缺失依赖';
        it.status = _Status.err;
        it.actionLabel = AppLocalizations.of(context)!.actionViewDetails;
        it.details = list.join('\n');
        _log('发现缺失依赖 ${list.length} 个');
      }
    });

    _log(AppLocalizations.of(context)!.healthCheckComplete);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _runStep(String key, Future<void> Function() task) async {
    final it = _items.firstWhere((e) => e.key == key);
    setState(() { it.status = _Status.running; });
    try {
      await task();
    } catch (e) {
      it.status = _Status.err;
      it.description = AppLocalizations.of(context)!.healthCheckFailed(e.toString());
      _log('错误: $e');
    } finally {
      if (mounted) setState(() {});
    }
  }

  void _log(String line) {
    _logs.add(line);
    if (mounted) setState(() {});
    // auto scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScroll.hasClients) {
        _logScroll.animateTo(
          _logScroll.position.maxScrollExtent + 48,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<_HealthItem> _parseDoctor(String text) {
    final lines = text.split('\n');
    final items = <_HealthItem>[];
    String? currentTitle;
    final buff = <String>[];
    _Status status = _Status.ok;

    void flush() {
      if (currentTitle != null) {
        items.add(_HealthItem(
          key: 'doctor-item-${items.length + 1}',
          title: currentTitle!,
          description: buff.join('\n').trim(),
          status: status,
        ));
      }
      currentTitle = null;
      buff.clear();
      status = _Status.ok;
    }

    for (final l in lines) {
      if (l.trim().startsWith('Warning:')) {
        flush();
        currentTitle = l.replaceFirst('Warning:', '').trim();
        status = _Status.warn;
      } else if (RegExp(r'^Error:|^fatal', caseSensitive: false).hasMatch(l)) {
        flush();
        currentTitle = l.replaceFirst(RegExp(r'^Error:\s*'), '').trim();
        status = _Status.err;
      } else {
        buff.add(l);
      }
    }
    flush();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FrostCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Text(AppLocalizations.of(context)!.healthTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const Spacer(),
              ActionButton(
                onPressed: _loading ? null : _prepareAndRun, 
                isPrimary: true,
                minWidth: 80,
                child: Text(AppLocalizations.of(context)!.actionRetest),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(AppLocalizations.of(context)!.healthIntroOk, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FrostCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
              // checklist
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(height: 12, thickness: 0.6, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
                  ),
                  itemBuilder: (_, i) {
                    final it = _items[i];
                    final scheme = Theme.of(context).colorScheme;
                    final baseOverlay = scheme.surface.withOpacity(0.04);
                    final bg = switch (it.status) {
                      _Status.ok => baseOverlay,
                      _Status.warn => Colors.orange.withOpacity(0.08),
                      _Status.err => Colors.red.withOpacity(0.08),
                      _Status.running => baseOverlay,
                      _Status.pending => Colors.transparent,
                    };
                    final trailing = it.actionLabel == null
                        ? null
                        : (it.status == _Status.err
                            ? ActionButton(
                                onPressed: () => _showDetails(it), 
                                isPrimary: true,
                                minWidth: 80,
                                child: Text(it.actionLabel!),
                              )
                            : ActionButton(
                                onPressed: () => _showDetails(it), 
                                minWidth: 80,
                                child: Text(it.actionLabel!),
                              ));
                    final subtitleStyle = TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                    );
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        leading: _statusIcon(it.status),
                        title: Text(it.title),
                        subtitle: it.description.isEmpty ? null : Text(it.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: subtitleStyle),
                        trailing: trailing,
                      ),
                    );
                  },
                ),
              ),
              // live logs
              Container(
                height: 140,
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
                ),
                child: Scrollbar(
                  controller: _logScroll,
                  child: ListView.builder(
                    controller: _logScroll,
                    itemCount: _logs.length,
                    itemBuilder: (_, i) => Text(
                      _logs[i],
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              )
            ]),
          ),
        ))
      ]),
    );
  }

  void _showDetails(_HealthItem it) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(it.title),
        content: SingleChildScrollView(child: Text((it.details?.isNotEmpty == true ? it.details : it.description) ?? '')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.actionClose))],
      ),
    );
  }

  Widget _statusIcon(_Status s) {
    switch (s) {
      case _Status.ok:
        return const Icon(Icons.check_circle, color: Colors.green);
      case _Status.warn:
        return const Icon(Icons.warning_amber_rounded, color: Colors.orange);
      case _Status.err:
        return const Icon(Icons.cancel, color: Colors.redAccent);
      case _Status.running:
        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
      case _Status.pending:
        return const Icon(Icons.radio_button_unchecked, color: Colors.grey);
    }
  }
}

enum _Status { pending, running, ok, warn, err }

class _HealthItem {
  final String key;
  final String title;
  String description;
  _Status status;
  String? actionLabel;
  String? details;
  _HealthItem({required this.key, required this.title, required this.description, required this.status, this.actionLabel, this.details});
} 