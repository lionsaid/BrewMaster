import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final BoxBorder? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final needsContainer = gradient != null || color != null || border != null;
    if (!needsContainer) {
      return Card(child: Padding(padding: padding, child: child));
    }
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: border,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class FrostCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const FrostCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final tint = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withOpacity(0.25)
        : Colors.white.withOpacity(0.45);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: child, // 移除 Padding，直接使用 child
        ),
      ),
    );
  }
} 