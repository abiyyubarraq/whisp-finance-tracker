import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../models/expense.dart';
import '../widgets/glass_container.dart';
import '../widgets/modern_app_bar.dart';
import '../config/theme.dart';
import '../utils/currency_formatter.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    // Initialize with this month as default (same as expense_list_screen)
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    _dateRange = DateTimeRange(start: startOfMonth, end: endOfMonth);
  }

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
          title: 'Analytics',
          actions: [_buildProfileButton(context)],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        key: ValueKey('${_dateRange!.start}_${_dateRange!.end}'),
        stream: _getAnalyticsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data!.docs
              .map((doc) => Expense.fromFirestore(doc))
              .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSummaryCards(expenses),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCategoryBreakdown(expenses),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Expense> expenses) {
    final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.totalValue);
    final avgPerDay = totalSpent / _dateRange!.duration.inDays.clamp(1, 999);
    final dateLabel = _getDateLabel();
    final itemTotal = expenses.fold<int>(0, (sum, e) => sum + e.items.length);

    return GradientGlassContainer(
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
                    CurrencyFormatter.formatCompact(totalSpent, 'IDR'),
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
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  dateLabel,
                  '${expenses.length} transactions',
                  Icons.calendar_today_rounded,
                  'On $itemTotal items',
                  onTap: () => _showDateRangePicker(context),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  'Avg/Day',
                  CurrencyFormatter.formatCompact(avgPerDay, 'IDR'),
                  Icons.trending_up_rounded,
                  null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    String? subValue, {
    VoidCallback? onTap,
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
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: container,
        ),
      );
    }

    return container;
  }

  String _getDateLabel() {
    if (_dateRange == null) {
      return 'All Time';
    }
    // Format custom date range
    final startStr = _formatDate(_dateRange!.start);
    final endStr = _formatDate(_dateRange!.end);
    return '$startStr - $endStr';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    try {
      final now = DateTime.now();
      final lastDate = DateTime(now.year, now.month, now.day);

      // Clamp the existing date range to ensure it's within valid bounds
      final clampedStart = _dateRange!.start.isBefore(DateTime(2020))
          ? DateTime(2020)
          : (_dateRange!.start.isAfter(lastDate)
                ? lastDate
                : _dateRange!.start);
      final clampedEnd = _dateRange!.end.isAfter(lastDate)
          ? lastDate
          : (_dateRange!.end.isBefore(clampedStart)
                ? clampedStart
                : _dateRange!.end);
      final initialRange = DateTimeRange(start: clampedStart, end: clampedEnd);

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
        setState(() {
          // Ensure end date includes the full day (23:59:59)
          final endDate = DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          );
          _dateRange = DateTimeRange(start: picked.start, end: endDate);
        });
      }
    } catch (e) {
      debugPrint('Error showing date range picker: $e');
    }
  }

  Widget _buildCategoryBreakdown(List<Expense> expenses) {
    final categoryTotals = <String, double>{};

    for (var expense in expenses) {
      for (var item in expense.items) {
        categoryTotals[item.spentType] =
            (categoryTotals[item.spentType] ?? 0) + item.value;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? AppTheme.gradientDark
                        : AppTheme.gradientLight,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ...categoryTotals.entries.map((entry) {
            final total = categoryTotals.values.fold<double>(
              0,
              (a, b) => a + b,
            );
            final percentage = (entry.value / total * 100);

            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatCompact(entry.value, 'IDR'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage / 100,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? AppTheme.gradientDark
                                  : AppTheme.gradientLight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
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
          }),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getAnalyticsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .where(
          'spentAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(_dateRange!.start),
        )
        .where(
          'spentAt',
          isLessThanOrEqualTo: Timestamp.fromDate(_dateRange!.end),
        )
        .snapshots();
  }

  Widget _buildProfileButton(BuildContext context) {
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
          onTap: () => Navigator.pushNamed(context, '/profile'),
          borderRadius: BorderRadius.circular(12),
          child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
