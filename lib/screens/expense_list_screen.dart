import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/glass_container.dart';
import '../config/theme.dart';
import '../utils/filter_sort.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  ExpenseFilter _filter = ExpenseFilter();
  ExpenseSort _sort = ExpenseSort(SortField.spentAt, SortDirection.descending);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Center(child: Text('Please login'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ModernAppBar(
          title: 'Expenses',
          actions: [
            SizedBox(width: 8),
            _buildActionButton(
              context,
              icon: Icons.filter_list_rounded,
              onTap: _showFilterSheet,
            ),
            SizedBox(width: 8),
            _buildActionButton(
              context,
              icon: Icons.sort_rounded,
              onTap: _showSortSheet,
            ),
            SizedBox(width: 8),
            _buildActionButton(
              context,
              icon: Icons.person_rounded,
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getExpensesStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            debugPrint('StreamBuilder error for expenses: ${snapshot.error}');
            return _buildErrorState(context);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final expenses = snapshot.data!.docs
              .map((doc) => Expense.fromFirestore(doc))
              .toList();

          final filteredExpenses = _applyFilters(expenses);
          final sortedExpenses = _applySorting(filteredExpenses);

          return Column(
            children: [
              // Summary card
              _buildSummaryCard(context, sortedExpenses),
              SizedBox(height: 16),
              // Expense list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 100),
                    itemCount: sortedExpenses.length,
                    itemBuilder: (context, index) {
                      return ExpenseCard(
                        expense: sortedExpenses[index],
                        onTap: () => _showExpenseDetails(sortedExpenses[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<Expense> expenses) {
    final total = expenses.fold<double>(0, (sum, e) => sum + e.value);
    final thisMonth = expenses.where((e) {
      final now = DateTime.now();
      return e.spentAt.month == now.month && e.spentAt.year == now.year;
    }).length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GradientGlassContainer(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      'IDR ${_formatAmount(total)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    'This Month',
                    '$thisMonth transactions',
                    Icons.calendar_today_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStat(
                    'Average',
                    'IDR ${_formatAmount(expenses.isEmpty ? 0 : total / expenses.length)}',
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

  Widget _buildMiniStat(String label, String value, IconData icon) {
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

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Stream<QuerySnapshot> _getExpensesStream(String userId) {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses');

    if (_filter.dateRange != null) {
      query = query
          .where(
            'spentAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
              _filter.dateRange!.start,
            ),
          )
          .where(
            'spentAt',
            isLessThanOrEqualTo: Timestamp.fromDate(_filter.dateRange!.end),
          );
    }

    return query.orderBy('spentAt', descending: true).snapshots();
  }

  List<Expense> _applyFilters(List<Expense> expenses) {
    return expenses.where((expense) {
      if (_filter.currencyFilter != null &&
          expense.currency != _filter.currencyFilter) {
        return false;
      }

      if (_filter.selectedSpentTypes.isNotEmpty &&
          !_filter.selectedSpentTypes.contains(expense.spentType)) {
        return false;
      }

      if (_filter.selectedPaymentSources.isNotEmpty &&
          !_filter.selectedPaymentSources.contains(expense.paymentSource)) {
        return false;
      }

      if (_filter.showOnlyFlagged && expense.aiConfidence != 'low') {
        return false;
      }

      return true;
    }).toList();
  }

  List<Expense> _applySorting(List<Expense> expenses) {
    expenses.sort((a, b) {
      int comparison;

      switch (_sort.field) {
        case SortField.spentAt:
          comparison = a.spentAt.compareTo(b.spentAt);
          break;
        case SortField.value:
          comparison = a.value.compareTo(b.value);
          break;
        case SortField.spentPlace:
          comparison = a.spentPlace.compareTo(b.spentPlace);
          break;
        case SortField.spentType:
          comparison = a.spentType.compareTo(b.spentType);
          break;
        case SortField.paymentSource:
          comparison = a.paymentSource.compareTo(b.paymentSource);
          break;
      }

      return _sort.direction == SortDirection.ascending
          ? comparison
          : -comparison;
    });

    return expenses;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filter = ExpenseFilter();
                });
                Navigator.pop(context);
              },
              child: const Text('Clear Filters'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Date'),
              onTap: () {
                setState(() {
                  _sort = ExpenseSort(
                    SortField.spentAt,
                    SortDirection.descending,
                  );
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Amount'),
              onTap: () {
                setState(() {
                  _sort = ExpenseSort(
                    SortField.value,
                    SortDirection.descending,
                  );
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.spentPlace),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${expense.currency} ${expense.value}'),
            Text('Description: ${expense.desc}'),
            Text('Category: ${expense.spentType}'),
            Text('Payment: ${expense.paymentSource}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              'Start tracking your expenses by tapping the + button',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: GlassContainer(
        margin: EdgeInsets.all(40),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
