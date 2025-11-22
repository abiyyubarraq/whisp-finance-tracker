import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../config/theme.dart';
import 'glass_container.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseCard({super.key, required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showFlag = expense.aiConfidence == 'low';

    return GlassContainer(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.all(0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon with gradient background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? AppTheme.gradientDark
                              : AppTheme.gradientLight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor(
                              expense.items.isNotEmpty
                                  ? expense.items.first.spentType
                                  : 'other',
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getCategoryIcon(
                          expense.items.isNotEmpty
                              ? expense.items.first.spentType
                              : 'other',
                        ),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    // Expense info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expense.spentPlace,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (showFlag)
                                Container(
                                  margin: EdgeInsets.only(left: 8),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.flag_rounded,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            expense.desc ??
                                (expense.items.isNotEmpty
                                    ? '${expense.items.length} ${expense.items.length == 1 ? 'item' : 'items'}'
                                    : 'No description'),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Amount and details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Amount
                    Text(
                      '${expense.currency} ${_formatAmount(expense.totalValue)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    // Date
                    Text(
                      DateFormat('MMM dd, HH:mm').format(expense.spentAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Tags
                Row(
                  children: [
                    if (expense.items.isNotEmpty)
                      _buildTag(
                        context,
                        expense.items.first.spentType,
                        _getCategoryColor(expense.items.first.spentType),
                      ),
                    if (expense.items.isNotEmpty) SizedBox(width: 8),
                    _buildTag(
                      context,
                      expense.paymentSource,
                      Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    if (expense.items.length > 1) ...[
                      SizedBox(width: 8),
                      _buildTag(
                        context,
                        '+${expense.items.length - 1} more',
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'food': Color(0xFFEF4444),
      'coffee': Color(0xFF8B4513),
      'transportation': Color(0xFF3B82F6),
      'utilities': Color(0xFF10B981),
      'shopping': Color(0xFFF59E0B),
      'entertainment': Color(0xFF8B5CF6),
      'health': Color(0xFFEC4899),
      'education': Color(0xFF6366F1),
      'other': Color(0xFF6B7280),
    };
    return colors[category.toLowerCase()] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'food': Icons.restaurant_rounded,
      'coffee': Icons.coffee_rounded,
      'transportation': Icons.directions_car_rounded,
      'utilities': Icons.bolt_rounded,
      'shopping': Icons.shopping_bag_rounded,
      'entertainment': Icons.movie_rounded,
      'health': Icons.favorite_rounded,
      'education': Icons.school_rounded,
      'other': Icons.more_horiz_rounded,
    };
    return icons[category.toLowerCase()] ?? Icons.receipt_rounded;
  }
}
