import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/expense.dart';
import '../../../widgets/glass_container.dart';
import '../../../config/theme.dart';

class ManualInputTab extends ConsumerStatefulWidget {
  const ManualInputTab({super.key});

  @override
  ConsumerState<ManualInputTab> createState() => _ManualInputTabState();
}

class _ManualInputTabState extends ConsumerState<ManualInputTab> {
  final _formKey = GlobalKey<FormState>();
  final _spentPlaceController = TextEditingController();
  final _descController = TextEditingController();
  final _valueController = TextEditingController();

  DateTime _spentAt = DateTime.now();
  String _currency = 'IDR';
  String? _selectedPaymentSource;
  String? _selectedSpentType;

  @override
  void dispose() {
    _spentPlaceController.dispose();
    _descController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Expense Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            _buildDateTimePicker(),
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
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Description (What did you buy?)',
                  prefixIcon: Icon(Icons.description_rounded, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16),
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
                        prefixIcon: Icon(Icons.money, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
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
                      items: ['IDR', 'USD'].map((currency) {
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
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('paymentSources')
                  .where('isActive', isEqualTo: true)
                  .orderBy('order')
                  .snapshots()
                  .handleError((error, stackTrace) {
                    debugPrint('Error fetching payment sources: $error');
                    debugPrint('Stack trace: $stackTrace');
                    // Re-throw to let StreamBuilder handle it
                    throw error;
                  }),
              builder: (context, snapshot) {
                // Handle error state
                if (snapshot.hasError) {
                  debugPrint(
                    'StreamBuilder error for payment sources: ${snapshot.error}',
                  );
                  return _buildErrorState('payment sources');
                }

                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final sources = snapshot.data!.docs;

                return GlassContainer(
                  padding: EdgeInsets.zero,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPaymentSource,
                    decoration: InputDecoration(
                      hintText: 'Payment Source',
                      prefixIcon: Icon(Icons.payment_rounded, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    items: sources.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['name'] as String,
                        child: Text(doc['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPaymentSource = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a payment source';
                      }
                      return null;
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('spentTypes')
                  .where('isActive', isEqualTo: true)
                  .orderBy('order')
                  .snapshots()
                  .handleError((error, stackTrace) {
                    debugPrint('Error fetching spent types: $error');
                    debugPrint('Stack trace: $stackTrace');
                    // Re-throw to let StreamBuilder handle it
                    throw error;
                  }),
              builder: (context, snapshot) {
                // Handle error state
                if (snapshot.hasError) {
                  debugPrint(
                    'StreamBuilder error for spent types: ${snapshot.error}',
                  );
                  return _buildErrorState('spent types');
                }

                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final types = snapshot.data!.docs;

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
                    items: types.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['name'] as String,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(
                                        (doc['color'] as String).substring(1),
                                        radix: 16,
                                      ) +
                                      0xFF000000,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(doc['name'] as String),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSpentType = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
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
                    color: AppTheme.primaryLight.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _saveExpense,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorType) {
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load $errorType',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _spentAt,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );

          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(_spentAt),
            );

            if (time != null) {
              setState(() {
                _spentAt = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
              });
            }
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 20),
              SizedBox(width: 12),
              Text(
                DateFormat('MMM dd, yyyy - HH:mm').format(_spentAt),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      final expense = Expense(
        id: '',
        createdAt: DateTime.now(),
        spentAt: _spentAt,
        spentPlace: _spentPlaceController.text,
        desc: _descController.text,
        value: double.parse(_valueController.text),
        paymentSource: _selectedPaymentSource!,
        spentType: _selectedSpentType!,
        currency: _currency,
        inputMethod: 'manual',
        aiConfidence: 'manual',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add(expense.toFirestore());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved successfully')),
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
    }
  }
}
