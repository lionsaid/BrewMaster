import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

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

/// Unified action button component, ensuring consistent button width across different languages
class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isPrimary;
  final double? minWidth;
  final EdgeInsetsGeometry? padding;
  final double? height; // Unified height (default 36)

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
    // Unified button height
    final double effectiveHeight = height ?? 36.0;

    // Ensure button text uses fixed font style, not affected by theme font changes
    final buttonStyle = (style ?? const ButtonStyle()).copyWith(
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          fontFamily: '.SF Pro Text', // Use system default font
        ),
      ),
      minimumSize: MaterialStateProperty.all(Size(minWidth ?? 80, effectiveHeight)),
      maximumSize: MaterialStateProperty.all(Size(minWidth ?? 80, effectiveHeight)),
      padding: MaterialStateProperty.all(padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      // Directly specify tapTargetSize, adapt to old signature
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      // Prevent text wrapping
      alignment: Alignment.center,
    );

    // Ensure child is Text when automatically adjusting size to fit button
    final wrappedChild = child is Text 
        ? AutoSizeText(
            (child as Text).data ?? '',
            style: (child as Text).style,
            textAlign: TextAlign.center,
            maxLines: 1,
            minFontSize: 10,
            maxFontSize: 14,
            group: AutoSizeGroup(), // Ensure consistent text size for buttons in the same group
          )
        : child;

    final button = isPrimary
        ? FilledButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: wrappedChild,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: wrappedChild,
          );

    return SizedBox(
      width: minWidth ?? 80,
      height: effectiveHeight,
      child: Center(
        child: button,
      ),
    );
  }
}

/// Action button with icon
class ActionIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final ButtonStyle? style;
  final bool isPrimary;
  final double? minWidth;
  final EdgeInsetsGeometry? padding;
  final double? height; // Unified height (default 36)

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
    // Unified button height
    final double effectiveHeight = height ?? 36.0;

    // Ensure button text uses fixed font style, not affected by theme font changes
    final buttonStyle = (style ?? const ButtonStyle()).copyWith(
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          fontFamily: '.SF Pro Text', // Use system default font
        ),
      ),
      minimumSize: MaterialStateProperty.all(Size(minWidth ?? 100, effectiveHeight)),
      padding: MaterialStateProperty.all(padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      // Directly specify tapTargetSize, adapt to old signature
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