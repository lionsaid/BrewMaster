import 'dart:ui' show ImageFilter;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:brew_master/core/services/brew_service.dart';
import 'package:brew_master/core/widgets/app_card.dart';
import 'package:brew_master/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
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
  static const String _recommendUrl = 'https://lionsaid-1305508138.cos.ap-beijing.myqcloud.com/brew_master/recommend/recommendations.json';

  List<_Section> _sections = [];
  bool _isLoading = true;
  String? _loadError;
  final List<_App> _featured = [];
  int _currentFeaturedIndex = 0;
  Timer? _featuredTimer;
  static const String _featuredUrl = 'https://lionsaid-1305508138.cos.ap-beijing.myqcloud.com/brew_master/recommend/featured.json';
  late final PageController _pageController;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      final double? p = _pageController.page;
      if (p != null) setState(() => _page = p);
    });
    _loadAll();
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadRecommendations(),
      _loadFeatured(),
    ]);
    _startFeaturedAutoSwitch();
  }

  Future<void> _loadRecommendations() async {
    try {
      final http.Response response = await http.get(Uri.parse(_recommendUrl)).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> sectionsJson = (jsonMap['sections'] as List<dynamic>? ?? <dynamic>[]);
      final List<_Section> sections = sectionsJson
          .map((dynamic item) => _Section.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
      setState(() { _sections = sections; _isLoading = false; _loadError = null; });
    } catch (e) {
      // 回退到本地资源，保证在离线或网络异常时仍可用
      try {
        final String jsonString = await rootBundle.loadString('assets/data/recommendations.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        final List<dynamic> sectionsJson = (jsonMap['sections'] as List<dynamic>? ?? <dynamic>[]);
        final List<_Section> sections = sectionsJson
            .map((dynamic item) => _Section.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
        setState(() { _sections = sections; _isLoading = false; _loadError = null; });
      } catch (_) {
        setState(() { _isLoading = false; _loadError = '加载推荐数据失败'; });
      }
    }
  }

  Future<void> _loadFeatured() async {
    try {
      final http.Response response = await http.get(Uri.parse(_featuredUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> appsJson = (jsonMap['apps'] as List<dynamic>? ?? <dynamic>[]);
      _featured
        ..clear()
        ..addAll(appsJson.map((e) => _App.fromJson(e as Map<String, dynamic>)));
    } catch (_) {
      try {
        final String jsonString = await rootBundle.loadString('assets/data/featured.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        final List<dynamic> appsJson = (jsonMap['apps'] as List<dynamic>? ?? <dynamic>[]);
        _featured
          ..clear()
          ..addAll(appsJson.map((e) => _App.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        if (_sections.isNotEmpty) {
          _featured
            ..clear()
            ..addAll(_sections.first.apps.take(3));
        }
      }
    }
  }

  void _startFeaturedAutoSwitch() {
    _featuredTimer?.cancel();
    if (_featured.length <= 1) return;
    _featuredTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final int next = (_currentFeaturedIndex + 1) % _featured.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(child: Text(_loadError!));
    }
    if (_sections.isEmpty || _sections.first.apps.isEmpty) {
      return const Center(child: Text('暂无推荐数据'));
    }
    final _App heroApp = (_featured.isNotEmpty)
        ? _featured[_currentFeaturedIndex % _featured.length]
        : _sections.first.apps.first;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          _heroCarousel(heroApp),
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

  Widget _heroCarousel(_App _ignored) {
    final List<_App> items = _featured.isNotEmpty
        ? _featured
        : (_sections.isNotEmpty ? _sections.first.apps.take(3).toList(growable: false) : <_App>[]);
    if (items.isEmpty) return const SizedBox.shrink();
    return _NeonBorder(
      radius: 16,
      width: 2.5,
      child: FrostCard(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 180,
          child: Stack(children: [
            PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (int i) => setState(() => _currentFeaturedIndex = i),
              itemBuilder: (BuildContext _, int index) {
                final _App app = items[index];
                final double delta = (index - _page).toDouble();
                final double scale = (1 - (delta.abs() * 0.06)).clamp(0.9, 1.0);
                final double opacity = (1 - delta.abs() * 0.3).clamp(0.3, 1.0);
                final double translateX = -delta * 24; // 左滑视差
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 280),
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(translateX, 0),
                    child: Transform.scale(
                      scale: scale,
                      child: _heroSlide(app),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(items.length, (int i) {
                  final bool active = i == _currentFeaturedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: active ? 22 : 8,
                    decoration: BoxDecoration(
                      color: active ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            )
          ]),
        ),
      ),
      ),
    );
  }

  Widget _heroSlide(_App app, {Key? key}) {
    return SizedBox(
      key: key,
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

  // 彩虹霓虹边框容器
}

class _NeonBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  final double width;
  const _NeonBorder({required this.child, this.radius = 16, this.width = 2.5});
  @override
  State<_NeonBorder> createState() => _NeonBorderState();
}

class _NeonBorderState extends State<_NeonBorder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final double radius = widget.radius;
    final double borderWidth = widget.width;
    const List<Color> colors = [
      Color(0xFFFF6B6B), // red
      Color(0xFFFFB86C), // orange
      Color(0xFF50FA7B), // green
      Color(0xFF3E8EED), // blue
      Color(0xFF9A7DFF), // purple
      Color(0xFFFF6B6B), // red back to start for smooth loop
    ];
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final double angle = _controller.value * 2 * math.pi;
        return Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(angle),
            ),
            shadows: [
              BoxShadow(color: colors[0].withOpacity(0.25), blurRadius: 24, spreadRadius: 1),
              BoxShadow(color: colors[3].withOpacity(0.2), blurRadius: 24, spreadRadius: 1),
            ],
          ),
          padding: EdgeInsets.all(borderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - borderWidth),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _Section {
  final String title; final List<_App> apps; const _Section({required this.title, required this.apps});
  factory _Section.fromJson(Map<String, dynamic> json) {
    final List<dynamic> appsJson = (json['apps'] as List<dynamic>? ?? <dynamic>[]);
    return _Section(
      title: json['title'] as String? ?? '',
      apps: appsJson.map((dynamic e) => _App.fromJson(e as Map<String, dynamic>)).toList(growable: false),
    );
  }
}

class _App {
  final String name; final String homepage; final bool isCask; final List<String> tags;
  const _App({required this.name, required this.homepage, required this.isCask, required this.tags});
  factory _App.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawTags = (json['tags'] as List<dynamic>? ?? <dynamic>[]);
    return _App(
      name: json['name'] as String? ?? '',
      homepage: json['homepage'] as String? ?? '',
      isCask: json['isCask'] as bool? ?? false,
      tags: rawTags.map((dynamic e) => e.toString()).toList(growable: false),
    );
  }
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