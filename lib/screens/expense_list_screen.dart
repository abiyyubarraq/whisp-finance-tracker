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
import '../widgets/common/empty_state.dart';
import '../widgets/common/error_state.dart';
import '../widgets/expense_list/filter_sheet.dart';
import '../widgets/common/confirmation_dialog.dart';
import '../utils/notification_helper.dart';
import '../services/expense_service.dart';
import '../utils/test_keys.dart';
import 'expense_edit_screen.dart';

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
    _filter = ExpenseFilter(dateRange: DateRangeHelper.getCurrentMonthRange());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Center(child: Text('Please login'));
    }

    // Use the date range from filter, default to current month if null
    final dateRange =
        _filter.dateRange ?? DateRangeHelper.getCurrentMonthRange();
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
            onRetry: () =>
                ref.invalidate(expensesByDateRangeProvider(dateRange)),
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
      GradientActionButton(icon: Icons.sort_rounded, onTap: _showSortSheet),
      SizedBox(width: 8),
      GradientActionButton(
        key: TestKeys.homeProfileButton,
        icon: Icons.person_rounded,
        semanticLabel: 'Profile',
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
    // Using CustomScrollView with slivers to allow the summary card (with
    // expandable calendar) and expense list to scroll together. This prevents
    // RenderFlex overflow when the calendar expands, as the entire content
    // becomes scrollable rather than fighting for fixed space in a Column.
    return RefreshIndicator(
      onRefresh: () async {
        final dateRange =
            _filter.dateRange ?? DateRangeHelper.getCurrentMonthRange();
        ref.invalidate(expensesByDateRangeProvider(dateRange));
      },
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Summary card with expandable calendar
          SliverToBoxAdapter(
            child: ExpenseSummaryCard(
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
          ),
          // Spacing
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Expense list or empty state
          if (expenses.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return ExpenseCard(
                  expense: expenses[index],
                  onTap: () => _openExpenseEditor(expenses[index]),
                  onDelete: () => _confirmDeleteExpense(expenses[index]),
                );
              }, childCount: expenses.length),
            )
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.filter_list_off_rounded,
                title: 'No matching expenses',
                message: 'Try adjusting your filters',
              ),
            ),
          // Bottom padding for FAB clearance
          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
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
          // Compare dates only (ignore time component)
          final aDate = DateTime(a.spentAt.year, a.spentAt.month, a.spentAt.day);
          final bDate = DateTime(b.spentAt.year, b.spentAt.month, b.spentAt.day);
          comparison = aDate.compareTo(bDate);

          // Apply direction to date comparison
          comparison = _sort.direction == SortDirection.ascending
              ? comparison
              : -comparison;

          // If dates are the same, sort by value (highest first, always)
          if (comparison == 0) {
            comparison = b.totalValue.compareTo(a.totalValue);
          }

          return comparison;

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

  void _openExpenseEditor(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseEditScreen(expense: expense),
      ),
    );
  }

  Future<void> _confirmDeleteExpense(Expense expense) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Expense',
      message:
          'Are you sure you want to delete this expense? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      if (mounted) {
        NotificationHelper.showError(context, 'User not authenticated');
      }
      return;
    }

    try {
      final expenseService = ExpenseService();
      await expenseService.deleteExpense(user.uid, expense.id);

      if (mounted) {
        NotificationHelper.showSuccess(context, 'Expense deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(context, 'Failed to delete expense: $e');
      }
    }
  }
}
