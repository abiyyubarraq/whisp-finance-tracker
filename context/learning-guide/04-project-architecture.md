# Module 04: Project Architecture

**Duration:** 2-3 hours | **Difficulty:** Intermediate | **Prerequisites:** Modules 01-03

## 🎯 Learning Objectives

After this module, you will:
- Understand Whisp's Clean Architecture implementation
- Know the purpose of each folder and file
- Understand data flow through the layers
- Know how to add new features following the architecture
- Understand separation of concerns

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Directory Structure Deep Dive](#directory-structure-deep-dive)
3. [Layered Architecture](#layered-architecture)
4. [Data Flow](#data-flow)
5. [Adding a New Feature](#adding-a-new-feature)
6. [Dependency Injection](#dependency-injection)
7. [Quick Reference](#quick-reference)
8. [Practice Exercises](#practice-exercises)

---

## Architecture Overview

### Clean Architecture Principles

Whisp follows **Clean Architecture** with these layers:

```
Clean Architecture Layers (top to bottom):

    ┌───────────────────────────────────────┐
    │    Presentation Layer                 │
    │    (Screens & Widgets)                │
    │    - UI components                    │
    │    - User interactions                │
    └────────────────┬──────────────────────┘
                     │ uses
                     ↓
    ┌───────────────────────────────────────┐
    │    State Management Layer             │
    │    (Riverpod Providers)               │
    │    - StreamProvider, StateProvider    │
    │    - Reactive state                   │
    └────────────────┬──────────────────────┘
                     │ calls
                     ↓
    ┌───────────────────────────────────────┐
    │    Business Logic Layer               │
    │    (Services)                         │
    │    - ExpenseService, AuthService      │
    │    - Business rules                   │
    └────────────────┬──────────────────────┘
                     │ uses
                     ↓
    ┌───────────────────────────────────────┐
    │    Data Layer                         │
    │    (Models & Firebase)                │
    │    - Data models                      │
    │    - Firestore, Auth, Storage         │
    └───────────────────────────────────────┘
```

**Key Principles:**
1. **Separation of Concerns** - Each layer has a specific responsibility
2. **Dependency Rule** - Outer layers depend on inner layers, not vice versa
3. **Testability** - Each layer can be tested independently
4. **Maintainability** - Changes in one layer don't affect others

### React/Node.js Comparison

| Layer | React/Node.js | Whisp Flutter |
|-------|---------------|---------------|
| **Presentation** | React Components | Screens & Widgets |
| **State** | Redux/Context | Riverpod Providers |
| **Business Logic** | Services/Controllers | Services |
| **Data** | API Clients/Models | Models & Firebase |
| **Utils** | Utils/Helpers | Utils |

---

## Directory Structure Deep Dive

### Complete Structure

```
lib/
├── main.dart                           # App entry point
├── firebase_options.dart               # Auto-generated Firebase config
│
├── config/                             # App-wide configuration
│   ├── theme.dart                      # Material 3 theme definition
│   └── env.dart                        # Environment variables
│
├── models/                             # Data models (Domain layer)
│   ├── expense.dart                    # Main expense entity
│   ├── expense_item.dart               # Item within expense
│   ├── expense_data.dart               # AI extraction result
│   ├── budget.dart                     # Budget tracking
│   ├── payment_source.dart             # Payment methods
│   ├── spent_type.dart                 # Expense categories
│   ├── place_name.dart                 # Place names
│   └── item_name.dart                  # Item names
│
├── providers/                          # State management (Riverpod)
│   ├── auth_provider.dart              # Authentication state
│   ├── theme_provider.dart             # Theme mode state
│   └── user_data_provider.dart         # User data streams
│
├── services/                           # Business logic layer
│   ├── auth_service.dart               # Firebase Authentication
│   ├── expense_service.dart            # Expense CRUD operations
│   ├── gemini_service.dart             # Google Gemini AI
│   ├── export_service.dart             # Excel/PDF export
│   ├── budget_service.dart             # Budget calculations
│   ├── payment_source_service.dart     # Payment source management
│   ├── spent_type_service.dart         # Category management
│   ├── place_name_service.dart         # Place name management
│   ├── item_name_service.dart          # Item name management
│   └── notification_service.dart       # Local notifications
│
├── screens/                            # UI screens (pages)
│   ├── auth/                           # Authentication screens
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── input_tabs/                     # Expense input methods
│   │   ├── image_input_tab.dart        # Image scanning
│   │   ├── voice_input_tab.dart        # Voice recording
│   │   └── manual_input_tab.dart       # Manual form
│   ├── main_screen.dart                # Tab navigation hub
│   ├── expense_list_screen.dart        # Expense list with filters
│   ├── expense_detail_screen.dart      # Expense details
│   ├── expense_edit_screen.dart        # Edit expense
│   ├── analytics_screen.dart           # Charts and insights
│   ├── budget_management_screen.dart   # Budget tracking
│   ├── profile_screen.dart             # User profile
│   └── manage_data_screen.dart         # Manage categories, etc.
│
├── widgets/                            # Reusable UI components
│   ├── glass_container.dart            # Glassmorphism effect
│   ├── common/                         # Shared components
│   │   ├── confirmation_dialog.dart
│   │   ├── notification_helper.dart
│   │   └── loading_button.dart
│   ├── expense_list/                   # Expense display
│   │   ├── expense_card.dart
│   │   ├── expense_summary.dart
│   │   └── filter_bar.dart
│   ├── manual_input/                   # Form components
│   │   ├── expense_item_form.dart
│   │   └── date_picker_field.dart
│   └── profile/                        # Profile components
│       └── theme_selector.dart
│
└── utils/                              # Utility functions
    ├── constants.dart                  # App constants
    ├── filter_sort.dart                # Filtering & sorting logic
    ├── currency_formatter.dart         # Number formatting
    ├── icon_helper.dart                # Icon mapping
    └── color_helper.dart               # Color utilities
```

### Purpose of Each Directory

#### **models/** (Domain Layer)
**Purpose:** Define data structures and business entities

**Comparison:** Like TypeScript interfaces + class methods
```typescript
// TypeScript interface
interface Expense {
  id: string;
  amount: number;
  date: Date;
}
```

```dart
// Dart model class
class Expense {
  final String? id;
  final double totalValue;
  final DateTime spentAt;

  const Expense({this.id, required this.totalValue, required this.spentAt});

  factory Expense.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

**Key Files:**
- [expense.dart](../lib/models/expense.dart) - Main expense entity
- [expense_item.dart](../lib/models/expense_item.dart) - Itemized entries
- [budget.dart](../lib/models/budget.dart) - Budget tracking

---

#### **services/** (Business Logic Layer)
**Purpose:** Handle business logic, Firebase operations, external APIs

**Comparison:** Like Node.js controllers/services
```typescript
// Node.js service
class ExpenseService {
  async getExpenses(userId: string): Promise<Expense[]> {
    return await db.collection('expenses').where('userId', '==', userId).get();
  }
}
```

```dart
// Flutter service
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Expense>> streamExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());
  }
}
```

**Key Files:**
- [expense_service.dart](../lib/services/expense_service.dart) - Expense CRUD
- [gemini_service.dart](../lib/services/gemini_service.dart) - AI integration
- [auth_service.dart](../lib/services/auth_service.dart) - Authentication

---

#### **providers/** (State Management Layer)
**Purpose:** Manage application state with Riverpod

**Comparison:** Like Redux store or React Context providers

**Key Files:**
- [auth_provider.dart](../lib/providers/auth_provider.dart) - Auth state
- [user_data_provider.dart](../lib/providers/user_data_provider.dart) - User data streams

Example:
```dart
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ExpenseService().streamExpenses(userId);
});
```

---

#### **screens/** (Presentation Layer)
**Purpose:** Full-page UI components with navigation

**Comparison:** Like React pages/routes

**Organization:**
- One file per screen
- Screens compose widgets
- Handle user interactions
- Navigate to other screens

**Example:**
```dart
class ExpenseListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Expenses')),
      body: expensesAsync.when(
        data: (expenses) => ExpenseList(expenses: expenses),
        loading: () => LoadingIndicator(),
        error: (error, stack) => ErrorWidget(error),
      ),
    );
  }
}
```

---

#### **widgets/** (UI Components Layer)
**Purpose:** Reusable UI components

**Comparison:** Like React components

**Organization by feature:**
- `common/` - Shared across app
- `expense_list/` - Expense display components
- `manual_input/` - Form components
- `profile/` - Profile-specific components

**Example:**
```dart
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const GlassContainer({required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(...),
      child: BackdropFilter(...),
    );
  }
}
```

---

#### **utils/** (Utility Layer)
**Purpose:** Helper functions, constants, formatters

**Comparison:** Like utility files in any project

**Key Files:**
- [constants.dart](../lib/utils/constants.dart) - Default data, constants
- [currency_formatter.dart](../lib/utils/currency_formatter.dart) - Number formatting
- [filter_sort.dart](../lib/utils/filter_sort.dart) - Filtering logic

---

## Layered Architecture

### Layer Dependencies

```
Dependency Flow:

    ┌──────────────────────┐
    │  Presentation Layer  │
    │ (Screens & Widgets)  │───────────┐
    └──────────┬───────────┘           │
               │ uses                  │ uses
               ↓                       ↓
    ┌──────────────────────┐    ┌─────────────┐
    │  State Management    │    │    Utils    │
    │    (Providers)       │    │  (Helpers,  │
    └──────────┬───────────┘    │  Constants) │
               │ calls           └─────────────┘
               │         uses
               ↓          ↓
    ┌──────────────────────┐
    │   Business Logic     │
    │     (Services)       │
    └──────────┬───────────┘
               │ uses
               ↓
    ┌──────────────────────┐
    │     Data Layer       │
    │      (Models)        │
    └──────────────────────┘
               │
               │ calls
               ↓
    ┌──────────────────────┐
    │      Firebase        │
    │  (Firestore, Auth,   │
    │     Storage)         │
    └──────────────────────┘

Note: Providers also use Models directly for type information
```

### Data Flow Example: Adding an Expense

```
Sequence of operations when user adds an expense:

    Screen          Provider        Service        Firestore
      │                │               │               │
      │ 1. User fills  │               │               │
      │    form        │               │               │
      │                │               │               │
      │ 2. Submit      │               │               │
      │──────────────────addExpense()──────────────────>│
      │                │               │               │
      │                │               │ 3. Validate   │
      │                │               │    data       │
      │                │               │               │
      │                │               │ 4. Add doc    │
      │                │               │──────────────>│
      │                │               │               │
      │                │               │<─ 5. Success ─│
      │<────────────────6. Complete ───────────────────│
      │                │               │               │
      │                │<────7. Snapshot update────────│
      │                │   (real-time listener)        │
      │                │               │               │
      │<─ 8. Rebuild ──│               │               │
      │  with new data │               │               │
      │                │               │               │

Flow Summary:
1. User fills form in UI
2. Screen calls Service.addExpense()
3. Service validates the data
4. Service adds document to Firestore
5. Firestore returns success
6. Method completes
7. Firestore triggers real-time snapshot update to Provider
8. Provider notifies Screen to rebuild with new data
```

**Code walkthrough:**

1. **User interaction (Presentation Layer):**
```dart
// lib/screens/input_tabs/manual_input_tab.dart
onPressed: () async {
  final expense = Expense(...);
  await ExpenseService().addExpense(userId, expense);
  Navigator.pop(context);
}
```

2. **Service layer (Business Logic):**
```dart
// lib/services/expense_service.dart
Future<void> addExpense(String userId, Expense expense) async {
  try {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add(expense.toFirestore());
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }
}
```

3. **Real-time update (State Management):**
```dart
// lib/providers/user_data_provider.dart
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  return ExpenseService().streamExpenses(userId);
});
```

4. **UI updates automatically (Presentation Layer):**
```dart
// lib/screens/expense_list_screen.dart
final expensesAsync = ref.watch(expensesProvider);
// Widget rebuilds with new data
```

---

## Adding a New Feature

### Example: Adding "Expense Tags" Feature

**Step-by-step process:**

#### Step 1: Create Model
```dart
// lib/models/tag.dart
class Tag {
  final String? id;
  final String name;
  final String color;
  final bool isActive;
  final DateTime createdAt;

  const Tag({
    this.id,
    required this.name,
    required this.color,
    this.isActive = true,
    required this.createdAt,
  });

  factory Tag.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tag(
      id: doc.id,
      name: data['name'] ?? '',
      color: data['color'] ?? '#000000',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
```

#### Step 2: Create Service
```dart
// lib/services/tag_service.dart
class TagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream active tags
  Stream<List<Tag>> streamActiveTags(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Tag.fromFirestore(doc))
            .toList());
  }

  // Add tag
  Future<void> addTag(String userId, Tag tag) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .add(tag.toFirestore());
  }

  // Update tag
  Future<void> updateTag(String userId, String tagId, Tag tag) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .update(tag.toFirestore());
  }

  // Delete tag
  Future<void> deleteTag(String userId, String tagId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .delete();
  }
}
```

#### Step 3: Create Provider
```dart
// lib/providers/user_data_provider.dart (add to existing file)
final activeTagsProvider = StreamProvider<List<Tag>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return TagService().streamActiveTags(userId);
});
```

#### Step 4: Create Management Screen
```dart
// lib/screens/manage_tags_screen.dart
class ManageTagsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(activeTagsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Manage Tags')),
      body: tagsAsync.when(
        data: (tags) => ListView.builder(
          itemCount: tags.length,
          itemBuilder: (context, index) {
            final tag = tags[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(int.parse(tag.color.replaceFirst('#', '0xff'))),
              ),
              title: Text(tag.name),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteTag(context, ref, tag),
              ),
            );
          },
        ),
        loading: () => CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTagDialog(context, ref),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteTag(BuildContext context, WidgetRef ref, Tag tag) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    await TagService().deleteTag(userId, tag.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tag deleted')),
    );
  }

  void _showAddTagDialog(BuildContext context, WidgetRef ref) {
    // Show dialog to add tag
  }
}
```

#### Step 5: Integrate into Expense Model
```dart
// lib/models/expense.dart (modify existing)
class Expense {
  // ... existing fields
  final List<String> tags; // Add this field

  const Expense({
    // ... existing parameters
    this.tags = const [],
  });

  // Update fromFirestore and toFirestore methods
}
```

#### Step 6: Update Expense Form
```dart
// lib/screens/input_tabs/manual_input_tab.dart
class ManualInputTab extends ConsumerStatefulWidget {
  // Add state for selected tags
  List<String> _selectedTags = [];

  // Add tag selector widget
  Widget _buildTagSelector() {
    final tagsAsync = ref.watch(activeTagsProvider);

    return tagsAsync.when(
      data: (tags) => Wrap(
        spacing: 8,
        children: tags.map((tag) {
          final isSelected = _selectedTags.contains(tag.name);
          return FilterChip(
            label: Text(tag.name),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedTags.add(tag.name);
                } else {
                  _selectedTags.remove(tag.name);
                }
              });
            },
          );
        }).toList(),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading tags'),
    );
  }
}
```

---

## Dependency Injection

### Service Provider Pattern

All services are provided through Riverpod providers:

```dart
// lib/providers/service_providers.dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final expenseServiceProvider = Provider<ExpenseService>((ref) => ExpenseService());
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

// Usage in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final expenseService = ref.read(expenseServiceProvider);

    // Use services
  }
}
```

### Benefits

1. **Easy testing** - Mock providers for tests
2. **No singleton boilerplate** - Riverpod handles it
3. **Automatic disposal** - Resources cleaned up
4. **Hot reload friendly** - State preserved

---

## Quick Reference

### File Naming Conventions

```
snake_case_file_names.dart
PascalCaseClassNames
camelCaseVariables
_privateMembers
```

### Where to Put New Code

| What you're adding | Where it goes |
|-------------------|---------------|
| New data model | `lib/models/` |
| API/Firebase logic | `lib/services/` |
| State provider | `lib/providers/` |
| New screen | `lib/screens/` |
| Reusable component | `lib/widgets/` |
| Helper function | `lib/utils/` |
| App constant | `lib/utils/constants.dart` |

### Import Organization

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:io';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:riverpod/riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 4. Local imports
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_card.dart';
```

---

## Practice Exercises

### Exercise 1: Trace Data Flow (30 minutes)

**Task:** Trace how data flows when a user adds a new expense.

1. Start at the UI (manual input form)
2. Follow through service layer
3. Track Firebase operation
4. Observe how UI updates via provider

Open these files and trace the flow:
1. [manual_input_tab.dart](../lib/screens/input_tabs/manual_input_tab.dart)
2. [expense_service.dart](../lib/services/expense_service.dart)
3. [user_data_provider.dart](../lib/providers/user_data_provider.dart)

---

### Exercise 2: Add a New Utility (15 minutes)

**Task:** Create a utility function to format dates.

1. Create `lib/utils/date_formatter.dart`
2. Add a function `formatExpenseDate(DateTime date)`
3. Use it in an expense card widget

---

### Exercise 3: Create a New Widget (30 minutes)

**Task:** Create a reusable `StatCard` widget.

Requirements:
- Shows a title, value, and icon
- Uses glassmorphism style
- Place in `lib/widgets/common/stat_card.dart`

---

## Next Steps

Great! You now understand Whisp's architecture.

**Next Module:** [05: Firebase Integration →](05-firebase-integration.md)

Learn how Firebase is integrated for auth, Firestore, and storage.

---

## Summary Checklist

- [ ] I understand Clean Architecture layers
- [ ] I know the purpose of each directory
- [ ] I can trace data flow through the app
- [ ] I know where to add new features
- [ ] I understand the service provider pattern
- [ ] I can follow the project's file organization

**Continue to:** [Module 05: Firebase Integration](05-firebase-integration.md)
