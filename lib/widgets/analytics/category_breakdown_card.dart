// lib/widgets/analytics/category_breakdown_card.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/expense.dart';
import '../../utils/currency_formatter.dart';
import '../glass_container.dart';

/// Displays a breakdown of expenses by category with progress bars.
class CategoryBreakdownCard extends StatelessWidget {
  final List<Expense> expenses;

  const CategoryBreakdownCard({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark),
          SizedBox(height: 24),
          if (categoryTotals.isEmpty)
            _buildEmptyState(context)
          else
            ...() {
              // Calculate total and sort categories by value (descending)
              final total = categoryTotals.values.fold<double>(0, (a, b) => a + b);
              final sortedEntries = categoryTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return sortedEntries.map((entry) {
                final percentage = (entry.value / total * 100);
                return _buildCategoryRow(context, entry.key, entry.value, percentage, isDark);
              });
            }(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.pie_chart_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'By Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Spending distribution',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No expenses to display',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String category,
    double value,
    double percentage,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.formatCompact(value, 'IDR'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals() {
    final categoryTotals = <String, double>{};

    for (var expense in expenses) {
      for (var item in expense.items) {
        categoryTotals[item.spentType] =
            (categoryTotals[item.spentType] ?? 0) + item.value;
      }
    }

    return categoryTotals;
  }
}
