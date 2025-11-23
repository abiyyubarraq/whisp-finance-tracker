// lib/screens/expense_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_list/expense_card.dart';
import '../widgets/modern_app_bar.dart';
import '../config/theme.dart';
import '../utils/filter_sort.dart';
import '../widgets/expense_list/expense_summary_card.dart';
import '../widgets/expense_list/sort_sheet.dart';
import '../widgets/expense_list/expense_details_dialog.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/expense_list/filter_sheet.dart';

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
          actions: _buildAppBarActions(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getExpensesStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            debugPrint('StreamBuilder error for expenses: ${snapshot.error}');
            return ErrorState(
              message: 'Failed to load expenses',
              onRetry: () => setState(() {}),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No expenses yet',
              message: 'Start tracking your expenses by tapping the + button',
            );
          }

          final expenses = snapshot.data!.docs
              .map((doc) => Expense.fromFirestore(doc))
              .toList();

          final filteredExpenses = _applyFilters(expenses);
          final sortedExpenses = _applySorting(filteredExpenses);

          if (sortedExpenses.isEmpty) {
            return EmptyState(
              icon: Icons.filter_list_off_rounded,
              title: 'No matching expenses',
              message: 'Try adjusting your filters',
              action: TextButton(
                onPressed: () {
                  setState(() => _filter = ExpenseFilter());
                },
                child: Text('Clear Filters'),
              ),
            );
          }

          return _buildExpensesList(sortedExpenses);
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      SizedBox(width: 8),
      _buildActionButton(
        context,
        icon: Icons.filter_list_rounded,
        onTap: _showFilterSheet,
        hasActiveFilter: _filter.hasActiveFilters(),
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
    ];
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool hasActiveFilter = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
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
        ),
        if (hasActiveFilter)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    return Column(
      children: [
        ExpenseSummaryCard(expenses: expenses),
        SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 100),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return ExpenseCard(
                  expense: expenses[index],
                  onTap: () => _showExpenseDetails(expenses[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
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

      if (_filter.selectedSpentTypes.isNotEmpty) {
        final expenseSpentTypes = expense.items
            .map((item) => item.spentType)
            .toSet();
        if (!expenseSpentTypes.any(
          (type) => _filter.selectedSpentTypes.contains(type),
        )) {
          return false;
        }
      }

      if (_filter.selectedPaymentSources.isNotEmpty &&
          !_filter.selectedPaymentSources.contains(expense.paymentSource)) {
        return false;
      }

      if (_filter.showOnlyFlagged && expense.aiConfidence != 'low') {
        return false;
      }

      if (_filter.minAmount != null &&
          expense.totalValue < _filter.minAmount!) {
        return false;
      }

      if (_filter.maxAmount != null &&
          expense.totalValue > _filter.maxAmount!) {
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
          comparison = a.totalValue.compareTo(b.totalValue);
          break;
        case SortField.spentPlace:
          comparison = a.spentPlace.compareTo(b.spentPlace);
          break;
        case SortField.spentType:
          final aTypes = a.items.map((item) => item.spentType).join(',');
          final bTypes = b.items.map((item) => item.spentType).join(',');
          comparison = aTypes.compareTo(bTypes);
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
      builder: (context) => FilterSheet(
        currentFilter: _filter,
        onApply: (newFilter) {
          setState(() => _filter = newFilter);
          Navigator.pop(context);
        },
        onClear: () {
          setState(() => _filter = ExpenseFilter());
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortSheet(
        currentSort: _sort,
        onApply: (newSort) {
          setState(() => _sort = newSort);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => ExpenseDetailsDialog(expense: expense),
    );
  }
}
