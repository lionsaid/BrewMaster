import 'dart:io';
import 'package:flutter/material.dart';

class TypeIcon extends StatelessWidget {
  final bool isCask;
  final double size;
  const TypeIcon({super.key, required this.isCask, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = isCask ? const Color(0xFF7C3AED) : const Color(0xFF0EA5E9);
    final icon = isCask ? Icons.apps : Icons.science;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.9), color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.6),
    );
  }
}

class FaviconImage extends StatefulWidget {
  final String host;
  final double size;
  const FaviconImage({super.key, required this.host, this.size = 32});

  @override
  State<FaviconImage> createState() => _FaviconImageState();
}

class _FaviconImageState extends State<FaviconImage> {
  String? _resolvedUrl;
  bool _probing = true;

  List<String> get _candidates => [
        'https://www.google.com/s2/favicons?domain=${widget.host}&sz=${(widget.size * 2).round()}',
        'https://icons.duckduckgo.com/ip3/${widget.host}.ico',
        'https://${widget.host}/favicon.ico',
      ];

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    for (final url in _candidates) {
      try {
        final ok = await _checkUrl(url);
        if (ok) {
          if (!mounted) return;
          setState(() { _resolvedUrl = url; _probing = false; });
          return;
        }
      } catch (_) {
        // ignore and try next
      }
    }
    if (mounted) setState(() { _resolvedUrl = null; _probing = false; });
  }

  Future<bool> _checkUrl(String url) async {
    final uri = Uri.parse(url);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      final req = await client.getUrl(uri);
      final res = await req.close();
      if (res.statusCode >= 200 && res.statusCode < 400) {
        final type = res.headers.contentType;
        if (type == null) return true; // some servers don't send it
        final t = '${type.mimeType}'.toLowerCase();
        if (t.contains('image/') || t.contains('x-icon') || t.contains('ico')) return true;
      }
      return false;
    } finally {
      client.close(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resolvedUrl != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.network(_resolvedUrl!, fit: BoxFit.cover),
      );
    }
    // probing or failed: show placeholder
    return Container(
      width: widget.size,
      height: widget.size,
      color: Colors.black12,
      alignment: Alignment.center,
      child: Icon(Icons.apps, size: widget.size * 0.6, color: Colors.black38),
    );
  }
}

class FaviconOrTypeIcon extends StatelessWidget {
  final bool isCask;
  final String homepage;
  final double size;
  const FaviconOrTypeIcon({super.key, required this.isCask, required this.homepage, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final host = Uri.tryParse(homepage)?.host;
    if (host == null || host.isEmpty) {
      return TypeIcon(isCask: isCask, size: size);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned.fill(child: TypeIcon(isCask: isCask, size: size)),
        Positioned.fill(child: FaviconImage(host: host, size: size)),
      ]),
    );
  }
}
