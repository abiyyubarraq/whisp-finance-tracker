// lib/screens/expense_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../models/expense.dart';
import '../models/expense_item.dart';
import '../models/receipt_image.dart';
import '../widgets/glass_container.dart';
import '../config/theme.dart';
import '../widgets/manual_input/expense_item_form.dart';
import '../widgets/manual_input/expense_item_card.dart';
import '../widgets/manual_input/payment_source_dropdown.dart';
import '../widgets/manual_input/date_time_picker_field.dart';
import '../widgets/common/image_attachment_widget.dart';
import '../services/expense_service.dart';
import '../services/budget_service.dart';
import '../providers/user_data_provider.dart';
import '../utils/notification_helper.dart';
import '../widgets/common/confirmation_dialog.dart';

class ExpenseEditScreen extends ConsumerStatefulWidget {
  final Expense expense;

  const ExpenseEditScreen({super.key, required this.expense});

  @override
  ConsumerState<ExpenseEditScreen> createState() => _ExpenseEditScreenState();
}

class _ExpenseEditScreenState extends ConsumerState<ExpenseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _spentPlaceController;
  late TextEditingController _descController;

  late DateTime _spentAt;
  late String _currency;
  String? _selectedPaymentSource;
  late List<ExpenseItem> _items;
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _hasChanges = false;

  // Multiple image handling
  List<XFile> _newImageFiles = [];
  List<ReceiptImage> _currentReceiptImages = [];
  final List<ReceiptImage> _imagesToRemove = [];

  @override
  void initState() {
    super.initState();
    _initializeFromExpense();
  }

  void _initializeFromExpense() {
    _spentPlaceController = TextEditingController(
      text: widget.expense.spentPlace,
    );
    _descController = TextEditingController(text: widget.expense.desc ?? '');
    _spentAt = widget.expense.spentAt;
    _currency = widget.expense.currency;
    _selectedPaymentSource = widget.expense.paymentSource;
    _items = List<ExpenseItem>.from(widget.expense.items);
    _currentReceiptImages = List<ReceiptImage>.from(
      widget.expense.receiptImages,
    );
  }

  @override
  void dispose() {
    _spentPlaceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppTheme.backgroundDark, AppTheme.surfaceDark]
                  : [AppTheme.backgroundLight, Color(0xFFE0E7FF)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
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
                          _buildImageAttachment(),
                          SizedBox(height: 24),
                          _buildItemsSection(),
                          SizedBox(height: 24),
                          _buildTotalSummary(),
                          SizedBox(height: 24),
                          _buildMetadata(),
                          SizedBox(height: 32),
                          _buildActionButtons(isDark),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _confirmDiscard();
                if (shouldPop == true && context.mounted) {
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Edit Expense',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Expense Details',
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
    final paymentSourcesAsync = ref.watch(paymentSourcesProvider(false));

    return paymentSourcesAsync.when(
      data: (sources) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateTimePickerField(
              selectedDateTime: _spentAt,
              onDateTimeChanged: (dateTime) {
                setState(() => _spentAt = dateTime);
                _markAsChanged();
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
                onChanged: (_) => _markAsChanged(),
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
                onChanged: (_) => _markAsChanged(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PaymentSourceDropdown(
                    selectedPaymentSource: _selectedPaymentSource,
                    sources: sources,
                    onChanged: (value) {
                      setState(() => _selectedPaymentSource = value);
                      _markAsChanged();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    padding: EdgeInsets.zero,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _currency,
                      decoration: InputDecoration(
                        hintText: 'Currency',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      items: ['IDR', 'USD', 'EUR', 'GBP', 'JPY'].map((
                        currency,
                      ) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _currency = value!);
                        _markAsChanged();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => GlassContainer(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => GlassContainer(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Failed to load payment sources',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageAttachment() {
    // Filter out images marked for removal
    final displayedReceiptImages = _currentReceiptImages
        .where((receiptImage) => !_imagesToRemove.contains(receiptImage))
        .toList();

    return ImageAttachmentWidget(
      selectedFiles: _newImageFiles,
      receiptImages: displayedReceiptImages,
      isLoading: _isLoading,
      onImagesSelected: (files) {
        setState(() => _newImageFiles = [..._newImageFiles, ...files]);
        _markAsChanged();
      },
      onLocalFileRemoved: (index) {
        setState(() => _newImageFiles.removeAt(index));
        _markAsChanged();
      },
      onUploadedImageRemoved: (receiptImage) {
        setState(() => _imagesToRemove.add(receiptImage));
        _markAsChanged();
      },
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
                    'Tap "Add Item" to add items',
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
                  onDelete: () => _confirmDeleteItem(index),
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
              NumberFormat.currency(
                symbol: _currency,
                decimalDigits: 0,
              ).format(totalTax),
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

  Widget _buildMetadata() {
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metadata',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.input_rounded,
            'Input Method',
            widget.expense.inputMethod,
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.psychology_rounded,
            'AI Confidence',
            widget.expense.aiConfidence,
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Created',
            DateFormat('MMM dd, yyyy • HH:mm').format(widget.expense.createdAt),
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            widget.expense.isReviewed
                ? Icons.check_circle_rounded
                : Icons.pending_rounded,
            'Status',
            widget.expense.isReviewed ? 'Reviewed' : 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Save Button
        Container(
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
                        'Save Changes',
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
        SizedBox(height: 12),
        // Delete Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isDeleting ? null : _deleteExpense,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: _isDeleting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete Expense',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
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
          _markAsChanged();
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
          _markAsChanged();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDeleteItem(int index) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Item',
      message: 'Are you sure you want to delete this item?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      setState(() => _items.removeAt(index));
      _markAsChanged();
    }
  }

  Future<bool?> _confirmDiscard() async {
    return showConfirmationDialog(
      context: context,
      title: 'Discard Changes',
      message:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmText: 'Discard',
      isDestructive: true,
      icon: Icons.warning_rounded,
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      NotificationHelper.showWarning(context, 'Please add at least one item');
      return;
    }

    if (_selectedPaymentSource == null) {
      NotificationHelper.showWarning(context, 'Please select a payment source');
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      setState(() => _isLoading = false);
      NotificationHelper.showError(context, 'User not authenticated');
      return;
    }

    try {
      final expenseService = ExpenseService();

      // Start with existing images (minus ones marked for removal)
      List<ReceiptImage> finalReceiptImages = _currentReceiptImages
          .where((receiptImage) => !_imagesToRemove.contains(receiptImage))
          .toList();

      // Delete images marked for removal from storage
      for (final receiptImage in _imagesToRemove) {
        await expenseService.deleteReceiptImage(receiptImage.path);
      }

      // Upload new images
      for (final file in _newImageFiles) {
        final result = await expenseService.uploadReceiptImage(user.uid, file);
        finalReceiptImages.add(
          ReceiptImage(
            path: result['path']!, // Firebase Storage path (not blob URL)
            url: result['url']!, // Download URL
          ),
        );
      }

      final updatedExpense = widget.expense.copyWith(
        spentAt: _spentAt,
        spentPlace: _spentPlaceController.text.trim(),
        desc: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        items: _items,
        totalValue: Expense.calculateTotalValue(_items),
        paymentSource: _selectedPaymentSource,
        currency: _currency,
        receiptImages: finalReceiptImages,
        isReviewed: true,
      );

      await expenseService.updateExpense(user.uid, updatedExpense);

      // Check budget alerts
      final budgetService = BudgetService();
      await budgetService.checkBudgetAlerts(user.uid);

      if (mounted) {
        Navigator.pop(context, true);
        NotificationHelper.showSuccess(context, 'Expense updated successfully');
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(context, 'Failed to update expense: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteExpense() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Expense',
      message:
          'Are you sure you want to delete this expense? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      setState(() => _isDeleting = false);
      if (mounted) {
        NotificationHelper.showError(context, 'User not authenticated');
      }
      return;
    }

    try {
      final expenseService = ExpenseService();

      // Delete all associated images from storage
      for (final receiptImage in widget.expense.receiptImages) {
        await expenseService.deleteReceiptImage(receiptImage.path);
      }

      await expenseService.deleteExpense(user.uid, widget.expense.id);

      if (mounted) {
        Navigator.pop(context, true);
        NotificationHelper.showSuccess(context, 'Expense deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(context, 'Failed to delete expense: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}
