// lib/widgets/common/mini_stat_card.dart
import 'package:flutter/material.dart';

/// A full-width stat card displaying date range, transaction info, and secondary stat.
/// Used within gradient containers to show comprehensive spending statistics.
class MiniStatCard extends StatelessWidget {
  final String dateLabel;
  final int transactionCount;
  final int itemCount;
  final String secondaryStatLabel;
  final String secondaryStatValue;
  final IconData secondaryStatIcon;
  final int missingDays;
  final VoidCallback? onTap;

  const MiniStatCard({
    super.key,
    required this.dateLabel,
    required this.transactionCount,
    required this.itemCount,
    required this.secondaryStatLabel,
    required this.secondaryStatValue,
    required this.secondaryStatIcon,
    this.missingDays = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range row with icon
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: isDark ? Colors.white : primaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : onSurfaceColor.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '$transactionCount',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : onSurfaceColor,
                          ),
                        ),
                        Text(
                          ' transactions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : onSurfaceColor.withValues(alpha: 0.85),
                          ),
                        ),
                        if (missingDays > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  size: 10,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '$missingDays day${missingDays > 1 ? 's' : ''} missing',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Divider
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.1),
          ),

          const SizedBox(height: 8),

          // Bottom row with items count and secondary stat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Items count
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : onSurfaceColor.withValues(alpha: 0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$itemCount items',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.75)
                              : onSurfaceColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Secondary stat
              Row(
                children: [
                  Icon(
                    secondaryStatIcon,
                    color: isDark ? Colors.white : primaryColor,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        secondaryStatLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : onSurfaceColor.withValues(alpha: 0.65),
                        ),
                      ),
                      Text(
                        secondaryStatValue,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : onSurfaceColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: content,
        ),
      );
    }

    return content;
  }
}
