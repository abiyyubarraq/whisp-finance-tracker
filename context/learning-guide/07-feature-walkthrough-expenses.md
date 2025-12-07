# Module 07: Feature Walkthrough - Expenses

**Duration:** 4-5 hours | **Difficulty:** Advanced | **Prerequisites:** Modules 01-06

## 🎯 Learning Objectives

- Understand complete expense CRUD implementation
- Build manual input form with validation
- Implement image scanning with Gemini AI
- Add voice input functionality
- Create expense list with filtering
- Handle receipt image uploads

---

## Expense Model Structure

See [lib/models/expense.dart](../lib/models/expense.dart):

```dart
class Expense {
  final String? id;
  final DateTime createdAt;
  final DateTime spentAt;
  final String spentPlace;
  final List<ExpenseItem> items;
  final double totalValue;
  final String paymentSource;
  final String currency;
  final String inputMethod; // 'image', 'voice', or 'manual'
  final List<String> receiptImages;

  const Expense({
    this.id,
    required this.createdAt,
    required this.spentAt,
    required this.spentPlace,
    required this.items,
    required this.totalValue,
    required this.paymentSource,
    this.currency = 'IDR',
    this.inputMethod = 'manual',
    this.receiptImages = const [],
  });

  // Firestore serialization
  factory Expense.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

## Expense Item Model

See [lib/models/expense_item.dart](../lib/models/expense_item.dart):

```dart
class ExpenseItem {
  final String name;
  final String spentType;
  final int quantity;
  final double pricePerItem;
  final double totalPrice;

  const ExpenseItem({
    required this.name,
    required this.spentType,
    this.quantity = 1,
    required this.pricePerItem,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() { ... }
  factory ExpenseItem.fromMap(Map<String, dynamic> map) { ... }
}
```

## Manual Input Implementation

See [lib/screens/input_tabs/manual_input_tab.dart](../lib/screens/input_tabs/manual_input_tab.dart):

### Key Features

1. **Multi-item form** - Add multiple expense items
2. **Auto-calculation** - Total updates automatically
3. **Dropdown selections** - Payment sources, categories
4. **Date/time pickers** - User-friendly date selection
5. **Form validation** - Required fields, number validation

### Code Structure

```dart
class ManualInputTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<ManualInputTab> createState() => _ManualInputTabState();
}

class _ManualInputTabState extends ConsumerState<ManualInputTab> {
  // Form controllers
  final _placeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentSource = '';
  List<ExpenseItemForm> _items = [ExpenseItemForm()];

  // Calculate total
  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    // Load payment sources from Riverpod
    final paymentSourcesAsync = ref.watch(activePaymentSourcesProvider);
    final spentTypesAsync = ref.watch(activeSpentTypesProvider);

    return Form(
      child: Column(
        children: [
          // Place name field
          TextFormField(
            controller: _placeController,
            decoration: InputDecoration(labelText: 'Place'),
          ),

          // Date picker
          _buildDatePicker(),

          // Payment source dropdown
          paymentSourcesAsync.when(
            data: (sources) => DropdownButtonFormField(
              value: _selectedPaymentSource,
              items: sources.map((s) => DropdownMenuItem(
                value: s.name,
                child: Text(s.name),
              )).toList(),
              onChanged: (value) {
                setState(() => _selectedPaymentSource = value!);
              },
            ),
            loading: () => CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),

          // Expense items list
          ..._items.asMap().entries.map((entry) {
            return _buildExpenseItemForm(entry.key, entry.value);
          }),

          // Add item button
          ElevatedButton(
            onPressed: _addItem,
            child: Text('Add Item'),
          ),

          // Total display
          Text('Total: ${_formatCurrency(_totalAmount)}'),

          // Submit button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Save Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItemForm(int index, ExpenseItemForm item) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Item name with auto-suggestions
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                // Get suggestions from Firestore
                return _getItemNameSuggestions(textEditingValue.text);
              },
              onSelected: (value) {
                setState(() {
                  _items[index].name = value;
                });
              },
            ),

            // Category dropdown
            DropdownButtonFormField(
              value: item.category,
              items: ...,
              onChanged: (value) {
                setState(() {
                  _items[index].category = value!;
                });
              },
            ),

            // Quantity and price
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '${item.quantity}',
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _items[index].quantity = int.tryParse(value) ?? 1;
                        _items[index].updateTotal();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: '${item.pricePerItem}',
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _items[index].pricePerItem =
                            double.tryParse(value) ?? 0;
                        _items[index].updateTotal();
                      });
                    },
                  ),
                ),
              ],
            ),

            // Total for this item
            Text('Item Total: ${_formatCurrency(item.totalPrice)}'),

            // Remove button
            if (_items.length > 1)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeItem(index),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw 'User not authenticated';

      // Create expense object
      final expense = Expense(
        createdAt: DateTime.now(),
        spentAt: _selectedDate,
        spentPlace: _placeController.text.trim(),
        items: _items.map((item) => item.toExpenseItem()).toList(),
        totalValue: _totalAmount,
        paymentSource: _selectedPaymentSource,
        inputMethod: 'manual',
      );

      // Save to Firestore
      final expenseService = ref.read(expenseServiceProvider);
      await expenseService.addExpense(user.uid, expense);

      // Auto-add new names to Firestore (for suggestions)
      await _autoAddNewNames(user.uid);

      if (mounted) {
        NotificationHelper.showSuccess(context, 'Expense added successfully');
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(context, 'Failed to add expense: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
```

## Image Input with Gemini AI

See [lib/screens/input_tabs/image_input_tab.dart](../lib/screens/input_tabs/image_input_tab.dart):

```dart
class ImageInputTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<ImageInputTab> createState() => _ImageInputTabState();
}

class _ImageInputTabState extends ConsumerState<ImageInputTab> {
  File? _selectedImage;
  ExpenseData? _extractedData;
  bool _isProcessing = false;

  Future<void> _pickAndProcessImage() async {
    // Pick image from camera or gallery
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
      _isProcessing = true;
    });

    try {
      // Process with Gemini AI
      final geminiService = ref.read(geminiServiceProvider);
      final extractedData = await geminiService.extractExpenseFromImage(
        _selectedImage!,
      );

      setState(() {
        _extractedData = extractedData;
      });
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(
          context,
          'Failed to process image: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image preview
        if (_selectedImage != null)
          Image.file(_selectedImage!, height: 300),

        // Processing indicator
        if (_isProcessing)
          Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing receipt...'),
            ],
          ),

        // Extracted data form (editable)
        if (_extractedData != null && !_isProcessing)
          _buildEditableForm(_extractedData!),

        // Action buttons
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickAndProcessImage,
              child: Text('Take Photo'),
            ),
            if (_extractedData != null)
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text('Save'),
              ),
          ],
        ),
      ],
    );
  }
}
```

## Expense List with Filtering

See [lib/screens/expense_list_screen.dart](../lib/screens/expense_list_screen.dart):

```dart
class ExpenseListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String? _filterCategory;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) {
          // Apply filters
          final filteredExpenses = _applyFilters(expenses);

          if (filteredExpenses.isEmpty) {
            return Center(child: Text('No expenses found'));
          }

          return ListView.builder(
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];
              return ExpenseCard(
                expense: expense,
                onTap: () => _navigateToDetail(expense),
                onDelete: () => _deleteExpense(expense),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddExpenseScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  List<Expense> _applyFilters(List<Expense> expenses) {
    return expenses.where((expense) {
      // Category filter
      if (_filterCategory != null) {
        if (!expense.items.any((item) => item.spentType == _filterCategory)) {
          return false;
        }
      }

      // Date range filter
      if (_filterStartDate != null && expense.spentAt.isBefore(_filterStartDate!)) {
        return false;
      }
      if (_filterEndDate != null && expense.spentAt.isAfter(_filterEndDate!)) {
        return false;
      }

      return true;
    }).toList();
  }
}
```

## Practice Exercises

### Exercise 1: Add Search Functionality
Add a search bar to filter expenses by place name or item name.

### Exercise 2: Implement Sorting
Add buttons to sort expenses by date, amount, or place name.

### Exercise 3: Add Edit Expense Feature
Create an expense edit screen that pre-fills the form with existing data.

---

**Next Module:** [08: Feature Walkthrough - AI Integration →](08-feature-walkthrough-ai.md)
