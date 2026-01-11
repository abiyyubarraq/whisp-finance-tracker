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

  // Weekday labels starting from Sunday
  static const List<String> _weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

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
                SizedBox(height: 16),
                _buildCalendarView(context),
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

  Widget _buildCalendarView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get the month to display from dateRange or current month
    final DateTime displayMonth = widget.dateRange?.start ?? DateTime.now();
    final int year = displayMonth.year;
    final int month = displayMonth.month;

    // Calculate daily expense totals
    final dailyTotals = _calculateDailyTotals(year, month);

    // Get first day of month and number of days
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    // Calculate total cells needed (weekday offset + days in month)
    // Only render exactly the cells needed - no extra empty cells at the end
    final gridCellCount = startingWeekday + daysInMonth;

    // Current date for future date check
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Month/Year header
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header - compact
          Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Center(
              child: Text(
                '${monthNames[month - 1]} $year',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          // Weekday headers - compact
          Row(
            children: _weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 2),
          // Calendar grid using LayoutBuilder for responsive cell sizing
          // Using Wrap instead of GridView to avoid extra space after last row
          LayoutBuilder(
            builder: (context, constraints) {
              // Defensive check: ensure we have valid width before building
              if (constraints.maxWidth <= 0) {
                return const SizedBox.shrink();
              }

              // Calculate cell dimensions based on available width
              const double spacing = 1.0;
              final cellWidth = (constraints.maxWidth - (spacing * 6)) / 7;
              final cellHeight =
                  cellWidth / 2.0; // Aspect ratio 2:1 (width:height)

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(gridCellCount, (index) {
                  // Calculate the day number
                  final dayOffset = index - startingWeekday;

                  // Empty placeholder for days before month starts
                  if (dayOffset < 0) {
                    return SizedBox(width: cellWidth, height: cellHeight);
                  }

                  // Stop rendering after last day of month
                  if (dayOffset >= daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final dayNumber = dayOffset + 1;
                  final cellDate = DateTime(year, month, dayNumber);
                  final isFuture = cellDate.isAfter(today);
                  final dayTotal = dailyTotals[dayNumber] ?? 0.0;
                  final hasExpenses = dayTotal > 0;

                  return SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: _buildDayCell(
                      context,
                      dayNumber: dayNumber,
                      amount: dayTotal,
                      hasExpenses: hasExpenses,
                      isFuture: isFuture,
                      isToday: cellDate.isAtSameMomentAs(today),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context, {
    required int dayNumber,
    required double amount,
    required bool hasExpenses,
    required bool isFuture,
    required bool isToday,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Determine background color based on state
    Color backgroundColor;
    Color textColor;
    Color amountColor;

    if (isFuture) {
      // Future dates - transparent/subtle
      backgroundColor = Colors.transparent;
      textColor = isDark
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.black.withValues(alpha: 0.2);
      amountColor = textColor;
    } else if (hasExpenses) {
      // Has expenses - purple/primary background
      backgroundColor = primaryColor.withValues(alpha: isDark ? 0.8 : 0.9);
      textColor = Colors.white;
      // Use amber/gold color for expense amount - stands out against purple
      amountColor = const Color(0xFFFFD54F); // Amber 300 - bright yellow-gold
    } else {
      // No expenses - gray background
      backgroundColor = isDark
          ? Colors.grey.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.25);
      textColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
      amountColor = textColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: isToday
            ? Border.all(color: isDark ? Colors.white : primaryColor, width: 1)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day number - compact font size
            Text(
              dayNumber.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.0,
              ),
            ),
            // Amount (only show if has expenses and not future)
            if (hasExpenses && !isFuture)
              Text(
                _formatDayAmount(amount),
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                  height: 2.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  /// Calculate daily expense totals for a given month
  Map<int, double> _calculateDailyTotals(int year, int month) {
    final Map<int, double> dailyTotals = {};

    for (final expense in widget.expenses) {
      final spentDate = expense.spentAt;
      if (spentDate.year == year && spentDate.month == month) {
        final day = spentDate.day;
        dailyTotals[day] = (dailyTotals[day] ?? 0) + expense.totalValue;
      }
    }

    return dailyTotals;
  }

  /// Format amount for day cell display (compact, no currency symbol)
  String _formatDayAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
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
