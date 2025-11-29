// lib/widgets/common/spending_summary_card.dart
import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_range_helper.dart';
import '../glass_container.dart';
import 'mini_stat_card.dart';

/// A summary card showing total spending, transaction count, and secondary stat.
/// Used in both Analytics and Expense List screens.
class SpendingSummaryCard extends StatelessWidget {
  final List<Expense> expenses;
  final DateTimeRange? dateRange;
  final VoidCallback? onDateRangeTap;

  /// The main icon shown in the top right corner
  final IconData mainIcon;

  /// Label for the secondary stat (e.g., 'Average', 'Avg/Day')
  final String secondaryStatLabel;

  /// Value for the secondary stat - if null, calculates average per transaction
  final double? secondaryStatValue;

  /// Icon for the secondary stat
  final IconData secondaryStatIcon;

  const SpendingSummaryCard({
    super.key,
    required this.expenses,
    this.dateRange,
    this.onDateRangeTap,
    this.mainIcon = Icons.account_balance_wallet_rounded,
    this.secondaryStatLabel = 'Average',
    this.secondaryStatValue,
    this.secondaryStatIcon = Icons.analytics_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final transactionCount = expenses.length;
    final itemTotal = _getItemTotal();
    final dateLabel = DateRangeHelper.getDateLabel(dateRange);
    final secondaryStat = secondaryStatValue ?? _calculateAverage();

    return GradientGlassContainer(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainStat(context, total),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniStatCard(
                  label: dateLabel,
                  value: '$transactionCount transactions',
                  icon: Icons.calendar_today_rounded,
                  subValue: 'On $itemTotal items',
                  onTap: onDateRangeTap,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: MiniStatCard(
                  label: secondaryStatLabel,
                  value: CurrencyFormatter.formatCompact(secondaryStat, 'IDR'),
                  icon: secondaryStatIcon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStat(BuildContext context, double total) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Spending',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : onSurfaceColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                CurrencyFormatter.formatCompact(total, 'IDR'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            mainIcon,
            color: isDark ? Colors.white : primaryColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    return expenses.fold<double>(0, (sum, e) => sum + e.totalValue);
  }

  int _getItemTotal() {
    return expenses.fold<int>(0, (sum, e) => sum + e.items.length);
  }

  double _calculateAverage() {
    if (expenses.isEmpty) return 0;
    return _calculateTotal() / expenses.length;
  }
}
