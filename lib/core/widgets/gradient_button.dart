import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final List<Color> colors;

  const GradientButton({super.key, required this.label, required this.onPressed, this.colors = const [Color(0xFFFFB703), Color(0xFFFF8F00)]});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: enabled ? colors : [Colors.grey.shade300, Colors.grey.shade400]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

/// 统一的操作按钮组件，确保不同语言下的按钮宽度一致
class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isPrimary;
  final double? minWidth;
  final EdgeInsetsGeometry? padding;
  final double? height; // 统一高度（默认 36）

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isPrimary = false,
    this.minWidth,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // 统一按钮高度
    final double effectiveHeight = height ?? 36.0;

    // 确保按钮文本使用固定的字体样式，不受主题字体变化影响
    final buttonStyle = (style ?? const ButtonStyle()).copyWith(
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          fontFamily: '.SF Pro Text', // 使用系统默认字体
        ),
      ),
      minimumSize: MaterialStateProperty.all(Size(minWidth ?? 80, effectiveHeight)),
      padding: MaterialStateProperty.all(padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      // 直接指定 tapTargetSize，适配旧版签名
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final button = isPrimary
        ? FilledButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: child,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: child,
          );

    return SizedBox(
      width: minWidth ?? 80,
      height: effectiveHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: button,
      ),
    );
  }
}

/// 带图标的操作按钮
class ActionIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final ButtonStyle? style;
  final bool isPrimary;
  final double? minWidth;
  final EdgeInsetsGeometry? padding;
  final double? height; // 统一高度（默认 36）

  const ActionIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.style,
    this.isPrimary = false,
    this.minWidth,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // 统一按钮高度
    final double effectiveHeight = height ?? 36.0;

    // 确保按钮文本使用固定的字体样式，不受主题字体变化影响
    final buttonStyle = (style ?? const ButtonStyle()).copyWith(
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          fontFamily: '.SF Pro Text', // 使用系统默认字体
        ),
      ),
      minimumSize: MaterialStateProperty.all(Size(minWidth ?? 100, effectiveHeight)),
      padding: MaterialStateProperty.all(padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      // 直接指定 tapTargetSize，适配旧版签名
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final button = isPrimary
        ? FilledButton.icon(
            onPressed: onPressed,
            style: buttonStyle,
            icon: icon,
            label: label,
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            style: buttonStyle,
            icon: icon,
            label: label,
          );

    return SizedBox(
      width: minWidth ?? 100,
      height: effectiveHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: button,
      ),
    );
  }
} 