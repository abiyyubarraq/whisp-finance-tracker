// lib/widgets/expense_list/filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/filter_sort.dart';
import '../../widgets/glass_container.dart';
import '../../config/theme.dart';
import '../../providers/user_data_provider.dart';

class FilterSheet extends ConsumerStatefulWidget {
  final ExpenseFilter currentFilter;
  final Function(ExpenseFilter) onApply;
  final VoidCallback onClear;

  const FilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late ExpenseFilter _filter;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = ExpenseFilter(
      dateRange: widget.currentFilter.dateRange,
      selectedSpentTypes: Set.from(widget.currentFilter.selectedSpentTypes),
      selectedPaymentSources: Set.from(
        widget.currentFilter.selectedPaymentSources,
      ),
      showOnlyFlagged: widget.currentFilter.showOnlyFlagged,
      minAmount: widget.currentFilter.minAmount,
      maxAmount: widget.currentFilter.maxAmount,
    );
    _minAmountController.text = _filter.minAmount?.toString() ?? '';
    _maxAmountController.text = _filter.maxAmount?.toString() ?? '';
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 24),
            _buildDateRangeFilter(),
            SizedBox(height: 16),
            _buildAmountFilter(),
            SizedBox(height: 16),
            _buildSpentTypesFilter(),
            SizedBox(height: 16),
            _buildPaymentSourcesFilter(),
            SizedBox(height: 16),
            _buildFlaggedFilter(),
            SizedBox(height: 24),
            _buildActionButtons(isDark),
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
          'Filter Expenses',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.date_range_rounded, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _filter.dateRange == null
                          ? 'All time'
                          : '${_formatDate(_filter.dateRange!.start)} - ${_formatDate(_filter.dateRange!.end)}',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  if (_filter.dateRange != null)
                    IconButton(
                      icon: Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        setState(() => _filter.dateRange = null);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount Range',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: EdgeInsets.zero,
                child: TextField(
                  controller: _minAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Min',
                    prefixIcon: Icon(Icons.arrow_upward_rounded, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    _filter.minAmount = double.tryParse(value);
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GlassContainer(
                padding: EdgeInsets.zero,
                child: TextField(
                  controller: _maxAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Max',
                    prefixIcon: Icon(Icons.arrow_downward_rounded, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    _filter.maxAmount = double.tryParse(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpentTypesFilter() {
    final spentTypesAsync = ref.watch(activeSpentTypesProvider);

    return spentTypesAsync.when(
      data: (types) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spent Types',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: types.map((type) {
                final name = type.name;
                final isSelected = _filter.selectedSpentTypes.contains(name);

                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filter.selectedSpentTypes.add(name);
                      } else {
                        _filter.selectedSpentTypes.remove(name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading spent types')),
    );
  }

  Widget _buildPaymentSourcesFilter() {
    final paymentSourcesAsync = ref.watch(activePaymentSourcesProvider);

    return paymentSourcesAsync.when(
      data: (sources) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Sources',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sources.map((source) {
                final name = source.name;
                final isSelected = _filter.selectedPaymentSources.contains(
                  name,
                );

                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filter.selectedPaymentSources.add(name);
                      } else {
                        _filter.selectedPaymentSources.remove(name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading payment sources')),
    );
  }

  Widget _buildFlaggedFilter() {
    return CheckboxListTile(
      title: Text('Show only flagged expenses'),
      subtitle: Text('Low AI confidence'),
      value: _filter.showOnlyFlagged,
      onChanged: (value) {
        setState(() => _filter.showOnlyFlagged = value ?? false);
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onClear,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    'Clear',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
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
                onTap: () => widget.onApply(_filter),
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
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _filter.dateRange,
    );

    if (picked != null) {
      setState(() => _filter.dateRange = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
