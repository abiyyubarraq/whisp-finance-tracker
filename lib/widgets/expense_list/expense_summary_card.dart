// lib/widgets/expense_list/expense_summary_card.dart
import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../utils/date_range_helper.dart';
import '../common/spending_summary_card.dart';

/// Summary card for the expense list screen.
/// Wraps SpendingSummaryCard with date range selection callback.
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
    final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.totalValue);
    final avgPerDay = totalSpent / dateRange!.duration.inDays.clamp(1, 999);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SpendingSummaryCard(
        expenses: expenses,
        dateRange: dateRange,
        onDateRangeTap: () => _showDateRangePicker(context),
        mainIcon: Icons.trending_up_rounded,
        secondaryStatLabel: 'Avg/Day',
        secondaryStatValue: avgPerDay,
        secondaryStatIcon: Icons.analytics_rounded,
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await DateRangeHelper.showPicker(
      context,
      initialRange: dateRange,
    );

    if (picked != null) {
      onDateRangeSelected(picked);
    }
  }
}
