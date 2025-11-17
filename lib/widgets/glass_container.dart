import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.15,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.gradient,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        color ??
        (isDark ? Theme.of(context).colorScheme.surface : Colors.white);
    final effectiveOpacity = isDark ? opacity : opacity * 3;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(24);

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow:
            boxShadow ?? (isDark ? AppTheme.darkShadow : AppTheme.lightShadow),
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: effectiveOpacity),
              borderRadius: effectiveBorderRadius,
              border:
                  border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.3),
                    width: 1,
                  ),
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Gradient Glass Container
class GradientGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const GradientGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: borderRadius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                AppTheme.gradientDark[0].withValues(alpha: 0.3),
                AppTheme.gradientDark[1].withValues(alpha: 0.3),
              ]
            : [
                AppTheme.gradientLight[0].withValues(alpha: 0.2),
                AppTheme.gradientLight[1].withValues(alpha: 0.2),
              ],
      ),
      child: child,
    );
  }
}
