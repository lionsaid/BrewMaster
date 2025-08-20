import 'dart:ui' show ImageFilter;
import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/features/home/home_view.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final BrewService _brewService = BrewService();
  bool? _installed;
  String _diagnostic = '';
  final TextEditingController _customPathCtrl = TextEditingController();
  List<(String path,int exit,String out)> _probes = const [];
  bool _probing = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _probe() async {
    setState(() { _probing = true; });
    final res = await _brewService.probeBrewCandidates();
    if (!mounted) return;
    setState(() { _probes = res; _probing = false; });
  }

  Future<void> _saveCustomPath() async {
    final v = _customPathCtrl.text.trim();
    await _brewService.setPreferredBrewPath(v.isEmpty ? null : v);
    await _check();
  }

  Future<void> _check() async {
    setState(() { _diagnostic = '正在检测 Homebrew…'; });
    await _probe();
    final ok = await _brewService.isBrewInstalled();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } else {
      setState(() {
        _installed = false;
        _diagnostic = '未检测到可执行的 brew，请确认 /opt/homebrew/bin/brew 或 /usr/local/bin/brew 可用，或手动指定路径后重试。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_installed == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tint = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withOpacity(0.28)
        : Colors.white.withOpacity(0.38);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 980),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.splashWelcome, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.splashNoBrew, style: Theme.of(context).textTheme.bodyMedium),
                      if (_diagnostic.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(_diagnostic, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
                      ],
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _customPathCtrl,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.hintBrewPath,
                              prefixIcon: const Icon(Icons.link),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ActionButton(
                        onPressed: _saveCustomPath, 
                        isPrimary: true,
                        minWidth: 100,
                        child: Text(AppLocalizations.of(context)!.actionSaveAndCheck),
                      ),
                      ]),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
                          ),
                          child: _probing
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _probes.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (_, i) {
                                    final (path, exit, out) = _probes[i];
                                    final ok = exit == 0;
                                    return ListTile(
                                      dense: true,
                                      leading: Icon(ok ? Icons.check_circle : Icons.error_outline, color: ok ? Colors.green : Colors.orange),
                                      title: Text(path.isEmpty ? '(空路径)' : path),
                                      subtitle: Text('exit=$exit • ${out.split('\n').first}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: ActionButton(
                            onPressed: () => launchUrlString('https://brew.sh/zh-cn/', mode: LaunchMode.externalApplication),
                            isPrimary: true,
                            minWidth: 120,
                            child: Text(AppLocalizations.of(context)!.actionOpenHomebrewSite),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ActionButton(
                            onPressed: _check,
                            minWidth: 120,
                            child: Text(AppLocalizations.of(context)!.actionIInstalledRecheck),
                          ),
                        ),
                      ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 