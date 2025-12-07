# Module 10: Best Practices & Patterns

**Duration:** 2-3 hours | **Difficulty:** Intermediate | **Prerequisites:** All previous modules

## 🎯 Learning Objectives

- Follow Whisp's code quality standards
- Implement proper error handling patterns
- Provide user feedback for all operations
- Write maintainable, testable code
- Understand performance optimization techniques

---

## Code Organization Principles

### 1. DRY (Don't Repeat Yourself)

**❌ Bad: Duplicated code**
```dart
// In screen 1
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Delete'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
    ],
  ),
);

// In screen 2 - same code repeated!
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Delete'),
    content: Text('Are you sure?'),
    // ... same code
  ),
);
```

**✅ Good: Reusable helper**
```dart
// lib/widgets/common/confirmation_dialog.dart
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: Colors.red)
              : null,
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

// Usage
final confirmed = await showConfirmationDialog(
  context: context,
  title: 'Delete Expense',
  message: 'This action cannot be undone.',
  confirmText: 'Delete',
  isDestructive: true,
);

if (confirmed == true) {
  // Perform deletion
}
```

---

## Error Handling Patterns

### Pattern 1: Service Layer Error Handling

```dart
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addExpense(String userId, Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .add(expense.toFirestore());
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      throw _handleFirebaseError(e);
    } catch (e) {
      // Handle unexpected errors
      debugPrint('Unexpected error adding expense: $e');
      throw 'Failed to add expense. Please try again.';
    }
  }

  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again later';
      case 'unauthenticated':
        return 'Please sign in to continue';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
```

### Pattern 2: Widget Level Error Handling

```dart
class ExpenseForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    // 1. Validate
    if (!_formKey.currentState!.validate()) {
      NotificationHelper.showWarning(
        context,
        'Please fill all required fields',
      );
      return;
    }

    // 2. Show loading
    setState(() => _isLoading = true);

    // 3. Verify authentication
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      if (mounted) {
        NotificationHelper.showError(context, 'User not authenticated');
        setState(() => _isLoading = false);
      }
      return;
    }

    // 4. Perform operation with try-catch
    try {
      final expense = _buildExpense();
      await ref.read(expenseServiceProvider).addExpense(user.uid, expense);

      // 5. Success feedback
      if (mounted) {
        NotificationHelper.showSuccess(context, 'Expense added successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      // 6. Error feedback
      if (mounted) {
        NotificationHelper.showError(context, e.toString());
      }
    } finally {
      // 7. Reset loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // ... form fields
          LoadingButton(
            text: 'Save',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
```

---

## User Feedback Patterns

### NotificationHelper

See [lib/widgets/common/notification_helper.dart](../lib/widgets/common/notification_helper.dart):

```dart
class NotificationHelper {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
```

### Loading States

```dart
// 1. Loading indicator during async operation
Widget build(BuildContext context) {
  final expensesAsync = ref.watch(expensesProvider);

  return expensesAsync.when(
    data: (expenses) => ExpenseList(expenses: expenses),
    loading: () => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading expenses...'),
        ],
      ),
    ),
    error: (error, stack) => ErrorState(
      message: error.toString(),
      onRetry: () => ref.invalidate(expensesProvider),
    ),
  );
}

// 2. Shimmer loading for better UX
import 'package:shimmer/shimmer.dart';

Widget _buildLoadingShimmer() {
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          child: ListTile(
            title: Container(height: 16, color: Colors.white),
            subtitle: Container(height: 12, color: Colors.white),
          ),
        ),
      );
    },
  );
}
```

---

## Confirmation Dialogs for Destructive Actions

```dart
Future<void> _deleteExpense(Expense expense) async {
  // ALWAYS ask for confirmation before deletion
  final confirmed = await showConfirmationDialog(
    context: context,
    title: 'Delete Expense',
    message: 'Are you sure you want to delete this expense? This action cannot be undone.',
    confirmText: 'Delete',
    isDestructive: true,
  );

  if (confirmed != true) return;

  setState(() => _isDeleting = true);

  try {
    final user = ref.read(authStateProvider).value;
    if (user == null) throw 'User not authenticated';

    await ref.read(expenseServiceProvider).deleteExpense(
      user.uid,
      expense.id!,
    );

    if (mounted) {
      NotificationHelper.showSuccess(context, 'Expense deleted successfully');
    }
  } catch (e) {
    if (mounted) {
      NotificationHelper.showError(context, 'Failed to delete: $e');
    }
  } finally {
    if (mounted) {
      setState(() => _isDeleting = false);
    }
  }
}
```

---

## Mounted Checks for Async Operations

**Problem:** Using `context` or `setState` after widget is disposed causes errors.

**Solution:** Always check `mounted` after async operations.

```dart
Future<void> _loadData() async {
  try {
    final data = await fetchData();

    // ✅ Check mounted before using context
    if (mounted) {
      setState(() {
        _data = data;
      });
    }
  } catch (e) {
    // ✅ Check mounted before using context
    if (mounted) {
      NotificationHelper.showError(context, e.toString());
    }
  }
}
```

---

## Performance Optimization

### 1. Use `const` Constructors

```dart
// ❌ Bad: Widget rebuilds unnecessarily
Text('Hello')

// ✅ Good: Widget is const, won't rebuild
const Text('Hello')

// ✅ Good: Entire widget tree is const
const Column(
  children: [
    Text('Title'),
    Text('Subtitle'),
  ],
)
```

### 2. Use `ListView.builder` for Long Lists

```dart
// ❌ Bad: Loads all items at once
Column(
  children: expenses.map((e) => ExpenseCard(expense: e)).toList(),
)

// ✅ Good: Lazy loading, only renders visible items
ListView.builder(
  itemCount: expenses.length,
  itemBuilder: (context, index) {
    return ExpenseCard(expense: expenses[index]);
  },
)
```

### 3. Avoid Unnecessary Rebuilds

```dart
// ❌ Bad: Entire widget rebuilds when counter changes
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);

    return Column(
      children: [
        ExpensiveWidget(), // Rebuilds unnecessarily!
        Text('Count: $counter'),
      ],
    );
  }
}

// ✅ Good: Only Text rebuilds
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ExpensiveWidget(), // Const, won't rebuild
        Consumer(
          builder: (context, ref, child) {
            final counter = ref.watch(counterProvider);
            return Text('Count: $counter');
          },
        ),
      ],
    );
  }
}
```

---

## Security Best Practices

### 1. Never Store Sensitive Data in Code

```dart
// ❌ Bad: API key in code
const apiKey = 'AIzaSyABC123...';

// ✅ Good: Use environment variables
const apiKey = String.fromEnvironment('GEMINI_API_KEY');
```

### 2. Validate User Input

```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 3) {
      return 'Must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Only letters and spaces allowed';
    }
    return null;
  },
)
```

### 3. Sanitize Firestore Inputs

```dart
// Trim whitespace, remove special characters
final sanitizedPlace = placeController.text.trim().replaceAll(RegExp(r'[<>]'), '');

final expense = Expense(
  spentPlace: sanitizedPlace,
  // ...
);
```

---

## Code Quality Checklist

Before committing code, verify:

- [ ] **No code duplication** - Extracted common patterns into reusable widgets/functions
- [ ] **Error handling** - Try-catch blocks with user-friendly error messages
- [ ] **Loading states** - Show indicators during async operations
- [ ] **User feedback** - Success/error notifications for all user actions
- [ ] **Confirmation dialogs** - Required for destructive actions (delete, etc.)
- [ ] **Mounted checks** - After all async operations that use `context`
- [ ] **Type safety** - Proper type annotations, no `dynamic` unless necessary
- [ ] **Null safety** - Handle nullable values appropriately
- [ ] **Performance** - Use `const`, `ListView.builder`, avoid unnecessary rebuilds
- [ ] **Security** - No hardcoded secrets, validate inputs, sanitize data
- [ ] **Theme support** - Works in both dark and light modes
- [ ] **Comments** - Complex logic is documented

---

## Practice Exercise

**Task:** Review your expense list implementation and verify it follows all best practices in this module. Create a checklist and fix any issues found.

---

**Next Module:** [11: Exercises & Challenges →](11-exercises-challenges.md)
