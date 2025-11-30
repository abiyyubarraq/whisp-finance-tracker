// lib/widgets/manual_input/expense_item_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense_item.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/glass_container.dart';
import '../../config/theme.dart';
import '../../utils/input_helper.dart';

class ExpenseItemForm extends ConsumerStatefulWidget {
  final ExpenseItem? item;
  final Function(ExpenseItem) onSave;

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

  String? _selectedSpentType;
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
    _selectedSpentType = widget.item?.spentType;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _taxController.dispose();
    _descController.dispose();
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
              GlassContainer(
                padding: EdgeInsets.zero,
                child: TextFormField(
                  controller: _itemNameController,
                  decoration: InputDecoration(
                    hintText: 'Item name (e.g., Coffee, Notebook)',
                    prefixIcon: Icon(Icons.shopping_bag_rounded, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              _buildSpentTypeDropdown(),
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
                builder: (context, _, _) => ValueListenableBuilder(
                  valueListenable: _quantityController,
                  builder: (context, _, _) => ValueListenableBuilder(
                    valueListenable: _taxController,
                    builder: (context, _, _) => _buildCalculatedTotal(),
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

  Widget _buildSpentTypeDropdown() {
    final spentTypesAsync = ref.watch(spentTypesProvider(false));

    spentTypesAsync.whenData((types) {
      if (!_hasSetDefaultSpentType &&
          _selectedSpentType == null &&
          types.isNotEmpty &&
          mounted) {
        setState(() {
          _hasSetDefaultSpentType = true;
          _selectedSpentType = types.first.name;
        });
      }
    });

    ref.listen(spentTypesProvider(false), (previous, next) {
      next.whenData((types) {
        if (!_hasSetDefaultSpentType &&
            _selectedSpentType == null &&
            types.isNotEmpty &&
            mounted) {
          setState(() {
            _hasSetDefaultSpentType = true;
            _selectedSpentType = types.first.name;
          });
        }
      });
    });

    return spentTypesAsync.when(
      data: (types) {
        if (types.isEmpty) {
          return GlassContainer(
            padding: EdgeInsets.all(16),
            child: Text('No categories available'),
          );
        }

        return GlassContainer(
          padding: EdgeInsets.zero,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedSpentType,
            decoration: InputDecoration(
              hintText: 'Category',
              prefixIcon: Icon(Icons.category_rounded, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            items: types.map((type) {
              final colorString = type.color;
              final color = Color(
                int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
              );

              return DropdownMenuItem<String>(
                value: type.name,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(type.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedSpentType = value);
            },
            validator: (value) {
              if (value == null) return 'Please select a category';
              return null;
            },
          ),
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
              widget.item == null ? 'Add Item' : 'Save Changes',
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

    final cost = double.parse(_costController.text);
    final quantity = int.parse(_quantityController.text);
    final tax = _taxController.text.isEmpty
        ? null
        : double.parse(_taxController.text);

    final item = ExpenseItem(
      itemName: _itemNameController.text.trim(),
      spentType: _selectedSpentType!,
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

    widget.onSave(item);
  }
}
