# Module 03: Riverpod State Management for React Developers

**Duration:** 3-4 hours | **Difficulty:** Intermediate | **Prerequisites:** Modules 01-02, React hooks

## 🎯 Learning Objectives

After this module, you will:
- Understand Riverpod as React hooks + Context + Redux combined
- Map React state patterns to Riverpod providers
- Use providers to manage app state in Whisp
- Handle async data with StreamProvider and FutureProvider
- Understand dependency injection with Riverpod
- Know when to use each provider type

---

## 📋 Table of Contents

1. [Riverpod Overview](#riverpod-overview)
2. [Provider Types Mapping](#provider-types-mapping)
3. [useState → StateProvider](#usestate--stateprovider)
4. [useEffect → Lifecycle & Streams](#useeffect--lifecycle--streams)
5. [Context API → Provider](#context-api--provider)
6. [Redux → StateNotifier](#redux--statenotifier)
7. [Dependency Injection](#dependency-injection)
8. [Real Examples from Whisp](#real-examples-from-whisp)
9. [Best Practices](#best-practices)
10. [Quick Reference](#quick-reference)
11. [Practice Exercises](#practice-exercises)

---

## Riverpod Overview

### What is Riverpod?

**Riverpod** = **Provider** (dependency injection) + **State management** + **Reactivity**

Think of it as:
- **React Hooks** (useState, useEffect, useContext)
- **React Context** (global state)
- **Redux** (centralized state)
- **Dependency Injection** (services)

All combined into one cohesive system!

### Mental Model

```
React State Patterns  →  Maps to  →  Riverpod Providers
─────────────────────    ───────    ─────────────────────

┌─────────────────┐                 ┌──────────────────┐
│    useState     │ ─────────────→  │  StateProvider   │
│  (Local State)  │                 │  (Simple State)  │
└─────────────────┘                 └──────────────────┘

┌─────────────────┐                 ┌──────────────────┐
│   useContext    │ ─────────────→  │    Provider      │
│ (Global State)  │                 │ (Global Services)│
└─────────────────┘                 └──────────────────┘

┌─────────────────┐                 ┌──────────────────┐
│     Redux       │ ─────────────→  │ StateNotifier    │
│ (Complex State) │                 │   Provider       │
└─────────────────┘                 │(Complex State)   │
                                    └──────────────────┘

┌─────────────────┐                 ┌──────────────────┐
│ Props Drilling  │ ─────────────→  │    Provider      │
│  (Dependencies) │                 │ (Dependency      │
└─────────────────┘                 │  Injection)      │
                                    └──────────────────┘
```

### Key Concepts

| Concept | React | Riverpod |
|---------|-------|----------|
| **State container** | useState, useReducer | Provider, StateProvider |
| **Global state** | Context | Provider (automatically global) |
| **Async data** | useEffect + fetch | FutureProvider, StreamProvider |
| **Dependency injection** | Props, Context | Provider |
| **Computed values** | useMemo | Provider with dependencies |
| **Side effects** | useEffect | ref.listen, StateNotifier |

---

## Provider Types Mapping

### Quick Reference Table

| React Pattern | Riverpod Provider | Use Case |
|---------------|-------------------|----------|
| `useState<T>` | `StateProvider<T>` | Simple mutable state |
| `useContext<T>` | `Provider<T>` | Immutable values, services |
| `useEffect` + `fetch` | `FutureProvider<T>` | One-time async data |
| `useEffect` + `stream` | `StreamProvider<T>` | Real-time data (Firestore) |
| `useReducer` | `StateNotifierProvider<T>` | Complex state logic |
| `useMemo` | `Provider` with deps | Computed/derived values |

### Provider Type Decision Tree

```
                    Need to manage state?
                            │
            ┌───────────────┴───────────────┐
            │                               │
           Yes                             No
            │                               │
            ↓                               ↓
      Is it simple?                  ┌──────────────┐
            │                        │ Provider<T>  │
    ┌───────┴───────┐               │ (Immutable   │
    │               │               │  values)     │
   Yes             No               └──────────────┘
    │               │
    ↓               ↓
┌─────────────┐  Is it async?
│StateProvider│      │
│    <T>      │  ┌───┴────┐
│  (Simple    │  │        │
│   state)    │ Yes       No
└─────────────┘  │        │
                 ↓        ↓
         One-time or   ┌──────────────────┐
           stream?     │StateNotifier     │
                │      │   Provider<T>    │
         ┌──────┴────┐ │ (Complex state   │
         │           │ │  with logic)     │
      One-time    Stream└──────────────────┘
         │           │
         ↓           ↓
┌──────────────┐ ┌────────────────┐
│FutureProvider│ │StreamProvider  │
│     <T>      │ │     <T>        │
│ (One-time    │ │ (Real-time     │
│  async data) │ │  data stream)  │
└──────────────┘ └────────────────┘
```

---

## useState → StateProvider

### React: useState

```typescript
// React: Local state with useState
const ThemeToggle = () => {
  const [isDark, setIsDark] = useState(false);

  return (
    <button onClick={() => setIsDark(!isDark)}>
      {isDark ? 'Dark' : 'Light'} Mode
    </button>
  );
};
```

### Riverpod: StateProvider

```dart
// Step 1: Create provider (global, outside widget)
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Step 2: Use in widget
class ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read current value
    final isDark = ref.watch(isDarkModeProvider);

    return ElevatedButton(
      onPressed: () {
        // Update value
        ref.read(isDarkModeProvider.notifier).state = !isDark;
      },
      child: Text(isDark ? 'Dark' : 'Light' + ' Mode'),
    );
  }
}
```

### Key Differences

1. **Provider is defined globally** - Not inside widget
2. **Use `ConsumerWidget`** - Not `StatelessWidget`
3. **`ref.watch()`** - Subscribe to changes (like useState value)
4. **`ref.read()`** - Access without subscribing (for callbacks)
5. **State is automatically global** - No need for Context!

### Real Example from Whisp

```dart
// lib/providers/theme_provider.dart
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// lib/screens/profile_screen.dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ListTile(
      title: Text('Theme'),
      trailing: DropdownButton<ThemeMode>(
        value: themeMode,
        items: [
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
        ],
        onChanged: (mode) {
          if (mode != null) {
            ref.read(themeModeProvider.notifier).state = mode;
          }
        },
      ),
    );
  }
}
```

---

## useEffect → Lifecycle & Streams

### React: useEffect for Data Fetching

```typescript
// React: Fetch data with useEffect
const UserProfile = ({ userId }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUser = async () => {
      setLoading(true);
      try {
        const response = await fetch(`/api/users/${userId}`);
        const data = await response.json();
        setUser(data);
      } catch (error) {
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  return <div>{user?.name}</div>;
};
```

### Riverpod: FutureProvider

```dart
// Step 1: Create FutureProvider
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  final response = await http.get(Uri.parse('/api/users/$userId'));
  final data = jsonDecode(response.body);
  return User.fromJson(data);
});

// Step 2: Use in widget
class UserProfile extends ConsumerWidget {
  final String userId;
  const UserProfile({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider(userId));

    // Handle loading, error, and data states
    return asyncUser.when(
      data: (user) => Text(user.name),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### React: useEffect for Real-time Data

```typescript
// React: Subscribe to real-time updates
const ExpenseList = () => {
  const [expenses, setExpenses] = useState([]);

  useEffect(() => {
    const unsubscribe = firestore
      .collection('expenses')
      .onSnapshot(snapshot => {
        const data = snapshot.docs.map(doc => doc.data());
        setExpenses(data);
      });

    return () => unsubscribe();
  }, []);

  return (
    <ul>
      {expenses.map(expense => (
        <li key={expense.id}>{expense.amount}</li>
      ))}
    </ul>
  );
};
```

### Riverpod: StreamProvider

```dart
// Step 1: Create StreamProvider
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('expenses')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList());
});

// Step 2: Use in widget
class ExpenseList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExpenses = ref.watch(expensesProvider);

    return asyncExpenses.when(
      data: (expenses) => ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ListTile(
            title: Text(expense.spentPlace),
            subtitle: Text('${expense.totalValue}'),
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Key Observations

1. **No manual cleanup** - Riverpod handles unsubscribing
2. **Automatic refetching** - When dependencies change
3. **Built-in loading/error states** - Use `.when()` method
4. **No race conditions** - Riverpod cancels outdated requests

---

## Context API → Provider

### React: Context API

```typescript
// React: Create context
const AuthContext = createContext<User | null>(null);

// Provider component
const AuthProvider: React.FC = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged(setUser);
    return unsubscribe;
  }, []);

  return (
    <AuthContext.Provider value={user}>
      {children}
    </AuthContext.Provider>
  );
};

// Usage in component
const Profile = () => {
  const user = useContext(AuthContext);
  return <div>{user?.name}</div>;
};

// Must wrap app
<AuthProvider>
  <App />
</AuthProvider>
```

### Riverpod: StreamProvider (No Wrapper Needed!)

```dart
// Step 1: Create provider (automatically global)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Step 2: Use anywhere in app (no wrapper needed!)
class Profile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(authStateProvider);

    return asyncUser.when(
      data: (user) => Text(user?.displayName ?? 'Guest'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// App setup - just wrap with ProviderScope once
void main() {
  runApp(
    ProviderScope(  // Only needed at root
      child: MyApp(),
    ),
  );
}
```

### Advantages over React Context

| Feature | React Context | Riverpod |
|---------|--------------|----------|
| **Setup** | Need Provider wrapper | Just define provider |
| **Multiple contexts** | Multiple nested wrappers | Multiple providers, no nesting |
| **Performance** | Can cause unnecessary rebuilds | Optimized, granular |
| **Testing** | Need to wrap tests | Easy to override |
| **Type safety** | Manual typing | Automatic |

---

## Redux → StateNotifier

### React: Redux

```typescript
// Redux: Action types
const INCREMENT = 'INCREMENT';
const DECREMENT = 'DECREMENT';

// Action creators
const increment = () => ({ type: INCREMENT });
const decrement = () => ({ type: DECREMENT });

// Reducer
const counterReducer = (state = 0, action) => {
  switch (action.type) {
    case INCREMENT:
      return state + 1;
    case DECREMENT:
      return state - 1;
    default:
      return state;
  }
};

// Component
const Counter = () => {
  const count = useSelector(state => state.counter);
  const dispatch = useDispatch();

  return (
    <div>
      <p>{count}</p>
      <button onClick={() => dispatch(increment())}>+</button>
      <button onClick={() => dispatch(decrement())}>-</button>
    </div>
  );
};
```

### Riverpod: StateNotifier

```dart
// Step 1: Create StateNotifier (like reducer)
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0); // Initial state

  void increment() {
    state = state + 1;
  }

  void decrement() {
    state = state - 1;
  }

  void reset() {
    state = 0;
  }
}

// Step 2: Create provider
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

// Step 3: Use in widget
class Counter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Column(
      children: [
        Text('$count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: Text('+'),
        ),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).decrement(),
          child: Text('-'),
        ),
      ],
    );
  }
}
```

### Complex Example: Expense Filter State

```dart
// State class
class ExpenseFilterState {
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseFilterState({
    this.category,
    this.startDate,
    this.endDate,
  });

  ExpenseFilterState copyWith({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExpenseFilterState(
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// StateNotifier
class ExpenseFilterNotifier extends StateNotifier<ExpenseFilterState> {
  ExpenseFilterNotifier() : super(const ExpenseFilterState());

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void reset() {
    state = const ExpenseFilterState();
  }
}

// Provider
final expenseFilterProvider =
    StateNotifierProvider<ExpenseFilterNotifier, ExpenseFilterState>((ref) {
  return ExpenseFilterNotifier();
});

// Usage
class FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(expenseFilterProvider);

    return Row(
      children: [
        DropdownButton<String>(
          value: filter.category,
          onChanged: (category) {
            ref.read(expenseFilterProvider.notifier).setCategory(category);
          },
          items: [
            DropdownMenuItem(value: null, child: Text('All')),
            DropdownMenuItem(value: 'food', child: Text('Food')),
            DropdownMenuItem(value: 'transport', child: Text('Transport')),
          ],
        ),
      ],
    );
  }
}
```

---

## Dependency Injection

### React: Props Drilling vs Context

```typescript
// React: Props drilling problem
<App>
  <UserService>
    <Dashboard>
      <Profile>
        <UserDetails />  {/* Needs UserService, passed through 3 levels */}
      </Profile>
    </Dashboard>
  </UserService>
</App>

// React: Context solution
const UserServiceContext = createContext<UserService>(new UserService());
```

### Riverpod: Automatic DI

```dart
// Step 1: Define service provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Step 2: Use anywhere without drilling!
class UserDetails extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.read(userServiceProvider);
    // Use service directly
  }
}

// No props drilling needed!
```

### Provider Dependencies

**Providers can depend on other providers:**

```dart
// Auth provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Expenses provider depends on auth
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  // Watch auth state
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  // Use auth state to fetch expenses
  return ExpenseService().streamExpenses(user.uid);
});
```

**This is like:**
```typescript
// React equivalent
const useExpenses = () => {
  const user = useContext(AuthContext);
  const [expenses, setExpenses] = useState([]);

  useEffect(() => {
    if (!user) return;
    const unsubscribe = fetchExpenses(user.uid, setExpenses);
    return unsubscribe;
  }, [user]);

  return expenses;
};
```

---

## Real Examples from Whisp

### Example 1: Auth State

```dart
// lib/providers/auth_provider.dart
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Usage: Check if user is logged in
class AuthGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return MainScreen(); // Logged in
        } else {
          return LoginScreen(); // Not logged in
        }
      },
      loading: () => LoadingScreen(),
      error: (error, stack) => ErrorScreen(error: error),
    );
  }
}
```

### Example 2: User Data Streams

```dart
// lib/providers/user_data_provider.dart

// Payment sources stream
final activePaymentSourcesProvider = StreamProvider<List<PaymentSource>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);

  return PaymentSourceService().streamActivePaymentSources(userId);
});

// Spent types stream
final activeSpentTypesProvider = StreamProvider<List<SpentType>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);

  return SpentTypeService().streamActiveSpentTypes(userId);
});

// Usage in form
class ExpenseForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentSourcesAsync = ref.watch(activePaymentSourcesProvider);

    return paymentSourcesAsync.when(
      data: (sources) => DropdownButton(
        items: sources.map((s) => DropdownMenuItem(
          value: s.name,
          child: Text(s.name),
        )).toList(),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading payment sources'),
    );
  }
}
```

### Example 3: Theme Provider

```dart
// lib/providers/theme_provider.dart
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Usage in main app
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: AuthGate(),
    );
  }
}
```

---

## Best Practices

### 1. Choose the Right Provider Type

```dart
// ❌ Wrong: StateProvider for complex state
final expenseFilterProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// ✅ Correct: StateNotifier for complex state
final expenseFilterProvider = StateNotifierProvider<ExpenseFilterNotifier, ExpenseFilterState>((ref) {
  return ExpenseFilterNotifier();
});
```

### 2. Use `ref.watch()` vs `ref.read()`

```dart
// ✅ Use ref.watch() in build method (subscribes to changes)
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(authStateProvider);
  return Text(user?.name ?? 'Guest');
}

// ✅ Use ref.read() in callbacks (doesn't subscribe)
onPressed: () {
  final service = ref.read(userServiceProvider);
  service.doSomething();
}

// ❌ Don't use ref.watch() in callbacks (causes rebuild loops)
onPressed: () {
  final service = ref.watch(userServiceProvider); // Wrong!
}
```

### 3. Provider Naming Convention

```dart
// Services/Repositories
final authServiceProvider = Provider<AuthService>(...);
final firestoreProvider = Provider<FirebaseFirestore>(...);

// State
final themeModeProvider = StateProvider<ThemeMode>(...);
final counterProvider = StateNotifierProvider<CounterNotifier, int>(...);

// Async data
final userProvider = FutureProvider<User>(...);
final expensesProvider = StreamProvider<List<Expense>>(...);
```

### 4. Keep Providers Focused

```dart
// ❌ Don't: One giant provider for everything
final appStateProvider = StateNotifierProvider<AppState, AppState>(...);

// ✅ Do: Separate providers by domain
final authStateProvider = StreamProvider<User?>(...);
final themeProvider = StateProvider<ThemeMode>(...);
final expensesProvider = StreamProvider<List<Expense>>(...);
```

### 5. Dispose Resources

```dart
// StateNotifier with cleanup
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  ExpenseNotifier(this._service) : super(ExpenseState.initial());

  final ExpenseService _service;

  @override
  void dispose() {
    // Cleanup resources
    _service.dispose();
    super.dispose();
  }
}
```

---

## Quick Reference

### Provider Types

```dart
// 1. Provider - Immutable values/services
final configProvider = Provider<Config>((ref) => Config());

// 2. StateProvider - Simple mutable state
final counterProvider = StateProvider<int>((ref) => 0);

// 3. StateNotifierProvider - Complex state logic
final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

// 4. FutureProvider - One-time async data
final userProvider = FutureProvider<User>((ref) async {
  return fetchUser();
});

// 5. StreamProvider - Real-time data
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  return streamExpenses();
});
```

### ConsumerWidget

```dart
// Use ConsumerWidget instead of StatelessWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(myProvider);
    return Text('$value');
  }
}
```

### ConsumerStatefulWidget

```dart
// Use ConsumerStatefulWidget for stateful + Riverpod
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final value = ref.watch(myProvider);
    return Text('$value');
  }
}
```

### Accessing Providers

```dart
// watch - Subscribe to changes (in build method)
final value = ref.watch(provider);

// read - Access without subscribing (in callbacks)
final value = ref.read(provider);

// listen - React to changes (in initState, etc.)
ref.listen(provider, (previous, next) {
  // Do something when provider changes
});
```

---

## Practice Exercises

### Exercise 1: Simple Counter (30 minutes)

Convert this React counter to Riverpod:

```typescript
const Counter = () => {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount(count - 1)}>-</button>
      <button onClick={() => setCount(0)}>Reset</button>
    </div>
  );
};
```

<details>
<summary>Solution</summary>

```dart
// Provider
final counterProvider = StateProvider<int>((ref) => 0);

// Widget
class Counter extends ConsumerWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: Text('+'),
        ),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state--,
          child: Text('-'),
        ),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state = 0,
          child: Text('Reset'),
        ),
      ],
    );
  }
}
```
</details>

---

### Exercise 2: Theme Toggle (30 minutes)

Create a theme toggle with Riverpod that persists across the app.

**Requirements:**
- Provider for theme mode (light/dark/system)
- Button to toggle theme
- Apply theme to MaterialApp

<details>
<summary>Solution</summary>

```dart
// Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Toggle button
class ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return IconButton(
      icon: Icon(
        themeMode == ThemeMode.dark
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
      onPressed: () {
        final newMode = themeMode == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark;
        ref.read(themeModeProvider.notifier).state = newMode;
      },
    );
  }
}

// Apply in app
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Scaffold(
        appBar: AppBar(
          actions: [ThemeToggle()],
        ),
      ),
    );
  }
}
```
</details>

---

### Exercise 3: Todo List with StateNotifier (60 minutes)

Build a todo list with add, remove, and toggle functionality.

**Requirements:**
- StateNotifier for todo state
- Add new todos
- Toggle todo completion
- Remove todos
- Filter by completed/incomplete

<details>
<summary>Solution</summary>

```dart
// Models
class Todo {
  final String id;
  final String title;
  final bool completed;

  const Todo({
    required this.id,
    required this.title,
    this.completed = false,
  });

  Todo copyWith({String? id, String? title, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

// StateNotifier
class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void addTodo(String title) {
    final todo = Todo(
      id: DateTime.now().toString(),
      title: title,
    );
    state = [...state, todo];
  }

  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(completed: !todo.completed)
        else
          todo,
    ];
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

// Provider
final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

// Filter provider
enum TodoFilter { all, completed, incomplete }

final todoFilterProvider = StateProvider<TodoFilter>((ref) {
  return TodoFilter.all;
});

// Filtered todos (computed)
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoFilter.incomplete:
      return todos.where((todo) => !todo.completed).toList();
    default:
      return todos;
  }
});

// UI
class TodoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          leading: Checkbox(
            value: todo.completed,
            onChanged: (_) {
              ref.read(todoProvider.notifier).toggleTodo(todo.id);
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              ref.read(todoProvider.notifier).removeTodo(todo.id);
            },
          ),
        );
      },
    );
  }
}
```
</details>

---

## Next Steps

Excellent! You now understand Riverpod state management from a React perspective.

**Next Module:** [04: Project Architecture →](04-project-architecture.md)

In the next module, you'll explore Whisp's clean architecture, folder structure, and how all the pieces fit together.

---

## Summary Checklist

- [ ] I understand how Riverpod compares to React hooks and Context
- [ ] I know when to use StateProvider vs StateNotifierProvider
- [ ] I can use FutureProvider for async data
- [ ] I can use StreamProvider for real-time data
- [ ] I understand `ref.watch()` vs `ref.read()`
- [ ] I can create and use providers in Whisp
- [ ] I understand provider dependencies
- [ ] I can follow Riverpod best practices

**Continue to:** [Module 04: Project Architecture](04-project-architecture.md)
