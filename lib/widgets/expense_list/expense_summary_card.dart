// lib/widgets/expense_list/expense_summary_card.dart
import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../widgets/glass_container.dart';
import '../../utils/currency_formatter.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final List<Expense> expenses;
  final DateTimeRange? dateRange;
  final Function(DateTimeRange?) onDateRangeSelected;

  const ExpenseSummaryCard({
    super.key,
    required this.expenses,
    this.dateRange,
    required this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final filteredCount = _getFilteredCount();
    final average = _calculateAverage();
    final dateLabel = _getDateLabel();
    final itemTotal = _getItemTotal();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GradientGlassContainer(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainStat(context, total),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDateRangePicker(context),
                    behavior: HitTestBehavior.opaque,
                    child: _buildMiniStat(
                      dateLabel,
                      '$filteredCount transactions',
                      Icons.calendar_today_rounded,
                      onTap: () => _showDateRangePicker(context),
                      subValue: 'On $itemTotal items',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStat(
                    'Average',
                    CurrencyFormatter.formatCompact(average, 'IDR'),
                    Icons.analytics_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStat(BuildContext context, double total) {
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
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                CurrencyFormatter.formatCompact(total, 'IDR'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.trending_up_rounded, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    String? subValue,
  }) {
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
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.05),
            child: container,
          ),
        ),
      );
    }

    return container;
  }

  double _calculateTotal() {
    return expenses.fold<double>(0, (sum, e) => sum + e.totalValue);
  }

  int _getItemTotal() {
    return expenses.fold<int>(0, (sum, e) => sum + e.items.length);
  }

  int _getFilteredCount() {
    return expenses.length;
  }

  String _getDateLabel() {
    if (dateRange == null) {
      return 'All Time';
    }

    final startStr = _formatDate(dateRange!.start);
    final endStr = _formatDate(dateRange!.end);
    return '$startStr - $endStr';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    try {
      final now = DateTime.now();
      final lastDate = DateTime(now.year, now.month, now.day);

      DateTimeRange? initialRange;
      if (dateRange != null) {
        // Clamp the existing date range to ensure it's within valid bounds
        final clampedStart = dateRange!.start.isBefore(DateTime(2020))
            ? DateTime(2020)
            : (dateRange!.start.isAfter(lastDate)
                  ? lastDate
                  : dateRange!.start);
        final clampedEnd = dateRange!.end.isAfter(lastDate)
            ? lastDate
            : (dateRange!.end.isBefore(clampedStart)
                  ? clampedStart
                  : dateRange!.end);
        initialRange = DateTimeRange(start: clampedStart, end: clampedEnd);
      } else {
        // When dateRange is null (All Time), don't pre-select any dates
        initialRange = null;
      }

      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: lastDate,
        initialDateRange: initialRange,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600, maxHeight: 600),
                child: child,
              ),
            ),
          );
        },
      );

      if (picked != null) {
        onDateRangeSelected(picked);
      }
    } catch (e) {
      debugPrint('Error showing date range picker: $e');
    }
  }

  double _calculateAverage() {
    if (expenses.isEmpty) return 0;
    return _calculateTotal() / expenses.length;
  }
}
