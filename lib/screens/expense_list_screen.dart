// lib/screens/expense_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_list/expense_card.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/common/gradient_action_button.dart';
import '../utils/filter_sort.dart';
import '../utils/date_range_helper.dart';
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
  late ExpenseFilter _filter;
  ExpenseSort _sort = ExpenseSort(SortField.spentAt, SortDirection.descending);

  @override
  void initState() {
    super.initState();
    _filter = ExpenseFilter(
      dateRange: DateRangeHelper.getCurrentMonthRange(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Center(child: Text('Please login'));
    }

    // Use the date range from filter, default to current month if null
    final dateRange = _filter.dateRange ?? DateRangeHelper.getCurrentMonthRange();
    final expensesAsync = ref.watch(expensesByDateRangeProvider(dateRange));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ModernAppBar(
          title: 'Expenses',
          actions: _buildAppBarActions(context),
        ),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          final filteredExpenses = _applyFilters(expenses);
          final sortedExpenses = _applySorting(filteredExpenses);
          return _buildExpensesList(sortedExpenses);
        },
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) {
          debugPrint('Error loading expenses: $error');
          return ErrorState(
            message: 'Failed to load expenses',
            onRetry: () => ref.invalidate(expensesByDateRangeProvider(dateRange)),
          );
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      SizedBox(width: 8),
      GradientActionButton(
        icon: Icons.filter_list_rounded,
        onTap: _showFilterSheet,
        hasActiveIndicator: _filter.hasActiveFilters(),
      ),
      SizedBox(width: 8),
      GradientActionButton(
        icon: Icons.sort_rounded,
        onTap: _showSortSheet,
      ),
      SizedBox(width: 8),
      GradientActionButton(
        icon: Icons.person_rounded,
        onTap: () => Navigator.pushNamed(context, '/profile'),
      ),
    ];
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
        ExpenseSummaryCard(
          expenses: expenses,
          dateRange: _filter.dateRange,
          onDateRangeSelected: (dateRange) {
            setState(() {
              _filter = ExpenseFilter(
                dateRange: dateRange,
                currencyFilter: _filter.currencyFilter,
                selectedSpentTypes: _filter.selectedSpentTypes,
                selectedPaymentSources: _filter.selectedPaymentSources,
                showOnlyFlagged: _filter.showOnlyFlagged,
                minAmount: _filter.minAmount,
                maxAmount: _filter.maxAmount,
              );
            });
          },
        ),
        SizedBox(height: 16),
        if (expenses.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final dateRange = _filter.dateRange ?? DateRangeHelper.getCurrentMonthRange();
                ref.invalidate(expensesByDateRangeProvider(dateRange));
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
          )
        else
          Expanded(
            child: EmptyState(
              icon: Icons.filter_list_off_rounded,
              title: 'No matching expenses',
              message: 'Try adjusting your filters',
            ),
          ),
      ],
    );
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
