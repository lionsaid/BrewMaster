import 'package:flutter/widgets.dart';

class NoiseOverlay extends StatelessWidget {
  final double opacity;
  final double density; // 0..1 fraction of pixels painted
  const NoiseOverlay({super.key, this.opacity = 0.04, this.density = 0.12});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _NoisePainter(opacity: opacity, density: density),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double opacity;
  final double density;
  const _NoisePainter({required this.opacity, required this.density});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF000000).withOpacity(opacity);
    const double step = 4; // coarse grid for performance
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        // Deterministic pseudo-random based on coordinates
        final int h = _hash2(x.toInt(), y.toInt());
        if ((h & 0xFF) / 255.0 < density) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
        }
      }
    }
  }

  static int _hash2(int x, int y) {
    int h = x * 73856093 ^ y * 19349663;
    h ^= (h << 13);
    h ^= (h >> 17);
    h ^= (h << 5);
    return h & 0x7fffffff;
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) => false;
} 