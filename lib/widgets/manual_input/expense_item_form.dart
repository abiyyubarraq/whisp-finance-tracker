// lib/widgets/manual_input/expense_item_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense_item.dart';
import '../../models/item_name.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/glass_container.dart';
import '../../config/theme.dart';
import '../../utils/input_helper.dart';
import 'spent_type_field.dart';
import 'item_name_field.dart';

/// Result class containing the expense item and flags for new items
class ExpenseItemFormResult {
  final ExpenseItem item;
  final bool isShouldAddSpentType;
  final bool isShouldAddItemName;
  final String? newSpentTypeName;
  final String? newItemName;

  ExpenseItemFormResult({
    required this.item,
    this.isShouldAddSpentType = false,
    this.isShouldAddItemName = false,
    this.newSpentTypeName,
    this.newItemName,
  });
}

class ExpenseItemForm extends ConsumerStatefulWidget {
  final ExpenseItem? item;
  final Function(ExpenseItemFormResult) onSave;

  const ExpenseItemForm({super.key, this.item, required this.onSave});

  @override
  ConsumerState<ExpenseItemForm> createState() => _ExpenseItemFormState();
}

class _ExpenseItemFormState extends ConsumerState<ExpenseItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _itemNameController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  late TextEditingController _taxController;
  late TextEditingController _descController;
  late TextEditingController _spentTypeController;

  bool _isShouldAddSpentType = false;
  bool _isShouldAddItemName = false;
  bool _hasSetDefaultSpentType = false;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(
      text: widget.item?.itemName ?? '',
    );
    _costController = TextEditingController(
      text: widget.item?.cost.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '1',
    );
    _taxController = TextEditingController(
      text: widget.item?.tax?.toString() ?? '',
    );
    _descController = TextEditingController(text: widget.item?.descItem ?? '');
    _spentTypeController = TextEditingController(
      text: widget.item?.spentType ?? '',
    );
    _hasSetDefaultSpentType = widget.item?.spentType.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _taxController.dispose();
    _descController.dispose();
    _spentTypeController.dispose();
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.item == null ? 'Add Item' : 'Edit Item',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildItemNameField(),
              SizedBox(height: 16),
              _buildSpentTypeField(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      padding: EdgeInsets.zero,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Qty',
                          prefixIcon: Icon(Icons.numbers_rounded, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlassContainer(
                      padding: EdgeInsets.zero,
                      child: TextFormField(
                        controller: _costController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [ThousandMultiplierFormatter()],
                        decoration: InputDecoration(
                          hintText: 'Cost per unit',
                          prefixIcon: Icon(Icons.onetwothree_rounded, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter cost';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              GlassContainer(
                padding: EdgeInsets.zero,
                child: TextFormField(
                  controller: _taxController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [ThousandMultiplierFormatter()],
                  decoration: InputDecoration(
                    hintText: 'Tax (optional)',
                    prefixIcon: Icon(Icons.receipt_rounded, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Invalid tax amount';
                      }
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
                    hintText: 'Item description (optional)',
                    prefixIcon: Icon(Icons.notes_rounded, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: _costController,
                builder: (context, costValue, child) => ValueListenableBuilder(
                  valueListenable: _quantityController,
                  builder: (context, quantityValue, child) => ValueListenableBuilder(
                    valueListenable: _taxController,
                    builder: (context, taxValue, child) => _buildCalculatedTotal(),
                  ),
                ),
              ),
              SizedBox(height: 24),
              _buildSaveButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemNameField() {
    final itemNamesAsync = ref.watch(itemNamesProvider(false));

    return itemNamesAsync.when(
      data: (itemNames) {
        return ItemNameField(
          controller: _itemNameController,
          itemNames: itemNames,
          onIsNewChanged: (isNew) {
            setState(() => _isShouldAddItemName = isNew);
          },
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
      error: (error, stack) {
        debugPrint('Error loading item names: $error');
        // Fallback to simple text field
        return ItemNameField(
          controller: _itemNameController,
          itemNames: const <ItemName>[],
          onIsNewChanged: (isNew) {
            setState(() => _isShouldAddItemName = isNew);
          },
        );
      },
    );
  }

  Widget _buildSpentTypeField() {
    final spentTypesAsync = ref.watch(spentTypesProvider(false));

    // Auto-set default spent type only once on initial load
    spentTypesAsync.whenData((types) {
      if (!_hasSetDefaultSpentType &&
          _spentTypeController.text.isEmpty &&
          types.isNotEmpty &&
          mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _spentTypeController.text.isEmpty) {
            // Find default spent type, or use first if none is default
            final defaultType = types.firstWhere(
              (t) => t.isDefault,
              orElse: () => types.first,
            );
            setState(() {
              _hasSetDefaultSpentType = true;
              _spentTypeController.text = defaultType.name;
            });
          }
        });
      }
    });

    return spentTypesAsync.when(
      data: (types) {
        if (types.isEmpty) {
          return GlassContainer(
            padding: EdgeInsets.all(16),
            child: Text('No categories available'),
          );
        }

        return SpentTypeField(
          controller: _spentTypeController,
          spentTypes: types,
          onIsNewChanged: (isNew) {
            setState(() => _isShouldAddSpentType = isNew);
          },
        );
      },
      loading: () => GlassContainer(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        debugPrint('Error loading categories: $error');

        return GlassContainer(
          padding: EdgeInsets.all(16),
          child: Text('Error loading categories'),
        );
      },
    );
  }

  Widget _buildCalculatedTotal() {
    final cost = double.tryParse(_costController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final tax = double.tryParse(_taxController.text);
    final total = ExpenseItem.calculateValue(
      cost: cost,
      quantity: quantity,
      tax: tax,
    );
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            total.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _save,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              widget.item == null ? 'Add Item' : 'Save Item',
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final spentTypeName = _spentTypeController.text.trim();
    if (spentTypeName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a category')));
      return;
    }

    final cost = double.parse(_costController.text);
    final quantity = int.parse(_quantityController.text);
    final tax = _taxController.text.isEmpty
        ? null
        : double.parse(_taxController.text);

    final itemName = _itemNameController.text.trim();

    final item = ExpenseItem(
      itemName: itemName,
      spentType: spentTypeName,
      quantity: quantity,
      cost: cost,
      value: ExpenseItem.calculateValue(
        cost: cost,
        quantity: quantity,
        tax: tax,
      ),
      tax: tax,
      descItem: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
    );

    widget.onSave(
      ExpenseItemFormResult(
        item: item,
        isShouldAddSpentType: _isShouldAddSpentType,
        isShouldAddItemName: _isShouldAddItemName,
        newSpentTypeName: _isShouldAddSpentType ? spentTypeName : null,
        newItemName: _isShouldAddItemName ? itemName : null,
      ),
    );
  }
}
