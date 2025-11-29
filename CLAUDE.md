# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Whisp Finance Tracker is a Flutter-based expense tracking application with AI-powered input methods, comprehensive budget management, and analytics features for personal finance management.

**Version**: 0.1.0 (Beta)
**Platform**: Flutter (iOS, Android, Web, Desktop)
**Main Branch**: `development`

### Key Features

- **Multi-Input Expense Entry**: Image scanning (Gemini Vision AI), voice recording (Gemini Audio), manual form
- **Itemized Tracking**: Multiple items per expense transaction
- **Budget Management**: Category-based budget tracking and alerts
- **Analytics**: Visual charts and spending insights
- **Export**: Excel and PDF export with detailed item breakdown
- **AI Integration**: Google Gemini API for receipt scanning and voice transcription

## Architecture Overview

### Key Architectural Decisions

1. **State Management**: Riverpod for reactive state management and dependency injection
2. **UI Framework**: Material 3 with custom glassmorphism design system
3. **Backend**: Firebase (Auth, Firestore, Storage)
4. **AI Integration**: Google Generative AI (Gemini) for OCR and voice processing
5. **Architecture**: Clean Architecture with layered separation
6. **Data Persistence**: Firestore with real-time streams via StreamProviders

### Directory Structure

```
lib/
├── main.dart                    # App entry point with ProviderScope
├── firebase_options.dart        # Auto-generated Firebase configuration
├── config/
│   ├── theme.dart               # Material 3 theme with glassmorphism
│   └── env.dart                 # Environment variables (API keys)
├── models/                      # Data models with Firestore serialization
│   ├── expense.dart             # Main expense model
│   ├── expense_item.dart        # Itemized expense entry
│   ├── expense_data.dart        # AI extraction result
│   ├── budget.dart              # Budget tracking
│   ├── payment_source.dart      # Payment methods
│   └── spent_type.dart          # Expense categories
├── providers/                   # Riverpod state management
│   ├── auth_provider.dart       # Authentication state
│   ├── theme_provider.dart      # Theme mode state
│   └── user_data_provider.dart  # User data streams (payment sources, categories)
├── screens/                     # UI screens (pages)
│   ├── auth/                    # Authentication screens
│   ├── input_tabs/              # Expense input methods (image, voice, manual)
│   ├── main_screen.dart         # Tab navigation hub
│   ├── expense_list_screen.dart # Expense list with filters
│   ├── analytics_screen.dart    # Charts and insights
│   └── profile_screen.dart      # User profile and settings
├── services/                    # Business logic layer
│   ├── auth_service.dart        # Firebase Authentication
│   ├── gemini_service.dart      # Google Generative AI
│   ├── export_service.dart      # Excel/PDF export
│   ├── budget_service.dart      # Budget tracking
│   ├── payment_source_service.dart
│   ├── spent_type_service.dart
│   └── notification_service.dart
├── widgets/                     # Reusable UI components
│   ├── glass_container.dart     # Glassmorphism effect
│   ├── common/                  # Shared widgets
│   ├── expense_list/            # Expense display components
│   ├── manual_input/            # Form components
│   └── profile/                 # Profile screen components
└── utils/                       # Utility functions and constants
    ├── constants.dart           # Default data and constants
    ├── filter_sort.dart         # Filtering and sorting logic
    ├── currency_formatter.dart  # Number formatting
    ├── icon_helper.dart         # Icon mapping
    └── color_helper.dart        # Color utilities
```

### Layered Architecture

1. **Models Layer**: Immutable data structures with Firestore serialization (fromFirestore, toFirestore)
2. **Services Layer**: Business logic, Firebase operations, AI integration
3. **Providers Layer**: Riverpod providers for state management and dependency injection
4. **Screens Layer**: Full-page UI components with navigation
5. **Widgets Layer**: Reusable UI components following Material 3 design
6. **Utils Layer**: Helper functions, constants, formatters

## Key Patterns

### Riverpod Provider Pattern

```dart
// Service provider (singleton)
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Stream provider for real-time data
final activePaymentSourcesProvider = StreamProvider<List<PaymentSource>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return PaymentSourceService().streamActivePaymentSources(userId);
});

// State provider for UI state
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Usage in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentSources = ref.watch(activePaymentSourcesProvider);

    return paymentSources.when(
      data: (sources) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### Firebase Service Pattern

```dart
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream expenses in real-time
  Stream<List<Expense>> streamExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('spentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());
  }

  // Add expense with proper error handling
  Future<void> addExpense(String userId, Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .add(expense.toFirestore());
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }
}
```

### Model with Firestore Serialization

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

  const Expense({
    this.id,
    required this.createdAt,
    required this.spentAt,
    required this.spentPlace,
    required this.items,
    required this.totalValue,
    required this.paymentSource,
    this.currency = 'IDR',
  });

  // Factory constructor from Firestore
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      spentAt: (data['spentAt'] as Timestamp).toDate(),
      spentPlace: data['spentPlace'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => ExpenseItem.fromMap(item))
          .toList(),
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      paymentSource: data['paymentSource'] ?? '',
      currency: data['currency'] ?? 'IDR',
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'spentAt': Timestamp.fromDate(spentAt),
      'spentPlace': spentPlace,
      'items': items.map((item) => item.toMap()).toList(),
      'totalValue': totalValue,
      'paymentSource': paymentSource,
      'currency': currency,
    };
  }
}
```

### Widget Composition Pattern

```dart
// Reusable glass container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
```

## Firebase Integration

### Firestore Structure

```
users/{userId}/
  ├── expenses/{expenseId}
  │   ├── createdAt: Timestamp
  │   ├── spentAt: Timestamp
  │   ├── spentPlace: String
  │   ├── items: Array<ExpenseItem>
  │   ├── totalValue: Number
  │   ├── paymentSource: String
  │   ├── currency: String
  │   ├── inputMethod: String (image|voice|manual)
  │   └── imageUrl?: String
  ├── paymentSources/{sourceId}
  │   ├── name: String
  │   ├── isActive: Boolean
  │   └── order: Number
  ├── spentTypes/{typeId}
  │   ├── name: String
  │   ├── color: String
  │   ├── icon: String
  │   ├── isActive: Boolean
  │   └── order: Number
  └── budgets/{budgetId}
      ├── category: String
      ├── limit: Number
      └── period: String
```

### Authentication Pattern

```dart
// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Usage in screens
class AuthGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user != null ? MainScreen() : LoginScreen(),
      loading: () => LoadingScreen(),
      error: (error, stack) => ErrorScreen(error: error),
    );
  }
}
```

## Gemini AI Integration

### Receipt Scanning Pattern

```dart
class GeminiService {
  final GenerativeModel _visionModel;

  Future<ExpenseData> extractExpenseFromImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart('''
        Analyze this receipt and extract:
        1. Store/merchant name
        2. Date and time
        3. Individual items with prices
        4. Total amount
        5. Currency
        Return as JSON format.
      ''');

      final response = await _visionModel.generateContent([
        Content.multi([prompt, DataPart('image/jpeg', imageBytes)])
      ]);

      // Parse JSON response
      final jsonData = json.decode(response.text ?? '{}');
      return ExpenseData.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error extracting expense: $e');
      rethrow;
    }
  }
}
```

## Common Tasks

### Adding a New Screen

1. Create screen file in `lib/screens/` directory
2. Implement screen as `StatelessWidget` or `ConsumerWidget`
3. Add navigation route in `main.dart` or use Navigator
4. Follow Material 3 design guidelines
5. Use `GlassContainer` for glassmorphism effects
6. Implement proper loading/error/empty states

### Creating a New Riverpod Provider

1. Define provider in `lib/providers/` directory
2. Choose appropriate provider type:
   - `Provider` for stateless/singleton services
   - `StreamProvider` for real-time Firestore data
   - `FutureProvider` for async operations
   - `StateProvider` for simple mutable state
   - `StateNotifierProvider` for complex state logic
3. Reference provider in widgets using `ref.watch()` or `ref.read()`
4. Implement proper error handling with `.when()` method

### Adding a New Service

1. Create service class in `lib/services/` directory
2. Inject dependencies via constructor
3. Implement methods with proper error handling (try-catch)
4. Use `debugPrint` for logging
5. Return typed values (avoid dynamic)
6. Create provider for service in `lib/providers/`

### Creating a Reusable Widget

1. Create widget file in `lib/widgets/` directory (organized by feature)
2. Extend `StatelessWidget` or `ConsumerWidget` (if needs Riverpod)
3. Use `const` constructor when possible for performance
4. Accept customization via constructor parameters
5. Follow Material 3 design system
6. Support theme-aware styling (dark/light mode)
7. Add proper documentation comments

### Adding a New Model

1. Create model class in `lib/models/` directory
2. Use immutable fields (`final`)
3. Implement `fromFirestore` factory constructor
4. Implement `toFirestore` method
5. Add proper type annotations
6. Use `copyWith` method for immutability
7. Override `==` and `hashCode` if needed

## Styling Strategy

### Material 3 + Glassmorphism

- **Material 3**: Primary design system for components
- **Glassmorphism**: Custom `GlassContainer` widget for frosted glass effect
- **Theme**: Support dark and light modes via `ThemeMode` provider
- **Colors**: Use `Theme.of(context).colorScheme` for theme-aware colors
- **Typography**: Google Fonts (Poppins) via `GoogleFonts.poppins()`

### Responsive Design

```dart
// Use MediaQuery for responsive sizing
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 600;

// Use LayoutBuilder for adaptive layouts
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

## Error Handling

### Service Level

```dart
Future<void> deleteExpense(String userId, String expenseId) async {
  try {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  } on FirebaseException catch (e) {
    debugPrint('Firebase error: ${e.code} - ${e.message}');
    rethrow;
  } catch (e) {
    debugPrint('Unexpected error: $e');
    rethrow;
  }
}
```

### Widget Level

```dart
Consumer(
  builder: (context, ref, child) {
    final asyncValue = ref.watch(expensesProvider);

    return asyncValue.when(
      data: (expenses) => ExpenseList(expenses: expenses),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState(
        message: 'Failed to load expenses',
        onRetry: () => ref.invalidate(expensesProvider),
      ),
    );
  },
)
```

## Build & Development

### Development Commands

```bash
# Run in development
flutter run

# Build for specific platform
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows

# Code generation (if needed)
flutter pub run build_runner build

# Analyze code
flutter analyze

# Format code
dart format lib/

# Clean build
flutter clean && flutter pub get
```

### Environment Setup

1. Create `.env` file in project root (not committed to git)
2. Add required environment variables:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```
3. Firebase configuration is auto-generated in `firebase_options.dart`

## Additional Resources

- Detailed architecture: [context/architecture.md](context/architecture.md)
- Design principles: [context/design-principles.md](context/design-principles.md)
- Firebase integration: [context/firebase.md](context/firebase.md)
- Project overview: [context/overview.md](context/overview.md)

## Key Dependencies

- **State Management**: flutter_riverpod (^3.0.3)
- **Firebase**: firebase_core, firebase_auth, cloud_firestore, firebase_storage
- **AI**: google_generative_ai (^0.4.4)
- **UI**: google_fonts, fl_chart, shimmer, table_calendar
- **Media**: image_picker, camera, record
- **Export**: excel, pdf, share_plus
- **Utils**: uuid, intl, path_provider, shared_preferences

## Notes

- Always use `const` constructors for widgets when possible for performance
- Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
- Use null-safety operators (`?.`, `??`, `!`) appropriately
- Prefer `StreamProvider` over manual `StreamBuilder` for Firestore streams
- Use `debugPrint` instead of `print` for logging
- Implement proper loading, error, and empty states in all screens
- Test on both dark and light themes
- Consider performance: use `RepaintBoundary` for complex widgets
