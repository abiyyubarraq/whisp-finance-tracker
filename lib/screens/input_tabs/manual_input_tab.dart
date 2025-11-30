// lib/screens/input_tabs/manual_input_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../models/expense.dart';
import '../../models/expense_item.dart';
import '../../models/receipt_image.dart';
import '../../widgets/glass_container.dart';
import '../../config/theme.dart';
import '../../widgets/manual_input/expense_item_form.dart';
import '../../widgets/manual_input/expense_item_card.dart';
import '../../widgets/manual_input/payment_source_field.dart';
import '../../widgets/manual_input/place_name_field.dart';
import '../../widgets/manual_input/date_time_picker_field.dart';
import '../../widgets/common/image_attachment_widget.dart';
import '../../services/budget_service.dart';
import '../../services/expense_service.dart';
import '../../services/payment_source_service.dart';
import '../../services/place_name_service.dart';
import '../../services/spent_type_service.dart';
import '../../services/item_name_service.dart';
import '../../providers/user_data_provider.dart';
import '../../utils/notification_helper.dart';
import '../../utils/constants.dart';

/// Helper class for tracking pending new items to be added
class _PendingNewItem {
  final String name;
  final String? color;
  final String? icon;

  _PendingNewItem({required this.name, this.color, this.icon});
}

class ManualInputTab extends ConsumerStatefulWidget {
  const ManualInputTab({super.key});

  @override
  ConsumerState<ManualInputTab> createState() => _ManualInputTabState();
}

class _ManualInputTabState extends ConsumerState<ManualInputTab> {
  final _formKey = GlobalKey<FormState>();
  final _spentPlaceController = TextEditingController();
  final _descController = TextEditingController();
  final _paymentSourceController = TextEditingController();

  DateTime _spentAt = DateTime.now();
  String _currency = 'IDR';
  final List<ExpenseItem> _items = [];
  bool _isLoading = false;
  bool _hasSetDefaultPaymentSource = false;
  List<XFile> _selectedImageFiles = [];

  // Flags for tracking new items to be auto-added
  bool _isShouldAddPaymentSource = false;
  bool _isShouldAddPlaceName = false;

  // Pending new items from expense items
  final List<_PendingNewItem> _pendingNewSpentTypes = [];
  final List<_PendingNewItem> _pendingNewItemNames = [];

  @override
  void initState() {
    super.initState();
    _hasSetDefaultPaymentSource = _paymentSourceController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _spentPlaceController.dispose();
    _descController.dispose();
    _paymentSourceController.dispose();
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
            _buildImageAttachment(),
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
    final paymentSourcesAsync = ref.watch(paymentSourcesProvider(false));
    final placeNamesAsync = ref.watch(placeNamesProvider(false));

    // Set default payment source
    paymentSourcesAsync.whenData((sources) {
      if (!_hasSetDefaultPaymentSource &&
          _paymentSourceController.text.isEmpty &&
          sources.isNotEmpty &&
          mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _paymentSourceController.text.isEmpty) {
            // Find default payment source, or use first if none is default
            final defaultSource = sources.firstWhere(
              (s) => s.isDefault,
              orElse: () => sources.first,
            );
            setState(() {
              _hasSetDefaultPaymentSource = true;
              _paymentSourceController.text = defaultSource.name;
            });
          }
        });
      }
    });

    return paymentSourcesAsync.when(
      data: (sources) {
        return placeNamesAsync.when(
          data: (placeNames) {
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
                PlaceNameField(
                  controller: _spentPlaceController,
                  placeNames: placeNames,
                  onIsNewChanged: (isNew) {
                    setState(() => _isShouldAddPlaceName = isNew);
                  },
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
                      child: PaymentSourceField(
                        controller: _paymentSourceController,
                        sources: sources,
                        onIsNewChanged: (isNew) {
                          setState(() => _isShouldAddPaymentSource = isNew);
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
                          items: currencyOptions.map((currency) {
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
          },
          loading: () => _buildLoadingPlaceholder(),
          error: (error, stack) {
            debugPrint('Error loading payment sources: $error');

            return _buildErrorPlaceholder('Failed to load payment sources');
          },
        );
      },
      loading: () => _buildLoadingPlaceholder(),
      error: (error, stack) {
        debugPrint('Error loading payment sources: $error');
        return _buildErrorPlaceholder('Failed to load payment sources');
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String message) {
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text(message, style: TextStyle(fontSize: 12, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildImageAttachment() {
    return ImageAttachmentWidget(
      selectedFiles: _selectedImageFiles,
      receiptImages: const [], // No uploaded images yet for new expense
      isLoading: _isLoading,
      onImagesSelected: (files) {
        setState(
          () => _selectedImageFiles = [..._selectedImageFiles, ...files],
        );
      },
      onLocalFileRemoved: (index) {
        setState(() => _selectedImageFiles.removeAt(index));
      },
      onUploadedImageRemoved: (_) {
        // No uploaded images to remove for new expense
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
        onSave: (result) {
          setState(() {
            _items.add(result.item);

            // Track pending new spent type
            if (result.isShouldAddSpentType &&
                result.newSpentTypeName != null) {
              // Check if not already pending
              final alreadyPending = _pendingNewSpentTypes.any(
                (p) =>
                    p.name.toLowerCase() ==
                    result.newSpentTypeName!.toLowerCase(),
              );
              if (!alreadyPending) {
                _pendingNewSpentTypes.add(
                  _PendingNewItem(
                    name: result.newSpentTypeName!,
                    color: '#6B7280',
                    icon: 'more_horiz',
                  ),
                );
              }
            }

            // Track pending new item name
            if (result.isShouldAddItemName && result.newItemName != null) {
              // Check if not already pending
              final alreadyPending = _pendingNewItemNames.any(
                (p) =>
                    p.name.toLowerCase() == result.newItemName!.toLowerCase(),
              );
              if (!alreadyPending) {
                _pendingNewItemNames.add(
                  _PendingNewItem(name: result.newItemName!),
                );
              }
            }
          });
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
        onSave: (result) {
          setState(() {
            _items[index] = result.item;

            // Track pending new spent type
            if (result.isShouldAddSpentType &&
                result.newSpentTypeName != null) {
              final alreadyPending = _pendingNewSpentTypes.any(
                (p) =>
                    p.name.toLowerCase() ==
                    result.newSpentTypeName!.toLowerCase(),
              );
              if (!alreadyPending) {
                _pendingNewSpentTypes.add(
                  _PendingNewItem(
                    name: result.newSpentTypeName!,
                    color: '#6B7280',
                    icon: 'more_horiz',
                  ),
                );
              }
            }

            // Track pending new item name
            if (result.isShouldAddItemName && result.newItemName != null) {
              final alreadyPending = _pendingNewItemNames.any(
                (p) =>
                    p.name.toLowerCase() == result.newItemName!.toLowerCase(),
              );
              if (!alreadyPending) {
                _pendingNewItemNames.add(
                  _PendingNewItem(name: result.newItemName!),
                );
              }
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _spentPlaceController.clear();
      _descController.clear();
      _paymentSourceController.clear();
      _spentAt = DateTime.now();
      _currency = 'IDR';
      _items.clear();
      _hasSetDefaultPaymentSource = false;
      _selectedImageFiles = [];
      _isShouldAddPaymentSource = false;
      _isShouldAddPlaceName = false;
      _pendingNewSpentTypes.clear();
      _pendingNewItemNames.clear();
    });
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
      NotificationHelper.showWarning(context, 'Please add at least one item');
      return;
    }

    final paymentSource = _paymentSourceController.text.trim();
    if (paymentSource.isEmpty) {
      NotificationHelper.showWarning(context, 'Please enter a payment source');
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Auto-add new payment source if needed
      if (_isShouldAddPaymentSource && paymentSource.isNotEmpty) {
        await PaymentSourceService.addSilent(user.uid, paymentSource);
      }

      // Auto-add new place name if needed
      final placeName = _spentPlaceController.text.trim();
      if (_isShouldAddPlaceName && placeName.isNotEmpty) {
        await PlaceNameService.addSilent(user.uid, placeName);
      }

      // Auto-add pending new spent types
      for (final pending in _pendingNewSpentTypes) {
        await SpentTypeService.addSilent(
          user.uid,
          pending.name,
          color: pending.color ?? '#6B7280',
          icon: pending.icon ?? 'more_horiz',
        );
      }

      // Auto-add pending new item names
      for (final pending in _pendingNewItemNames) {
        await ItemNameService.addSilent(user.uid, pending.name);
      }

      // Upload all selected images
      List<ReceiptImage> receiptImages = [];
      if (_selectedImageFiles.isNotEmpty) {
        final expenseService = ExpenseService();
        for (final file in _selectedImageFiles) {
          final result = await expenseService.uploadReceiptImage(
            user.uid,
            file,
          );
          receiptImages.add(
            ReceiptImage(path: result['path']!, url: result['url']!),
          );
        }
      }

      final expense = Expense(
        id: '',
        createdAt: DateTime.now(),
        spentAt: _spentAt,
        spentPlace: placeName,
        desc: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        items: _items,
        totalValue: Expense.calculateTotalValue(_items),
        paymentSource: paymentSource,
        currency: _currency,
        inputMethod: 'manual',
        receiptImages: receiptImages,
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
        _resetForm();
        Navigator.pop(context);
        NotificationHelper.showSuccess(context, 'Expense saved successfully');
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(context, 'Failed to save expense: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
