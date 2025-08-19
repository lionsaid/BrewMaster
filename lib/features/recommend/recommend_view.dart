import 'dart:ui' show ImageFilter;
import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:brew_master/l10n/app_localizations.dart';

class RecommendView extends StatefulWidget {
  const RecommendView({super.key});
  @override
  State<RecommendView> createState() => _RecommendViewState();
}

class _RecommendViewState extends State<RecommendView> {
  final BrewService _brew = BrewService();
  final Map<String, bool> _busy = {};
  final Map<String, bool> _installed = {};
  final Map<String, String> _lastLine = {};

  final List<_Section> _sections = const [
    _Section(
      title: '开发者必备',
      apps: [
        _App(name: 'iterm2', homepage: 'https://iterm2.com', isCask: true, tags: ['终端', '开发者']),
        _App(name: 'visual-studio-code', homepage: 'https://code.visualstudio.com', isCask: true, tags: ['IDE', '编辑器']),
        _App(name: 'oh-my-zsh', homepage: 'https://ohmyz.sh', isCask: false, tags: ['shell', '插件']),
      ],
    ),
    _Section(
      title: '系统增强工具',
      apps: [
        _App(name: 'rectangle', homepage: 'https://rectangleapp.com', isCask: true, tags: ['窗口管理']),
        _App(name: 'the-unarchiver', homepage: 'https://theunarchiver.com', isCask: true, tags: ['解压']),
        _App(name: 'stats', homepage: 'https://github.com/exelban/stats', isCask: true, tags: ['系统监控']),
      ],
    ),
    _Section(
      title: '设计与创意',
      apps: [
        _App(name: 'figma', homepage: 'https://www.figma.com', isCask: true, tags: ['设计']),
        _App(name: 'imageoptim', homepage: 'https://imageoptim.com', isCask: true, tags: ['图片优化']),
        _App(name: 'handbrake', homepage: 'https://handbrake.fr', isCask: true, tags: ['视频转码']),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final heroApp = _sections.first.apps.first;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          _hero(heroApp),
          const SizedBox(height: 16),
          ..._sections.expand((s) => [
                Text(s.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: s.apps.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, j) => _card(s.apps[j]),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
        ],
      ),
    );
  }

  Widget _hero(_App app) {
    final brand = const Color(0xFF5865F2);
    return FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 160,
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('本周精选', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('${app.displayName} · ${app.slogan}', maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 8, children: [
                  ActionButton(
                    onPressed: () => launchUrlString(app.homepage, mode: LaunchMode.externalApplication), 
                    minWidth: 90,
                    child: Text(AppLocalizations.of(context)!.actionLearnMore),
                  ),
                  ActionButton(
                    onPressed: (_busy[app.name] == true || _installed[app.name] == true) ? null : () => _install(app), 
                    isPrimary: true,
                    minWidth: 80,
                    child: Text(_installed[app.name] == true 
                        ? AppLocalizations.of(context)!.actionInstalled 
                        : (_busy[app.name] == true 
                            ? AppLocalizations.of(context)!.actionInstalling 
                            : AppLocalizations.of(context)!.actionInstall)),
                  ),
                ]),
              ]),
            ),
            const SizedBox(width: 16),
            _logo(app, size: 96),
          ]),
        ),
      ),
    );
  }

  Widget _card(_App app) {
    final busy = _busy[app.name] == true;
    final installed = _installed[app.name] == true;
    final log = _lastLine[app.name] ?? '';
    return SizedBox(
      width: 360,
      child: FrostCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _logo(app),
              const SizedBox(width: 12),
              Expanded(child: Text(app.displayName, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Text(app.slogan, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: -8, children: app.tags.map((t) => Chip(label: Text(t), visualDensity: VisualDensity.compact)).toList()),
            const Spacer(),
            if (log.isNotEmpty) ...[
              Text(log, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
            ],
            Row(children: [
              ActionButton(
                onPressed: () => launchUrlString(app.homepage, mode: LaunchMode.externalApplication), 
                minWidth: 90,
                child: Text(AppLocalizations.of(context)!.actionLearnMore),
              ),
              const Spacer(),
              ActionButton(
                onPressed: (busy || installed) ? null : () => _install(app), 
                isPrimary: true,
                minWidth: 80,
                child: Text(installed 
                    ? AppLocalizations.of(context)!.actionInstalled 
                    : busy 
                        ? AppLocalizations.of(context)!.actionInstalling 
                        : AppLocalizations.of(context)!.actionInstall),
              ),
            ])
          ]),
        ),
      ),
    );
  }

  Widget _logo(_App app, {double size = 32}) {
    final host = Uri.parse(app.homepage).host;
    final url = 'https://www.google.com/s2/favicons?sz=${(size * 2).round()}&domain=$host';
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 6),
      child: Stack(children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: size,
              height: size,
              color: Colors.black12,
              alignment: Alignment.center,
              child: Icon(Icons.apps, size: size * 0.6, color: Colors.black38),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 6),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
            ),
          ),
        )
      ]),
    );
  }

  Future<void> _install(_App app) async {
    setState(() { _busy[app.name] = true; _lastLine[app.name] = ''; });
    try {
      await _brew.streamInstallPackage(app.name, isCask: app.isCask, onLine: (l) => setState(() => _lastLine[app.name] = l));
      setState(() { _installed[app.name] = true; });
      _toast('${AppLocalizations.of(context)!.actionInstalled} ${app.displayName}');
    } finally {
      setState(() { _busy[app.name] = false; });
    }
  }

  void _toast(String message) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) {
      return Positioned(
        bottom: 40,
        left: 0,
        right: 0,
        child: IgnorePointer(
          ignoring: true,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(message, style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
    });
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }
}

class _Section {
  final String title; final List<_App> apps; const _Section({required this.title, required this.apps});
}

class _App {
  final String name; final String homepage; final bool isCask; final List<String> tags;
  const _App({required this.name, required this.homepage, required this.isCask, required this.tags});
  String get displayName => name.replaceAll('-', ' ');
  String get slogan => switch (name) {
    'iterm2' => '最好的终端替代品，功能强大',
    'visual-studio-code' => '流行的跨平台 IDE/编辑器',
    'oh-my-zsh' => '强大的 zsh 框架与插件生态',
    'rectangle' => '窗口分屏与管理',
    'the-unarchiver' => '更强的压缩与解压',
    'stats' => '漂亮的系统状态监控',
    'figma' => '协作式 UI/UX 设计',
    'imageoptim' => '图像无损/有损压缩',
    'handbrake' => '跨平台视频转码器',
    _ => '实用工具',
  };
} 