// lib/widgets/common/mini_stat_card.dart
import 'package:flutter/material.dart';

/// A compact stat card used within gradient containers.
/// Displays a label, value, icon, and optional sub-value.
/// Can be made tappable with the onTap callback.
class MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? subValue;
  final VoidCallback? onTap;

  const MiniStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subValue ?? ' ',
                style: TextStyle(
                  fontSize: 10,
                  color: subValue != null
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final container = Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: content,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: container,
        ),
      );
    }

    return container;
  }
}
