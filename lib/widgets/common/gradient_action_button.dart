// lib/widgets/common/gradient_action_button.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// A gradient-styled action button commonly used in app bars.
/// Supports an optional active indicator dot for showing filter/selection state.
class GradientActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasActiveIndicator;
  final double size;
  final double iconSize;

  const GradientActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.hasActiveIndicator = false,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
        if (hasActiveIndicator)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }
}
