// lib/screens/input_tabs/manual_input_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/expense.dart';
import '../../models/expense_item.dart';
import '../../widgets/glass_container.dart';
import '../../config/theme.dart';
import '../../widgets/manual_input/expense_item_form.dart';
import '../../widgets/manual_input/expense_item_card.dart';
import '../../widgets/manual_input/payment_source_dropdown.dart';
import '../../widgets/manual_input/date_time_picker_field.dart';
import '../../services/budget_service.dart';

class ManualInputTab extends ConsumerStatefulWidget {
  const ManualInputTab({super.key});

  @override
  ConsumerState<ManualInputTab> createState() => _ManualInputTabState();
}

class _ManualInputTabState extends ConsumerState<ManualInputTab> {
  final _formKey = GlobalKey<FormState>();
  final _spentPlaceController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _spentAt = DateTime.now();
  String _currency = 'IDR';
  String? _selectedPaymentSource;
  List<ExpenseItem> _items = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _spentPlaceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24),
            _buildBasicInfo(),
            SizedBox(height: 24),
            _buildItemsSection(),
            SizedBox(height: 24),
            _buildTotalSummary(),
            SizedBox(height: 32),
            _buildSaveButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Enter Expense Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (_items.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_items.length} ${_items.length == 1 ? 'item' : 'items'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateTimePickerField(
          selectedDateTime: _spentAt,
          onDateTimeChanged: (dateTime) {
            setState(() => _spentAt = dateTime);
          },
        ),
        SizedBox(height: 16),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: TextFormField(
            controller: _spentPlaceController,
            decoration: InputDecoration(
              hintText: 'Place/Vendor (e.g., Starbucks, Walmart)',
              prefixIcon: Icon(Icons.store_rounded, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a place';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 16),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: TextFormField(
            controller: _descController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Transaction description (optional)',
              prefixIcon: Icon(Icons.description_rounded, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: PaymentSourceDropdown(
                selectedPaymentSource: _selectedPaymentSource,
                onChanged: (value) {
                  setState(() => _selectedPaymentSource = value);
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GlassContainer(
                padding: EdgeInsets.zero,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _currency,
                  decoration: InputDecoration(
                    hintText: 'Currency',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  items: ['IDR', 'USD', 'EUR', 'GBP', 'JPY'].map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _currency = value!);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _showAddItemDialog,
              icon: Icon(Icons.add_rounded, size: 18),
              label: Text('Add Item'),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (_items.isEmpty)
          GlassContainer(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No items added yet',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap "Add Item" to start',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ExpenseItemCard(
                  item: item,
                  currency: _currency,
                  onEdit: () => _showEditItemDialog(index, item),
                  onDelete: () => _deleteItem(index),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTotalSummary() {
    final totalValue = Expense.calculateTotalValue(_items);
    final totalQuantity = _items.fold(0, (sum, item) => sum + item.quantity);
    final totalTax = _items.fold(0.0, (sum, item) => sum + (item.tax ?? 0));

    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryRow('Items', '${_items.length}'),
          SizedBox(height: 8),
          _buildSummaryRow('Quantity', '$totalQuantity'),
          if (totalTax > 0) ...[
            SizedBox(height: 8),
            _buildSummaryRow(
              'Tax',
              '${NumberFormat.currency(symbol: _currency, decimalDigits: 0).format(totalTax)}',
            ),
          ],
          Divider(height: 24),
          _buildSummaryRow(
            'Total',
            NumberFormat.currency(
              symbol: _currency,
              decimalDigits: 0,
            ).format(totalValue),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? null
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveExpense,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Save Expense',
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

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseItemForm(
        onSave: (item) {
          setState(() => _items.add(item));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditItemDialog(int index, ExpenseItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseItemForm(
        item: item,
        onSave: (updatedItem) {
          setState(() => _items[index] = updatedItem);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _items.removeAt(index));
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPaymentSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a payment source'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final expense = Expense(
        id: '',
        createdAt: DateTime.now(),
        spentAt: _spentAt,
        spentPlace: _spentPlaceController.text.trim(),
        desc: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        items: _items,
        totalValue: Expense.calculateTotalValue(_items),
        paymentSource: _selectedPaymentSource!,
        currency: _currency,
        inputMethod: 'manual',
        aiConfidence: 'manual',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add(expense.toFirestore());

      // Check budget alerts
      final budgetService = BudgetService();
      await budgetService.checkBudgetAlerts(user.uid);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
