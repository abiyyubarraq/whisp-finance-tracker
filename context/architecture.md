# Whisp Finance Tracker - Architecture

**Architecture Style**: Clean Architecture with Flutter Layers
**Primary Pattern**: Reactive architecture with Riverpod state management
**State Management**: Riverpod (Provider pattern)
**Backend**: Firebase BaaS (Backend as a Service)

---

## Core Architectural Principles

1. **Layer Separation**: Clear boundaries between models, services, providers, screens, and widgets
2. **Reactive State**: Declarative UI with reactive data streams via Riverpod
3. **Dependency Injection**: Riverpod providers for service instantiation
4. **Immutability**: Immutable data models with copyWith methods
5. **Single Responsibility**: Each layer has a specific, focused purpose

### Key Constraints

- **Technical**: Flutter 3.38+, Dart 3.2+ with null safety, Firebase SDK
- **Business**: Personal finance tracking with AI-powered input
- **Operational**: Real-time data sync, multi-platform support, offline-capable

---

## System Layers

### 1. Models Layer

**Location**: `lib/models/`

**Responsibilities**:
- Define immutable data structures
- Firestore serialization (fromFirestore, toFirestore)
- Data validation
- NO business logic or UI concerns

**Key Models**:

#### Expense Model
```dart
class Expense {
  final String? id;
  final DateTime createdAt;
  final DateTime spentAt;
  final String spentPlace;
  final String desc;
  final List<ExpenseItem> items;
  final double totalValue;
  final String paymentSource;
  final String currency;
  final String inputMethod;
  final String? imageUrl;
  final double? aiConfidence;
  final String? rawAiResponse;
  final bool isReviewed;

  const Expense({
    this.id,
    required this.createdAt,
    required this.spentAt,
    required this.spentPlace,
    this.desc = '',
    required this.items,
    required this.totalValue,
    required this.paymentSource,
    this.currency = 'IDR',
    this.inputMethod = 'manual',
    this.imageUrl,
    this.aiConfidence,
    this.rawAiResponse,
    this.isReviewed = false,
  });

  // Factory constructor from Firestore
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      spentAt: (data['spentAt'] as Timestamp).toDate(),
      spentPlace: data['spentPlace'] ?? '',
      desc: data['desc'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => ExpenseItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      paymentSource: data['paymentSource'] ?? '',
      currency: data['currency'] ?? 'IDR',
      inputMethod: data['inputMethod'] ?? 'manual',
      imageUrl: data['imageUrl'],
      aiConfidence: data['aiConfidence']?.toDouble(),
      rawAiResponse: data['rawAiResponse'],
      isReviewed: data['isReviewed'] ?? false,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'spentAt': Timestamp.fromDate(spentAt),
      'spentPlace': spentPlace,
      'desc': desc,
      'items': items.map((item) => item.toMap()).toList(),
      'totalValue': totalValue,
      'paymentSource': paymentSource,
      'currency': currency,
      'inputMethod': inputMethod,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (aiConfidence != null) 'aiConfidence': aiConfidence,
      if (rawAiResponse != null) 'rawAiResponse': rawAiResponse,
      'isReviewed': isReviewed,
    };
  }

  // CopyWith for immutability
  Expense copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? spentAt,
    String? spentPlace,
    String? desc,
    List<ExpenseItem>? items,
    double? totalValue,
    String? paymentSource,
    String? currency,
    String? inputMethod,
    String? imageUrl,
    double? aiConfidence,
    String? rawAiResponse,
    bool? isReviewed,
  }) {
    return Expense(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      spentAt: spentAt ?? this.spentAt,
      spentPlace: spentPlace ?? this.spentPlace,
      desc: desc ?? this.desc,
      items: items ?? this.items,
      totalValue: totalValue ?? this.totalValue,
      paymentSource: paymentSource ?? this.paymentSource,
      currency: currency ?? this.currency,
      inputMethod: inputMethod ?? this.inputMethod,
      imageUrl: imageUrl ?? this.imageUrl,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      rawAiResponse: rawAiResponse ?? this.rawAiResponse,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }
}
```

#### ExpenseItem Model (Itemized Entry)
```dart
class ExpenseItem {
  final String itemName;
  final String spentType;
  final double quantity;
  final double cost;
  final double value;
  final double tax;

  const ExpenseItem({
    required this.itemName,
    required this.spentType,
    this.quantity = 1.0,
    required this.cost,
    required this.value,
    this.tax = 0.0,
  });

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      itemName: map['itemName'] ?? '',
      spentType: map['spentType'] ?? 'Others',
      quantity: (map['quantity'] ?? 1.0).toDouble(),
      cost: (map['cost'] ?? 0.0).toDouble(),
      value: (map['value'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'spentType': spentType,
      'quantity': quantity,
      'cost': cost,
      'value': value,
      'tax': tax,
    };
  }

  ExpenseItem copyWith({
    String? itemName,
    String? spentType,
    double? quantity,
    double? cost,
    double? value,
    double? tax,
  }) {
    return ExpenseItem(
      itemName: itemName ?? this.itemName,
      spentType: spentType ?? this.spentType,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      value: value ?? this.value,
      tax: tax ?? this.tax,
    );
  }
}
```

**Model Pattern Principles**:
- Use `final` fields for immutability
- Implement `fromFirestore` and `toFirestore` methods
- Provide `copyWith` for immutable updates
- Use null safety appropriately (`?`, `!`, `??`)
- Include proper type annotations

### 2. Services Layer

**Location**: `lib/services/`

**Responsibilities**:
- Business logic implementation
- Firebase CRUD operations
- External API integration (Gemini AI)
- Data transformation
- Error handling

**Service Pattern**:

#### Firebase Service Example
```dart
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream expenses in real-time
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

  // Add expense with error handling
  Future<void> addExpense(String userId, Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .add(expense.toFirestore());
      debugPrint('Expense added successfully');
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error adding expense: $e');
      rethrow;
    }
  }

  // Update expense
  Future<void> updateExpense(String userId, Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Expense ID cannot be null for update');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toFirestore());
      debugPrint('Expense updated successfully');
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Delete expense
  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
      debugPrint('Expense deleted successfully');
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Upload receipt image
  Future<String> uploadReceiptImage(String userId, File imageFile) async {
    try {
      final fileName = 'receipts/${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      debugPrint('Image uploaded: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Storage error: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}
```

#### Gemini AI Service
```dart
class GeminiService {
  final GenerativeModel _visionModel;
  final GenerativeModel _textModel;

  GeminiService()
      : _visionModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: Env.geminiApiKey,
        ),
        _textModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: Env.geminiApiKey,
        );

  // Extract expense data from receipt image
  Future<ExpenseData> extractExpenseFromImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart('''
        Analyze this receipt image and extract the following information:
        1. Store/merchant name
        2. Date and time of purchase
        3. List of items with individual prices
        4. Total amount
        5. Currency (default to IDR if not specified)
        6. Any tax or service charges

        Return the data in the following JSON format:
        {
          "storeName": "string",
          "date": "YYYY-MM-DD",
          "time": "HH:MM",
          "items": [
            {
              "name": "string",
              "quantity": number,
              "unitPrice": number,
              "totalPrice": number
            }
          ],
          "totalAmount": number,
          "currency": "string",
          "tax": number
        }
      ''');

      final response = await _visionModel.generateContent([
        Content.multi([prompt, DataPart('image/jpeg', imageBytes)])
      ]);

      final responseText = response.text ?? '{}';
      debugPrint('Gemini response: $responseText');

      // Parse JSON response
      final jsonData = json.decode(responseText);
      return ExpenseData.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error extracting expense from image: $e');
      rethrow;
    }
  }

  // Transcribe voice recording and extract expense
  Future<ExpenseData> extractExpenseFromVoice(File audioFile) async {
    try {
      final audioBytes = await audioFile.readAsBytes();
      final prompt = TextPart('''
        Transcribe this audio recording and extract expense information.
        The user is describing an expense. Extract:
        1. What was purchased (item or service)
        2. Amount spent
        3. Where it was purchased (if mentioned)
        4. When (if mentioned, otherwise use current date)

        Return as JSON in the same format as image extraction.
      ''');

      final response = await _textModel.generateContent([
        Content.multi([prompt, DataPart('audio/m4a', audioBytes)])
      ]);

      final responseText = response.text ?? '{}';
      final jsonData = json.decode(responseText);
      return ExpenseData.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error extracting expense from voice: $e');
      rethrow;
    }
  }
}
```

**Service Pattern Principles**:
- Inject dependencies via constructor (or use Riverpod providers)
- Use try-catch for error handling
- Return typed values (avoid `dynamic`)
- Log operations with `debugPrint`
- Rethrow exceptions after logging
- Use `async`/`await` for Firebase operations

### 3. Providers Layer (Riverpod)

**Location**: `lib/providers/`

**Responsibilities**:
- State management
- Dependency injection
- Reactive data streams
- UI state coordination

**Provider Types and Usage**:

#### Provider (Stateless/Singleton)
```dart
// Service provider - singleton instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
```

#### StreamProvider (Real-time Data)
```dart
// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Active payment sources stream
final activePaymentSourcesProvider = StreamProvider<List<PaymentSource>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;

  if (userId == null) {
    return Stream.value([]);
  }

  return PaymentSourceService().streamActivePaymentSources(userId);
});

// Active spent types stream
final activeSpentTypesProvider = StreamProvider<List<SpentType>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;

  if (userId == null) {
    return Stream.value([]);
  }

  return SpentTypeService().streamActiveSpentTypes(userId);
});
```

#### StateProvider (Simple Mutable State)
```dart
// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Load from SharedPreferences if needed
  return ThemeMode.system;
});

// Filter state provider
final expenseFilterProvider = StateProvider<ExpenseFilter>((ref) {
  return ExpenseFilter.all();
});
```

#### FutureProvider (Async Operations)
```dart
// One-time async data fetch
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;

  if (userId == null) return null;

  return await UserService().getUserProfile(userId);
});
```

**Provider Pattern Principles**:
- Use `Provider` for stateless services (singletons)
- Use `StreamProvider` for real-time Firestore data
- Use `StateProvider` for simple mutable UI state
- Use `FutureProvider` for one-time async operations
- Use `StateNotifierProvider` for complex state logic (if needed)
- Watch dependencies with `ref.watch()`
- Read providers with `ref.read()` (in callbacks only)
- Invalidate providers with `ref.invalidate()` for refresh

### 4. Screens Layer

**Location**: `lib/screens/`

**Responsibilities**:
- Full-page UI components
- Navigation handling
- Provider consumption
- User interaction orchestration
- NO business logic

**Screen Pattern**:

```dart
class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  // Local UI state
  String _searchQuery = '';
  ExpenseFilter _filter = ExpenseFilter.all();

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.uid;

    if (userId == null) {
      return const Center(child: Text('Please log in'));
    }

    // Stream expenses from Firestore
    final expensesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('spentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());

    return Scaffold(
      appBar: ModernAppBar(title: 'Expenses'),
      body: StreamBuilder<List<Expense>>(
        stream: expensesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return _buildEmptyState();
          }

          // Filter and sort expenses
          final filteredExpenses = _applyFilters(expenses);

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh logic
              setState(() {});
            },
            child: ListView.builder(
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                return ExpenseCard(expense: filteredExpenses[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => const ExpenseCardShimmer(),
    );
  }

  Widget _buildErrorState(Object? error) {
    return ErrorState(
      message: 'Failed to load expenses',
      onRetry: () => setState(() {}),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.receipt_long,
      title: 'No Expenses Yet',
      message: 'Start tracking your expenses by adding your first entry',
    );
  }

  List<Expense> _applyFilters(List<Expense> expenses) {
    // Apply filter logic
    return expenses.where((expense) {
      if (_searchQuery.isNotEmpty) {
        return expense.spentPlace.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExpenseModal(),
    );
  }
}
```

**Screen Pattern Principles**:
- Extend `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod
- Watch providers with `ref.watch()`
- Implement loading, error, and empty states
- Keep business logic in services
- Use proper error handling
- Navigate using `Navigator` or named routes
- Compose with reusable widgets

### 5. Widgets Layer

**Location**: `lib/widgets/`

**Responsibilities**:
- Reusable UI components
- Consistent styling
- Theme-aware rendering
- NO business logic or state management

**Widget Patterns**:

#### Stateless Reusable Widget
```dart
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.7),
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
```

#### Consumer Widget (with Riverpod)
```dart
class ExpenseCard extends ConsumerWidget {
  final Expense expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                expense.spentPlace,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CurrencyFormatter.format(expense.totalValue, expense.currency),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd, yyyy • HH:mm').format(expense.spentAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          _buildItemsList(context, expense.items),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, List<ExpenseItem> items) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.itemName, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${item.quantity}x @ ${CurrencyFormatter.format(item.cost, 'IDR')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      )).toList(),
    );
  }
}
```

**Widget Pattern Principles**:
- Use `const` constructors when possible
- Accept customization via constructor parameters
- Support theme-aware styling
- Keep widgets focused and composable
- Extract complex widgets into separate files
- Use proper widget lifecycle (initState, dispose, etc.)

### 6. Utils Layer

**Location**: `lib/utils/`

**Responsibilities**:
- Helper functions
- Constants and defaults
- Formatters
- Extensions

**Utility Patterns**:

```dart
// Currency formatter
class CurrencyFormatter {
  static final NumberFormat _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$ ',
    decimalDigits: 2,
  );

  static String format(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'IDR':
        return _idrFormat.format(amount);
      case 'USD':
        return _usdFormat.format(amount);
      default:
        return '$currency ${amount.toStringAsFixed(2)}';
    }
  }
}

// Date extensions
extension DateTimeExtensions on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}

// Constants
class AppConstants {
  // Default payment sources
  static const List<String> defaultPaymentSources = [
    'Cash',
    'Debit Card',
    'Credit Card',
    'E-Wallet',
  ];

  // Default spent types
  static const List<Map<String, dynamic>> defaultSpentTypes = [
    {'name': 'Food & Dining', 'color': 'FF5733', 'icon': 'restaurant'},
    {'name': 'Transportation', 'color': '3498DB', 'icon': 'directions_car'},
    {'name': 'Shopping', 'color': 'E74C3C', 'icon': 'shopping_bag'},
    {'name': 'Entertainment', 'color': '9B59B6', 'icon': 'movie'},
    {'name': 'Bills & Utilities', 'color': '1ABC9C', 'icon': 'receipt'},
    {'name': 'Health & Fitness', 'color': '2ECC71', 'icon': 'fitness_center'},
    {'name': 'Education', 'color': 'F39C12', 'icon': 'school'},
    {'name': 'Others', 'color': '95A5A6', 'icon': 'more_horiz'},
  ];

  // Currency options
  static const List<String> supportedCurrencies = [
  'IDR',
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'SGD',
];

  // Gemini prompts
  static const String receiptExtractionPrompt = '''
    Analyze this receipt and extract expense data...
  ''';
}
```

---

## Data Flow Patterns

### 1. User-Initiated Action Flow

```
User Action (Button press)
  → Screen handles event
    → Service method called
      → Firebase operation
        → Success/Error result
          → StreamProvider auto-updates
            → UI rebuilds with new data
```

**Example: Adding an Expense**

```dart
// 1. User taps "Save" button in UI
onPressed: () async {
  final authState = ref.read(authStateProvider).value;
  final userId = authState?.uid;

  if (userId == null) return;

  // 2. Service method called
  try {
    await ExpenseService().addExpense(userId, newExpense);

    // 3. Show success feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added!')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    // 4. Handle error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // 5. StreamProvider automatically updates UI
  // No manual refresh needed!
}
```

### 2. Real-time Data Flow

```
Firestore Collection
  → .snapshots() stream
    → StreamProvider
      → ref.watch() in widget
        → .when() for loading/error/data
          → UI renders current state
```

**Example: Real-time Expense List**

```dart
// 1. Define StreamProvider
final expensesProvider = StreamProvider.autoDispose.family<List<Expense>, String>(
  (ref, userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('spentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());
  },
);

// 2. Watch in widget
final expenses = ref.watch(expensesProvider(userId));

// 3. Render based on state
return expenses.when(
  data: (expenseList) => ListView.builder(
    itemCount: expenseList.length,
    itemBuilder: (context, index) => ExpenseCard(expense: expenseList[index]),
  ),
  loading: () => const LoadingShimmer(),
  error: (error, stack) => ErrorState(message: error.toString()),
);
```

### 3. AI Integration Flow

```
User Input (Image/Voice)
  → File picked/recorded
    → Gemini Service called
      → API request to Google
        → AI response (JSON)
          → Parse to ExpenseData model
            → Display for review
              → User confirms
                → Save to Firestore
```

**Example: Receipt Scanning**

```dart
// 1. Pick image
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.camera);

if (image == null) return;

// 2. Show loading
setState(() => _isProcessing = true);

try {
  // 3. Call Gemini service
  final geminiService = ref.read(geminiServiceProvider);
  final expenseData = await geminiService.extractExpenseFromImage(File(image.path));

  // 4. Upload image to storage
  final imageUrl = await ExpenseService().uploadReceiptImage(userId, File(image.path));

  // 5. Convert to Expense model
  final expense = Expense(
    createdAt: DateTime.now(),
    spentAt: expenseData.date,
    spentPlace: expenseData.storeName,
    items: expenseData.items,
    totalValue: expenseData.totalAmount,
    paymentSource: 'Cash', // Default
    currency: expenseData.currency,
    inputMethod: 'image',
    imageUrl: imageUrl,
    aiConfidence: expenseData.confidence,
    rawAiResponse: expenseData.rawResponse,
  );

  // 6. Show review screen
  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewExpenseScreen(expense: expense),
      ),
    );
  }
} catch (e) {
  // Handle error
  debugPrint('Error processing image: $e');
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to process receipt: $e')),
    );
  }
} finally {
  setState(() => _isProcessing = false);
}
```

---

## Riverpod Architecture Patterns

### Provider Dependency Graph

```
authStateProvider (StreamProvider<User?>)
  ↓
activePaymentSourcesProvider (StreamProvider<List<PaymentSource>>)
activeSpentTypesProvider (StreamProvider<List<SpentType>>)
expensesProvider (StreamProvider<List<Expense>>)
```

### Provider Lifecycle

1. **Provider Creation**: Defined at top-level
2. **Lazy Initialization**: Created when first watched
3. **Auto-Dispose**: Disposed when no longer watched (with .autoDispose)
4. **Caching**: Values cached until invalidated
5. **Refresh**: Use `ref.invalidate()` or `ref.refresh()`

### Best Practices

```dart
// ✅ Good: Watch provider in build method
final expenses = ref.watch(expensesProvider);

// ❌ Bad: Read provider in build (won't rebuild on changes)
final expenses = ref.read(expensesProvider);

// ✅ Good: Read in callbacks/event handlers
onPressed: () {
  final service = ref.read(authServiceProvider);
  service.signOut();
}

// ✅ Good: Auto-dispose family providers
final expensesProvider = StreamProvider.autoDispose.family<List<Expense>, String>(
  (ref, userId) => ...,
);

// ✅ Good: Invalidate for manual refresh
onRefresh: () {
  ref.invalidate(expensesProvider);
}
```

---

## Firebase Architecture

### Collection Structure

```
Root Collection: users/
  Document: {userId}
    Subcollection: expenses/
      Document: {expenseId}
        Fields: createdAt, spentAt, spentPlace, items, totalValue, paymentSource,
                currency, inputMethod, imageUrl, receiptImages

    Subcollection: paymentSources/
      Document: {sourceId}
        Fields: name, isActive, createdAt

    Subcollection: spentTypes/
      Document: {typeId}
        Fields: name, color, icon, isActive, createdAt

    Subcollection: placeNames/
      Document: {placeId}
        Fields: name, isActive, createdAt

    Subcollection: itemNames/
      Document: {itemId}
        Fields: name, isActive, createdAt

    Subcollection: budgets/
      Document: {budgetId}
        Fields: category, limit, period, startDate, endDate
```

### Security Rules Pattern

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data must match authenticated user
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Query Patterns

```dart
// 1. Basic query with ordering
collection('users')
  .doc(userId)
  .collection('expenses')
  .orderBy('spentAt', descending: true)
  .limit(50);

// 2. Filtered query
collection('users')
  .doc(userId)
  .collection('expenses')
  .where('paymentSource', isEqualTo: 'Cash')
  .orderBy('spentAt', descending: true);

// 3. Date range query
collection('users')
  .doc(userId)
  .collection('expenses')
  .where('spentAt', isGreaterThanOrEqualTo: startDate)
  .where('spentAt', isLessThanOrEqualTo: endDate)
  .orderBy('spentAt', descending: true);

// 4. Compound index required for complex queries
// Note: Firestore will prompt to create index automatically
```

---

## Performance Patterns

### 1. Widget Optimization

```dart
// Use const constructors
const GlassContainer(child: Text('Hello'));

// Extract to const widgets
static const _icon = Icon(Icons.add);

// Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ComplexChart(),
);
```

### 2. Stream Optimization

```dart
// Auto-dispose unused streams
final expensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  return streamExpenses();
});

// Limit query results
.limit(100)

// Use proper ordering
.orderBy('spentAt', descending: true)
```

### 3. Image Optimization

```dart
// Compress before upload
final compressedImage = await FlutterImageCompress.compressWithFile(
  imageFile.path,
  quality: 70,
  minWidth: 1024,
  minHeight: 1024,
);
```

---

## Error Handling Architecture

### Service Level
```dart
try {
  await operation();
} on FirebaseException catch (e) {
  debugPrint('Firebase error: ${e.code}');
  rethrow;
} catch (e) {
  debugPrint('Unexpected error: $e');
  rethrow;
}
```

### Widget Level
```dart
asyncValue.when(
  data: (data) => DataView(data),
  loading: () => LoadingView(),
  error: (error, stack) => ErrorView(error),
);
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11
