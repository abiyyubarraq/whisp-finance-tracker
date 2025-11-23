// lib/widgets/expense_list/sort_sheet.dart
import 'package:flutter/material.dart';
import '../../utils/filter_sort.dart';
import '../../widgets/glass_container.dart';
import '../../config/theme.dart';

class SortSheet extends StatefulWidget {
  final ExpenseSort currentSort;
  final Function(ExpenseSort) onApply;

  const SortSheet({
    super.key,
    required this.currentSort,
    required this.onApply,
  });

  @override
  State<SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<SortSheet> {
  late SortField _selectedField;
  late SortDirection _selectedDirection;

  @override
  void initState() {
    super.initState();
    _selectedField = widget.currentSort.field;
    _selectedDirection = widget.currentSort.direction;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.backgroundDark, AppTheme.surfaceDark]
              : [AppTheme.backgroundLight, Color(0xFFE0E7FF)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 24),
            _buildSortFields(),
            SizedBox(height: 24),
            _buildSortDirection(),
            SizedBox(height: 24),
            _buildApplyButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Sort Expenses',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildSortFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort by',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        _buildSortOption(
          'Date',
          'Sort by transaction date',
          SortField.spentAt,
          Icons.calendar_today_rounded,
        ),
        SizedBox(height: 8),
        _buildSortOption(
          'Amount',
          'Sort by total value',
          SortField.value,
          Icons.attach_money_rounded,
        ),
        SizedBox(height: 8),
        _buildSortOption(
          'Place',
          'Sort alphabetically by place',
          SortField.spentPlace,
          Icons.store_rounded,
        ),
        SizedBox(height: 8),
        _buildSortOption(
          'Category',
          'Sort by category',
          SortField.spentType,
          Icons.category_rounded,
        ),
        SizedBox(height: 8),
        _buildSortOption(
          'Payment Source',
          'Sort by payment method',
          SortField.paymentSource,
          Icons.payment_rounded,
        ),
      ],
    );
  }

  Widget _buildSortOption(
    String title,
    String subtitle,
    SortField field,
    IconData icon,
  ) {
    final isSelected = _selectedField == field;

    return GlassContainer(
      padding: EdgeInsets.zero,

      child: InkWell(
        onTap: () {
          setState(() => _selectedField = field);
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
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
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortDirection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direction',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDirectionOption(
                'Ascending',
                Icons.arrow_upward_rounded,
                SortDirection.ascending,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDirectionOption(
                'Descending',
                Icons.arrow_downward_rounded,
                SortDirection.descending,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionOption(
    String label,
    IconData icon,
    SortDirection direction,
  ) {
    final isSelected = _selectedDirection == direction;

    return GlassContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          setState(() => _selectedDirection = direction);
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onApply(ExpenseSort(_selectedField, _selectedDirection));
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
