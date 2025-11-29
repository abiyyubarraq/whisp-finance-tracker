import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../models/expense.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/common/gradient_action_button.dart';
import '../widgets/common/spending_summary_card.dart';
import '../widgets/analytics/category_breakdown_card.dart';
import '../utils/date_range_helper.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    _dateRange = DateRangeHelper.getCurrentMonthRange();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Center(child: Text('Please login'));
    }

    final expensesAsync = ref.watch(expensesByDateRangeProvider(_dateRange));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ModernAppBar(
          title: 'Analytics',
          actions: [
            GradientActionButton(
              icon: Icons.person_rounded,
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSummaryCard(expenses),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CategoryBreakdownCard(expenses: expenses),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Error loading analytics: $error');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load analytics'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(expensesByDateRangeProvider(_dateRange)),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Expense> expenses) {
    final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.totalValue);
    final avgPerDay = totalSpent / _dateRange.duration.inDays.clamp(1, 999);

    return SpendingSummaryCard(
      expenses: expenses,
      dateRange: _dateRange,
      onDateRangeTap: () => _showDateRangePicker(context),
      mainIcon: Icons.account_balance_wallet_rounded,
      secondaryStatLabel: 'Avg/Day',
      secondaryStatValue: avgPerDay,
      secondaryStatIcon: Icons.trending_up_rounded,
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await DateRangeHelper.showPicker(
      context,
      initialRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }
}
