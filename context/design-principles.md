# Design Principles - Whisp Finance Tracker

These guidelines outline fundamental coding practices and workflow preferences for the Whisp Finance Tracker Flutter application. They emphasize clarity, reusability, consistency, and adherence to Flutter/Dart best practices with emphasis on Riverpod patterns, Firebase integration, Gemini AI usage, and widget composition.

---

## Dart & Flutter Coding Standards

### Dart Style Guide Compliance

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

- **Naming Conventions**:
  - Classes, enums, typedefs, extensions: `PascalCase`
  - Libraries, packages, directories, source files: `snake_case`
  - Variables, constants, parameters, named parameters: `camelCase`
  - Private members: prefix with underscore `_privateMember`

```dart
// Good
class ExpenseService {}
class PaymentSource {}
final authService = AuthService();
const String appVersion = '1.0.0';

// File naming
// expense_service.dart
// payment_source.dart
```

### Null Safety

Leverage Dart's sound null safety:

```dart
// Use nullable types appropriately
String? optionalValue;
String requiredValue = 'default';

// Use null-aware operators
final name = user?.name ?? 'Guest';
final length = text?.length;

// Avoid non-null assertion unless absolutely certain
final id = expense.id!; // Only if you're 100% sure it's not null

// Prefer null checks
if (expense.id != null) {
  process(expense.id);
}
```

### Immutability

**Prefer immutable data structures:**

```dart
// Good: Immutable model
class Expense {
  final String id;
  final DateTime createdAt;
  final List<ExpenseItem> items;

  const Expense({
    required this.id,
    required this.createdAt,
    required this.items,
  });

  // Provide copyWith for updates
  Expense copyWith({
    String? id,
    DateTime? createdAt,
    List<ExpenseItem>? items,
  }) {
    return Expense(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

// Bad: Mutable fields
class Expense {
  String id;
  DateTime createdAt;

  Expense(this.id, this.createdAt);
}
```

### Const Constructors

**Use `const` constructors for performance:**

```dart
// Good: Const widget
class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No data'));
  }
}

// Usage with const
const EmptyState(message: 'No expenses');

// Const in widget tree
Column(
  children: const [
    Icon(Icons.info),
    SizedBox(height: 16),
    Text('Information'),
  ],
)
```

---

## Flutter Best Practices

### Widget Composition Over Inheritance

**Compose widgets rather than extending:**

```dart
// Good: Composition
class ExpenseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(title: 'Expenses'),
      body: ExpenseList(),
      floatingActionButton: AddExpenseButton(),
    );
  }
}

// Avoid: Deep inheritance hierarchies
class MyCustomWidget extends ComplexBaseWidget {}
```

### Build Method Purity

**Keep build methods pure - no side effects:**

```dart
// Good: Pure build method
@override
Widget build(BuildContext context) {
  final expenses = ref.watch(expensesProvider);
  return ListView(children: expenses.map((e) => ExpenseCard(e)).toList());
}

// Bad: Side effects in build
@override
Widget build(BuildContext context) {
  // DON'T: Call APIs in build
  fetchExpenses(); // ❌

  // DON'T: Modify state in build
  setState(() {}); // ❌

  return ListView(...);
}
```

### Proper Widget Lifecycle

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Initialize resources
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Clean up resources
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(controller: _scrollController);
  }
}
```

### Performance Optimization

```dart
// 1. Use const constructors
const Text('Hello');
const Icon(Icons.add);

// 2. Extract widgets to avoid rebuilds
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Text('Header');
  }
}

// 3. Use RepaintBoundary for complex widgets
RepaintBoundary(
  child: ExpensiveChart(),
);

// 4. Keys for list items
ListView.builder(
  itemBuilder: (context, index) {
    return ExpenseCard(
      key: ValueKey(expenses[index].id),
      expense: expenses[index],
    );
  },
);
```

---

## Riverpod Best Practices (EMPHASIS)

### Provider Types Selection

```dart
// 1. Provider - Stateless services/singletons
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 2. StreamProvider - Real-time Firestore data (MOST COMMON)
final expensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ExpenseService().streamExpenses(userId);
});

// 3. FutureProvider - One-time async operations
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final userId = ref.watch(authStateProvider).value?.uid;
  return await UserService().getProfile(userId!);
});

// 4. StateProvider - Simple mutable state
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// 5. StateNotifierProvider - Complex state logic (if needed)
final filterProvider = StateNotifierProvider<FilterNotifier, ExpenseFilter>((ref) {
  return FilterNotifier();
});
```

### Watching vs Reading

```dart
// ✅ CORRECT: Watch in build method (reactive)
@override
Widget build(BuildContext context, WidgetRef ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.when(...);
}

// ✅ CORRECT: Read in callbacks/event handlers
onPressed: () {
  final service = ref.read(authServiceProvider);
  await service.signOut();
}

// ❌ WRONG: Reading in build (won't rebuild)
@override
Widget build(BuildContext context, WidgetRef ref) {
  final expenses = ref.read(expensesProvider); // ❌
  return ListView(...);
}

// ❌ WRONG: Watching in callbacks (unnecessary)
onPressed: () {
  final service = ref.watch(authServiceProvider); // ❌
}
```

### Auto-Dispose Pattern

```dart
// ✅ Good: Auto-dispose unused providers
final expensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  return streamExpenses();
});

// ✅ Good: Family providers with auto-dispose
final expenseProvider = StreamProvider.autoDispose.family<Expense, String>(
  (ref, expenseId) {
    return streamExpense(expenseId);
  },
);

// Use keepAlive() if you need to preserve state
final importantDataProvider = Provider.autoDispose<Data>((ref) {
  ref.keepAlive(); // Never disposed
  return Data();
});
```

### Provider Dependencies

```dart
// ✅ Good: Watch dependent providers
final userExpensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  // Watch auth state
  final userId = ref.watch(authStateProvider).value?.uid;

  if (userId == null) {
    return Stream.value([]);
  }

  return ExpenseService().streamExpenses(userId);
});

// ✅ Good: Invalidate for refresh
Future<void> _refresh() async {
  ref.invalidate(expensesProvider);
}
```

### AsyncValue Handling

```dart
// ✅ BEST: Use .when() for all states
final expenses = ref.watch(expensesProvider);

return expenses.when(
  data: (expenseList) => ExpenseListView(expenseList),
  loading: () => const LoadingShimmer(),
  error: (error, stack) => ErrorState(
    message: error.toString(),
    onRetry: () => ref.invalidate(expensesProvider),
  ),
);

// Alternative: Pattern matching
if (expenses.isLoading) {
  return const LoadingView();
}

if (expenses.hasError) {
  return ErrorView(expenses.error!);
}

final data = expenses.value!;
return DataView(data);
```

---

## Firebase Integration Patterns (EMPHASIS)

### Firestore Serialization

```dart
// ✅ REQUIRED PATTERN: fromFirestore & toFirestore
class Expense {
  final String? id;
  final DateTime createdAt;
  final List<ExpenseItem> items;

  const Expense({
    this.id,
    required this.createdAt,
    required this.items,
  });

  // Factory from Firestore
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => ExpenseItem.fromMap(item))
          .toList() ?? [],
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
```

### Firebase Service Pattern

```dart
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Stream for real-time data
  Stream<List<Expense>> streamExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('spentAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());
  }

  // ✅ CRUD with error handling
  Future<void> addExpense(String userId, Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .add(expense.toFirestore());
      debugPrint('✅ Expense added');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> updateExpense(String userId, Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Expense ID required for update');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toFirestore());
      debugPrint('✅ Expense updated');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error: ${e.code}');
      rethrow;
    }
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
      debugPrint('✅ Expense deleted');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error: ${e.code}');
      rethrow;
    }
  }
}
```

### Error Handling with Firebase

```dart
// ✅ Catch specific Firebase exceptions
try {
  await operation();
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      throw 'No user found with this email';
    case 'wrong-password':
      throw 'Incorrect password';
    case 'email-already-in-use':
      throw 'Email is already registered';
    default:
      throw 'Authentication error: ${e.message}';
  }
} on FirebaseException catch (e) {
  debugPrint('Firebase error: ${e.code}');
  rethrow;
} catch (e) {
  debugPrint('Unexpected error: $e');
  rethrow;
}
```

---

## Gemini AI Integration Patterns (EMPHASIS)

### Gemini Service Pattern

```dart
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Env.geminiApiKey,
    );
  }

  // ✅ Image-based extraction
  Future<ExpenseData> extractFromImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final prompt = TextPart(_buildPrompt());

      final response = await _model.generateContent([
        Content.multi([prompt, DataPart('image/jpeg', bytes)])
      ]);

      final jsonText = _extractJson(response.text ?? '{}');
      return ExpenseData.fromJson(json.decode(jsonText));
    } catch (e) {
      debugPrint('❌ Gemini extraction failed: $e');
      rethrow;
    }
  }

  String _buildPrompt() {
    return '''
      Extract expense data from this receipt.
      Return ONLY valid JSON with this structure:
      {
        "storeName": "string",
        "date": "YYYY-MM-DD",
        "items": [{"name": "string", "price": number}],
        "total": number,
        "currency": "string"
      }
    ''';
  }

  String _extractJson(String text) {
    // Extract JSON from markdown code blocks if present
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
    return jsonMatch?.group(1) ?? text;
  }
}
```

### Gemini Error Handling

```dart
try {
  final data = await geminiService.extractFromImage(image);
  // Process data
} on FormatException {
  // Invalid JSON response
  showError('AI couldn\'t extract data clearly. Please review manually.');
} on Exception catch (e) {
  // Network or API errors
  debugPrint('Gemini error: $e');
  showError('Failed to process receipt. Please try again.');
}
```

---

## Widget Composition Patterns (EMPHASIS)

### Reusable Widget Design

```dart
// ✅ Good: Flexible, composable widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ??
        (isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.7));

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
```

### Extract Complex Widgets

```dart
// ✅ Good: Extract to separate widget
class ExpenseCard extends ConsumerWidget {
  final Expense expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(context),
          _buildItemsList(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(...);
  Widget _buildItemsList(BuildContext context) => Column(...);
  Widget _buildFooter(BuildContext context) => Row(...);
}

// ❌ Bad: Monolithic build method
class ExpenseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // 200+ lines of nested widgets
    );
  }
}
```

### Material 3 Design Compliance

```dart
// ✅ Use Material 3 components
ElevatedButton(
  onPressed: () {},
  child: const Text('Add Expense'),
);

FilledButton(
  onPressed: () {},
  child: const Text('Save'),
);

OutlinedButton(
  onPressed: () {},
  child: const Text('Cancel'),
);

// ✅ Use Theme colors
Text(
  'Total',
  style: TextStyle(color: Theme.of(context).colorScheme.primary),
);

Container(
  color: Theme.of(context).colorScheme.surface,
);
```

### Loading, Error, Empty States

```dart
// ✅ REQUIRED: Implement all states
final expenses = ref.watch(expensesProvider);

return expenses.when(
  data: (list) {
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long,
        title: 'No Expenses',
        message: 'Add your first expense to get started',
      );
    }
    return ExpenseListView(list);
  },
  loading: () => const LoadingShimmer(),
  error: (error, stack) => ErrorState(
    message: 'Failed to load expenses',
    onRetry: () => ref.invalidate(expensesProvider),
  ),
);
```

---

## Code Organization

### Import Ordering

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:io';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports (alphabetical)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Relative imports (project files)
import '../models/expense.dart';
import '../providers/auth_provider.dart';
import '../services/expense_service.dart';
import '../widgets/glass_container.dart';
```

### File Organization

```dart
// Order within a file:
// 1. Imports
// 2. Constants
// 3. Providers (if applicable)
// 4. Main class
// 5. Private helper classes/functions

// Example:
import 'package:flutter/material.dart';

// Constants
const double kDefaultPadding = 16.0;

// Providers
final expenseServiceProvider = Provider(...);

// Main class
class ExpenseListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
  }
}

// Private helpers
class _ExpenseCardShimmer extends StatelessWidget {
  // ...
}
```

---

## Error Handling Principles

### Service Layer

```dart
Future<void> operation() async {
  try {
    await riskyOperation();
    debugPrint('✅ Operation successful');
  } on SpecificException catch (e) {
    debugPrint('❌ Specific error: $e');
    rethrow;
  } catch (e, stackTrace) {
    debugPrint('❌ Unexpected error: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}
```

### Widget Layer

```dart
Future<void> _handleSubmit() async {
  try {
    await service.operation();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Success!')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

---

## Logging and Debugging

```dart
// ✅ Use debugPrint (strips in production)
debugPrint('User ID: $userId');
debugPrint('Expenses loaded: ${expenses.length}');

// ✅ Conditional logging
if (kDebugMode) {
  print('Detailed debug info: $data');
}

// ❌ Don't use print in production code
print('This will appear in production'); // ❌

// ✅ Log errors with context
debugPrint('❌ Failed to add expense: $e');
debugPrint('   User ID: $userId');
debugPrint('   Expense: ${expense.toFirestore()}');
```

---

## Documentation

### Code Comments

```dart
/// Extracts expense data from a receipt image using Gemini AI.
///
/// Returns [ExpenseData] with extracted information including:
/// - Store name
/// - Purchase date and time
/// - List of items with prices
/// - Total amount and currency
///
/// Throws [FormatException] if JSON parsing fails.
/// Throws [Exception] for network or API errors.
Future<ExpenseData> extractFromImage(File imageFile) async {
  // Implementation
}

// Use inline comments for complex logic only
final filteredExpenses = expenses.where((expense) {
  // Apply date range filter
  if (!expense.spentAt.isAfter(startDate)) return false;

  // Apply payment source filter
  if (filter.paymentSource != null &&
      expense.paymentSource != filter.paymentSource) {
    return false;
  }

  return true;
}).toList();
```

---

## Testing Considerations

While testing documentation is excluded per user request, maintain testable code:

- Keep business logic in services (testable without widgets)
- Use dependency injection via Riverpod
- Avoid tight coupling between layers
- Make widgets accept data via constructors
- Give widgets that tests or Maestro must find a key from `lib/utils/test_keys.dart` and a `Semantics` label (see README → Testing)

---

**Document Version**: 1.0
**Last Updated**: 2025-11
