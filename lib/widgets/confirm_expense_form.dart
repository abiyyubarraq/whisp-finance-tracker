import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/auth_provider.dart';
import '../models/expense.dart';
import '../models/expense_data.dart';
import '../services/budget_service.dart';
import '../widgets/glass_container.dart';
import '../config/theme.dart';

class ConfirmExpenseForm extends ConsumerStatefulWidget {
  final ExpenseData initialData;
  final File? imageFile;
  final Function(Expense) onSave;
  final VoidCallback onCancel;

  const ConfirmExpenseForm({
    super.key,
    required this.initialData,
    this.imageFile,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<ConfirmExpenseForm> createState() => _ConfirmExpenseFormState();
}

class _ConfirmExpenseFormState extends ConsumerState<ConfirmExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _spentPlaceController;
  late TextEditingController _descController;
  late TextEditingController _valueController;
  late DateTime _spentAt;
  late String _paymentSource;
  late String _spentType;
  String _currency = 'IDR';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _spentPlaceController = TextEditingController(
      text: widget.initialData.spentPlace,
    );
    _descController = TextEditingController(text: widget.initialData.desc);
    _valueController = TextEditingController(
      text: widget.initialData.value.toString(),
    );
    _spentAt = widget.initialData.spentAt;
    _paymentSource = widget.initialData.paymentSource;
    _spentType = widget.initialData.spentType;
  }

  @override
  void dispose() {
    _spentPlaceController.dispose();
    _descController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showFlag = widget.initialData.confidence == 'low';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFlag) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Low confidence extraction. Please review and edit.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            Text(
              'Review Expense Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: TextFormField(
                controller: _spentPlaceController,
                decoration: InputDecoration(
                  hintText: 'Place',
                  prefixIcon: Icon(Icons.store_rounded, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            SizedBox(height: 12),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Description',
                  prefixIcon: Icon(Icons.description_rounded, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GlassContainer(
                    padding: EdgeInsets.zero,
                    child: TextFormField(
                      controller: _valueController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (double.tryParse(value!) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GlassContainer(
                    padding: EdgeInsets.zero,
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: InputDecoration(
                        hintText: 'Currency',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      items: ['IDR', 'USD']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: EdgeInsets.zero,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onCancel,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                        colors: isDark
                            ? AppTheme.gradientDark
                            : AppTheme.gradientLight,
                      ),
                      borderRadius: BorderRadius.circular(16),
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
                        onTap: _isSaving ? null : _saveExpense,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: _isSaving
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 15,
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');

      String? imageUrl;

      // Upload image to Firebase Storage if present
      if (widget.imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'users/${user.uid}/receipts/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        await storageRef.putFile(widget.imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final expense = Expense(
        id: '',
        createdAt: DateTime.now(),
        spentAt: _spentAt,
        spentPlace: _spentPlaceController.text,
        desc: _descController.text,
        value: double.parse(_valueController.text),
        paymentSource: _paymentSource.isEmpty ? 'Cash' : _paymentSource,
        spentType: _spentType,
        currency: _currency,
        inputMethod: widget.imageFile != null ? 'image' : 'voice',
        imageUrl: imageUrl,
        aiConfidence: widget.initialData.confidence,
        isReviewed: true,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add(expense.toFirestore());

      // Check budget alerts
      final budgetService = BudgetService();
      await budgetService.checkBudgetAlerts(user.uid);

      widget.onSave(expense);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
