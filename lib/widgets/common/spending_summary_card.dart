// lib/widgets/common/spending_summary_card.dart
import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_range_helper.dart';
import '../glass_container.dart';
import 'mini_stat_card.dart';

/// A summary card showing total spending, transaction count, and secondary stat.
/// Used in both Analytics and Expense List screens.
class SpendingSummaryCard extends StatefulWidget {
  final List<Expense> expenses;
  final DateTimeRange? dateRange;
  final VoidCallback? onDateRangeTap;

  /// The main icon shown in the top right corner
  final IconData mainIcon;

  /// Label for the secondary stat (e.g., 'Average', 'Avg/Day')
  final String secondaryStatLabel;

  /// Value for the secondary stat - if null, calculates average per transaction
  final double secondaryStatValue;

  /// Icon for the secondary stat
  final IconData secondaryStatIcon;

  const SpendingSummaryCard({
    super.key,
    required this.expenses,
    required this.secondaryStatValue,
    this.dateRange,
    this.onDateRangeTap,
    this.mainIcon = Icons.account_balance_wallet_rounded,
    this.secondaryStatLabel = 'Average',
    this.secondaryStatIcon = Icons.analytics_rounded,
  });

  @override
  State<SpendingSummaryCard> createState() => _SpendingSummaryCardState();
}

class _SpendingSummaryCardState extends State<SpendingSummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final transactionCount = widget.expenses.length;
    final itemTotal = _getItemTotal();
    final dateLabel = DateRangeHelper.getDateLabel(widget.dateRange);
    final secondaryStat = widget.secondaryStatValue;
    final missingDays = _calculateMissingDays();

    return GradientGlassContainer(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainStat(context, total),
          AnimatedCrossFade(
            firstChild: Column(
              children: [
                SizedBox(height: 16),
                MiniStatCard(
                  dateLabel: dateLabel,
                  transactionCount: transactionCount,
                  itemCount: itemTotal,
                  secondaryStatLabel: widget.secondaryStatLabel,
                  secondaryStatValue: CurrencyFormatter.formatCompact(
                    secondaryStat,
                    'IDR',
                  ),
                  secondaryStatIcon: widget.secondaryStatIcon,
                  missingDays: missingDays,
                  onTap: widget.onDateRangeTap,
                ),
              ],
            ),
            secondChild: SizedBox.shrink(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 300),
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
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.mainIcon,
                color: isDark ? Colors.white : primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? Colors.white : primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateTotal() {
    return widget.expenses.fold<double>(0, (sum, e) => sum + e.totalValue);
  }

  int _getItemTotal() {
    return widget.expenses.fold<int>(0, (sum, e) => sum + e.items.length);
  }

  int _calculateMissingDays() {
    // Only calculate for specific date ranges (not "All Time")
    if (widget.dateRange == null) return 0;
    if (widget.expenses.isEmpty) return 0;

    // Get all unique dates with expenses (normalize to start of day)
    final expenseDates = widget.expenses.map((e) {
      final date = e.spentAt;
      return DateTime(date.year, date.month, date.day);
    }).toSet();

    // Calculate total days in range
    final startDate = DateTime(
      widget.dateRange!.start.year,
      widget.dateRange!.start.month,
      widget.dateRange!.start.day,
    );
    final endDate = DateTime(
      widget.dateRange!.end.year,
      widget.dateRange!.end.month,
      widget.dateRange!.end.day,
    );

    final totalDays = endDate.difference(startDate).inDays + 1;

    // Count days with expenses
    final daysWithExpenses = expenseDates.where((date) {
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).length;

    // Missing days = total days - days with expenses
    return totalDays - daysWithExpenses;
  }
}
