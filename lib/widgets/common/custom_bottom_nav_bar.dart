// lib/widgets/common/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../glass_container.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onAddPressed;

  const CustomBottomNavBar({
    super.key,
    required this.currentRoute,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(20),
      child: GlassContainer(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.receipt_long_rounded,
              route: '/expenses',
              isDark: isDark,
            ),
            _buildAddButton(context, isDark),
            _buildNavItem(
              context,
              icon: Icons.analytics_rounded,
              route: '/analytics',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String route,
    required bool isDark,
  }) {
    final isSelected =
        currentRoute == route ||
        (route == '/expenses' && currentRoute == '/') ||
        (route == '/analytics' && currentRoute == '/');

    return GestureDetector(
      onTap: () {
        if (route == '/expenses' || route == '/analytics') {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? AppTheme.gradientDark
                      : AppTheme.gradientLight,
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                            .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onAddPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF512F).withValues(alpha: 0.6),
              blurRadius: 24,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0xFFDD2476).withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}
