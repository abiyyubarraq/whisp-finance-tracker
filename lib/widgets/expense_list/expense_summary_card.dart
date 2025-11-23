// lib/widgets/expense_list/expense_summary_card.dart
import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../widgets/glass_container.dart';
import '../../utils/currency_formatter.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseSummaryCard({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final thisMonthCount = _getThisMonthCount();
    final average = _calculateAverage();

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
                  child: _buildMiniStat(
                    context,
                    'This Month',
                    '$thisMonthCount transactions',
                    Icons.calendar_today_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStat(
                    context,
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
                CurrencyFormatter.format(total, 'IDR'),
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
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    return expenses.fold<double>(0, (sum, e) => sum + e.totalValue);
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    return expenses.where((e) {
      return e.spentAt.month == now.month && e.spentAt.year == now.year;
    }).length;
  }

  double _calculateAverage() {
    if (expenses.isEmpty) return 0;
    return _calculateTotal() / expenses.length;
  }
}
