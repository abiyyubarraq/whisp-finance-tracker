# Module 02: Dart Fundamentals for TypeScript Developers

**Duration:** 2-3 hours | **Difficulty:** Beginner | **Prerequisites:** TypeScript basics

## 🎯 Learning Objectives

After this module, you will:
- Read and write Dart code confidently
- Understand Dart's type system and null safety
- Use Dart collections (List, Map, Set)
- Handle async operations with Future and Stream
- Understand key Dart features (spread, cascade, etc.)
- Know common Dart patterns used in the project

---

## 📋 Table of Contents

1. [Dart vs TypeScript Overview](#dart-vs-typescript-overview)
2. [Basic Syntax](#basic-syntax)
3. [Type System](#type-system)
4. [Null Safety](#null-safety)
5. [Functions](#functions)
6. [Classes and Objects](#classes-and-objects)
7. [Collections](#collections)
8. [Async Programming](#async-programming)
9. [Dart-Specific Features](#dart-specific-features)
10. [Common Patterns in Whisp](#common-patterns-in-whisp)
11. [Quick Reference](#quick-reference)
12. [Practice Exercises](#practice-exercises)

---

## Dart vs TypeScript Overview

### Key Similarities

Both Dart and TypeScript:
- ✅ Are statically typed
- ✅ Have type inference
- ✅ Support async/await
- ✅ Have classes and interfaces
- ✅ Compile to other languages (TS → JS, Dart → Native/JS)
- ✅ Have null safety features

### Key Differences

| Feature | TypeScript | Dart |
|---------|-----------|------|
| **Primary use** | Web (compiles to JS) | Mobile, Web, Desktop (compiles to native) |
| **Null safety** | Optional (`strictNullChecks`) | Built-in, enforced |
| **Type erasure** | Yes (compiles to JS) | No (types preserved at runtime) |
| **Syntax** | JavaScript-based | C-like, cleaner |
| **Package manager** | npm/yarn | pub |
| **Main use case** | Adds types to JS | Flutter framework language |

---

## Basic Syntax

### Variables

**TypeScript:**
```typescript
// TypeScript
let name: string = "John";
const age: number = 30;
var oldStyle = "avoid"; // old-style

// Type inference
let city = "Jakarta"; // inferred as string
```

**Dart:**
```dart
// Dart
String name = "John";
final int age = 30;
var oldStyle = "avoid"; // mutable

// Type inference
var city = "Jakarta"; // inferred as String

// Constants
const pi = 3.14159; // Compile-time constant
final currentTime = DateTime.now(); // Runtime constant
```

### Key Points

| Keyword | TypeScript | Dart | Mutability |
|---------|-----------|------|------------|
| `let` | Mutable | N/A | Mutable |
| `const` | Immutable reference | Compile-time constant | Immutable |
| `var` | Mutable (avoid) | Type inferred, mutable | Mutable |
| `final` | N/A | Runtime constant | Immutable |

**Dart Best Practice:**
- Use `final` for values that won't change (most common)
- Use `const` for compile-time constants (literals, config)
- Avoid `var` - be explicit with types or use `final`

---

### String Interpolation

**TypeScript:**
```typescript
const name = "Alice";
const age = 25;

// Template literals
const message = `Hello, ${name}! You are ${age} years old.`;
const calculation = `Next year: ${age + 1}`;
```

**Dart:**
```dart
final name = "Alice";
final age = 25;

// String interpolation (similar syntax)
final message = 'Hello, $name! You are $age years old.';
final calculation = 'Next year: ${age + 1}';

// Note: Single quotes are conventional in Dart
// Use ${} for expressions, $ for simple variables
```

---

### Comments

Both languages use the same comment syntax:

```dart
// Single-line comment

/*
 * Multi-line comment
 */

/// Documentation comment (like JSDoc)
/// Used by dartdoc tool
///
/// Example:
/// ```dart
/// final result = calculateTotal(10, 5);
/// ```
```

---

## Type System

### Basic Types

**TypeScript:**
```typescript
let str: string = "text";
let num: number = 42;
let flag: boolean = true;
let list: number[] = [1, 2, 3];
let tuple: [string, number] = ["Alice", 25];
let obj: object = { name: "Bob" };
let nothing: void = undefined;
let nullable: string | null = null;
```

**Dart:**
```dart
String str = "text";
int num = 42;          // Integer (different from double!)
double price = 9.99;   // Floating-point
bool flag = true;
List<int> list = [1, 2, 3];
// No built-in tuple, use custom class or record (Dart 3.0+)
Map<String, dynamic> obj = {"name": "Bob"};
void nothing;          // void return type only
String? nullable = null;  // Null safety syntax
```

### Important Difference: int vs double

**TypeScript:**
```typescript
// TypeScript: Only 'number' type
let a: number = 42;
let b: number = 3.14;
a = b; // OK, both are number
```

**Dart:**
```dart
// Dart: Separate int and double types
int a = 42;
double b = 3.14;
// a = b; // ERROR: Can't assign double to int

// Must explicitly convert
a = b.toInt();      // 3
b = a.toDouble();   // 42.0
```

### Type Aliases

**TypeScript:**
```typescript
type UserID = string;
type Callback = (data: string) => void;

interface User {
  id: UserID;
  name: string;
}
```

**Dart:**
```dart
typedef UserID = String;
typedef Callback = void Function(String data);

class User {
  final UserID id;
  final String name;

  User(this.id, this.name);
}
```

---

## Null Safety

### Overview

Dart has **sound null safety** built into the language (since Dart 2.12). TypeScript's null checking is optional and not as strict.

### Nullable vs Non-nullable

**TypeScript (with strictNullChecks):**
```typescript
let name: string = "Alice";
name = null; // Error with strictNullChecks

let nullableName: string | null = "Bob";
nullableName = null; // OK

// Optional chaining
const length = nullableName?.length;

// Nullish coalescing
const displayName = nullableName ?? "Guest";
```

**Dart:**
```dart
String name = "Alice";
// name = null; // ERROR: Can't assign null to non-nullable

String? nullableName = "Bob";
nullableName = null; // OK

// Null-aware operators
final length = nullableName?.length;  // null if nullableName is null

// If-null operator
final displayName = nullableName ?? "Guest";

// Null assertion (use sparingly!)
final definiteLength = nullableName!.length;  // Throws if null
```

### Null Safety Operators

| Operator | TypeScript | Dart | Description |
|----------|-----------|------|-------------|
| `?.` | Optional chaining | Null-aware access | Access member if not null |
| `??` | Nullish coalescing | If-null | Provide default value |
| `!` | Non-null assertion | Null assertion | Assert value is non-null |
| `??=` | N/A | Null-aware assignment | Assign if null |

### Null-Aware Examples

```dart
// Null-aware access
String? userName;
print(userName?.toUpperCase()); // null (doesn't crash)

// If-null operator
String displayName = userName ?? "Guest";
print(displayName); // "Guest"

// Null-aware assignment
userName ??= "Anonymous"; // Assign only if null
print(userName); // "Anonymous"

// Null assertion (dangerous!)
String? maybeName = getName();
String definitelyName = maybeName!; // Throws if maybeName is null
```

### Late Variables

```dart
// TypeScript: Use definite assignment assertion
class Service {
  private client!: HttpClient; // Trust me, it will be assigned

  init() {
    this.client = new HttpClient();
  }
}

// Dart: Use 'late' keyword
class Service {
  late HttpClient client; // Will be assigned before use

  void init() {
    client = HttpClient();
  }
}
```

**`late` keyword:**
- Defers initialization
- Must be assigned before first read
- Throws error if accessed before initialization

---

## Functions

### Function Declaration

**TypeScript:**
```typescript
// Function declaration
function add(a: number, b: number): number {
  return a + b;
}

// Arrow function
const multiply = (a: number, b: number): number => a * b;

// Optional parameters
function greet(name: string, title?: string): string {
  return title ? `Hello, ${title} ${name}` : `Hello, ${name}`;
}

// Default parameters
function greet2(name: string, title: string = "Mr."): string {
  return `Hello, ${title} ${name}`;
}
```

**Dart:**
```dart
// Function declaration
int add(int a, int b) {
  return a + b;
}

// Arrow function (for single expressions)
int multiply(int a, int b) => a * b;

// Optional positional parameters []
String greet(String name, [String? title]) {
  return title != null ? 'Hello, $title $name' : 'Hello, $name';
}

// Optional named parameters {}
String greet2(String name, {String title = "Mr."}) {
  return 'Hello, $title $name';
}

// Required named parameters (Dart 2.12+)
void createUser({required String name, required int age}) {
  print('$name is $age years old');
}
```

### Named Parameters

This is a **key difference** - Dart has named parameters built into the language:

**TypeScript:**
```typescript
// TypeScript: Use object destructuring
function createUser({ name, age, email }: {
  name: string;
  age: number;
  email?: string;
}) {
  console.log(name, age, email);
}

createUser({ name: "Alice", age: 25 });
```

**Dart:**
```dart
// Dart: Built-in named parameters
void createUser({
  required String name,
  required int age,
  String? email,
}) {
  print('$name, $age, $email');
}

createUser(name: "Alice", age: 25);
createUser(name: "Bob", age: 30, email: "bob@example.com");
```

### Function Types

**TypeScript:**
```typescript
type Callback = (data: string) => void;

function executeCallback(cb: Callback) {
  cb("Hello");
}
```

**Dart:**
```dart
typedef Callback = void Function(String data);
// or inline:
void executeCallback(void Function(String) cb) {
  cb("Hello");
}

// Common types:
VoidCallback // void Function()
ValueChanged<T> // void Function(T value)
```

---

## Classes and Objects

### Basic Class

**TypeScript:**
```typescript
class Person {
  name: string;
  age: number;

  constructor(name: string, age: number) {
    this.name = name;
    this.age = age;
  }

  greet(): string {
    return `Hello, I'm ${this.name}`;
  }
}

const person = new Person("Alice", 25);
```

**Dart:**
```dart
class Person {
  String name;
  int age;

  // Constructor
  Person(this.name, this.age);

  String greet() {
    return "Hello, I'm $name";
  }
}

final person = Person("Alice", 25);
// Note: 'new' keyword is optional in Dart
```

### Constructor Shortcuts

**Dart has a shorthand for constructors:**

```dart
// Long form (like TypeScript)
class Person {
  String name;
  int age;

  Person(String name, int age) {
    this.name = name;
    this.age = age;
  }
}

// Short form (Dart-specific)
class Person {
  String name;
  int age;

  Person(this.name, this.age); // Automatically assigns
}

// With final fields
class Person {
  final String name;
  final int age;

  const Person(this.name, this.age); // Can be const constructor
}
```

### Named Constructors

**TypeScript:**
```typescript
// TypeScript: Use static factory methods
class User {
  constructor(
    public name: string,
    public email: string
  ) {}

  static fromJson(json: any): User {
    return new User(json.name, json.email);
  }
}

const user = User.fromJson({ name: "Alice", email: "alice@example.com" });
```

**Dart:**
```dart
// Dart: Built-in named constructors
class User {
  final String name;
  final String email;

  User(this.name, this.email);

  // Named constructor
  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'];

  // Another named constructor
  User.guest()
      : name = 'Guest',
        email = 'guest@example.com';
}

final user1 = User.fromJson({'name': 'Alice', 'email': 'alice@example.com'});
final user2 = User.guest();
```

### Getters and Setters

**TypeScript:**
```typescript
class Rectangle {
  constructor(
    public width: number,
    public height: number
  ) {}

  get area(): number {
    return this.width * this.height;
  }

  set dimensions({ width, height }: { width: number; height: number }) {
    this.width = width;
    this.height = height;
  }
}
```

**Dart:**
```dart
class Rectangle {
  double width;
  double height;

  Rectangle(this.width, this.height);

  // Getter
  double get area => width * height;

  // Setter
  set area(double value) {
    // Not common in Dart, but possible
    width = value / height;
  }
}
```

### Immutability Pattern

**Common in both languages:**

```dart
// Dart: Immutable class with copyWith pattern
class User {
  final String name;
  final int age;

  const User({required this.name, required this.age});

  // copyWith method for immutable updates
  User copyWith({String? name, int? age}) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}

final user1 = User(name: "Alice", age: 25);
final user2 = user1.copyWith(age: 26); // New instance
```

This pattern is **everywhere** in Flutter and Whisp project!

---

## Collections

### Lists (Arrays)

**TypeScript:**
```typescript
const numbers: number[] = [1, 2, 3, 4, 5];

// Methods
numbers.push(6);
numbers.pop();
const first = numbers[0];
const length = numbers.length;

// Array methods
const doubled = numbers.map(n => n * 2);
const evens = numbers.filter(n => n % 2 === 0);
const sum = numbers.reduce((acc, n) => acc + n, 0);
```

**Dart:**
```dart
List<int> numbers = [1, 2, 3, 4, 5];

// Methods
numbers.add(6);
numbers.removeLast();
final first = numbers[0];
final length = numbers.length;

// List methods (similar to JS)
final doubled = numbers.map((n) => n * 2).toList();
final evens = numbers.where((n) => n % 2 == 0).toList();
final sum = numbers.reduce((acc, n) => acc + n);

// Note: map() returns Iterable, must call .toList()
```

### Maps (Objects/Dictionaries)

**TypeScript:**
```typescript
const user: { [key: string]: any } = {
  name: "Alice",
  age: 25,
  email: "alice@example.com"
};

// Access
const name = user["name"];
const age = user.age;

// Add/update
user.city = "Jakarta";

// Check existence
if ("email" in user) {
  console.log(user.email);
}
```

**Dart:**
```dart
Map<String, dynamic> user = {
  'name': 'Alice',
  'age': 25,
  'email': 'alice@example.com',
};

// Access
final name = user['name'];
// user.age doesn't work with Map<String, dynamic>

// Add/update
user['city'] = 'Jakarta';

// Check existence
if (user.containsKey('email')) {
  print(user['email']);
}

// Iterate
user.forEach((key, value) {
  print('$key: $value');
});
```

### Sets

**TypeScript:**
```typescript
const uniqueNumbers = new Set<number>([1, 2, 3, 3, 4]);
console.log(uniqueNumbers); // Set { 1, 2, 3, 4 }

uniqueNumbers.add(5);
uniqueNumbers.delete(2);
const hasThree = uniqueNumbers.has(3);
```

**Dart:**
```dart
final uniqueNumbers = <int>{1, 2, 3, 3, 4};
print(uniqueNumbers); // {1, 2, 3, 4}

uniqueNumbers.add(5);
uniqueNumbers.remove(2);
final hasThree = uniqueNumbers.contains(3);
```

### Spread Operator

**TypeScript:**
```typescript
const list1 = [1, 2, 3];
const list2 = [4, 5, 6];
const combined = [...list1, ...list2];

const obj1 = { a: 1, b: 2 };
const obj2 = { ...obj1, c: 3 };
```

**Dart:**
```dart
final list1 = [1, 2, 3];
final list2 = [4, 5, 6];
final combined = [...list1, ...list2];

// Spread works in maps too
final obj1 = {'a': 1, 'b': 2};
final obj2 = {...obj1, 'c': 3};
```

---

## Async Programming

### Promises vs Futures

**TypeScript:**
```typescript
// Promise
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return data;
}

// Usage
fetchUser("123")
  .then(user => console.log(user))
  .catch(error => console.error(error));

// Or with async/await
try {
  const user = await fetchUser("123");
  console.log(user);
} catch (error) {
  console.error(error);
}
```

**Dart:**
```dart
// Future (equivalent to Promise)
Future<User> fetchUser(String id) async {
  final response = await http.get(Uri.parse('/api/users/$id'));
  final data = jsonDecode(response.body);
  return User.fromJson(data);
}

// Usage
fetchUser("123")
  .then((user) => print(user))
  .catchError((error) => print(error));

// Or with async/await
try {
  final user = await fetchUser("123");
  print(user);
} catch (error) {
  print(error);
}
```

### Key Similarities

- Both use `async` and `await` keywords
- Both return `Promise<T>` / `Future<T>`
- Both handle errors with try-catch
- Both support `.then()` and `.catchError()` / `.catch()`

### Streams (Observables)

**TypeScript (with RxJS):**
```typescript
import { Observable } from 'rxjs';

const numbers$ = new Observable<number>(subscriber => {
  subscriber.next(1);
  subscriber.next(2);
  subscriber.next(3);
  subscriber.complete();
});

numbers$.subscribe(
  value => console.log(value),
  error => console.error(error),
  () => console.log('Complete')
);
```

**Dart:**
```dart
// Stream (built into Dart)
Stream<int> numberStream() async* {
  yield 1;
  yield 2;
  yield 3;
}

// Usage
numberStream().listen(
  (value) => print(value),
  onError: (error) => print(error),
  onDone: () => print('Complete'),
);

// Or with await for
await for (final number in numberStream()) {
  print(number);
}
```

### Real Example from Whisp

```dart
// Firestore stream (real-time updates)
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

// Usage in Riverpod provider
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);
  return ExpenseService().streamExpenses(userId);
});
```

---

## Dart-Specific Features

### Cascade Notation

**Unique to Dart** - allows chaining method calls on the same object:

```dart
// Without cascade
var user = User();
user.name = "Alice";
user.age = 25;
user.save();

// With cascade notation (..)
var user = User()
  ..name = "Alice"
  ..age = 25
  ..save();

// Real example from Whisp
final paint = Paint()
  ..color = Colors.blue
  ..strokeWidth = 2.0
  ..style = PaintingStyle.stroke;
```

### Collection If/For

**Dart-specific syntax for conditionals and loops in collections:**

```dart
// Collection if
final items = [
  'Always',
  if (isLoggedIn) 'Profile',
  if (isAdmin) 'Admin Panel',
];

// Collection for
final numbers = [1, 2, 3];
final doubled = [
  for (var n in numbers) n * 2
];
```

**TypeScript equivalent (more verbose):**
```typescript
const items = [
  'Always',
  ...(isLoggedIn ? ['Profile'] : []),
  ...(isAdmin ? ['Admin Panel'] : []),
];

const doubled = numbers.map(n => n * 2);
```

### Extension Methods

**Add methods to existing classes:**

```dart
// Define extension
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// Usage
final name = "alice";
print(name.capitalize()); // "Alice"

// Real example from Whisp (utils/extensions.dart)
extension DateTimeExtensions on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year &&
           month == other.month &&
           day == other.day;
  }
}
```

---

## Common Patterns in Whisp

### Pattern 1: Immutable Model with fromFirestore/toFirestore

```dart
class Expense {
  final String? id;
  final DateTime spentAt;
  final double totalValue;
  final List<ExpenseItem> items;

  const Expense({
    this.id,
    required this.spentAt,
    required this.totalValue,
    required this.items,
  });

  // Deserialize from Firestore
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      spentAt: (data['spentAt'] as Timestamp).toDate(),
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      items: (data['items'] as List? ?? [])
          .map((item) => ExpenseItem.fromMap(item))
          .toList(),
    );
  }

  // Serialize to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'spentAt': Timestamp.fromDate(spentAt),
      'totalValue': totalValue,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  // copyWith for immutable updates
  Expense copyWith({
    String? id,
    DateTime? spentAt,
    double? totalValue,
    List<ExpenseItem>? items,
  }) {
    return Expense(
      id: id ?? this.id,
      spentAt: spentAt ?? this.spentAt,
      totalValue: totalValue ?? this.totalValue,
      items: items ?? this.items,
    );
  }
}
```

### Pattern 2: Async Service Methods

```dart
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Async method returning Future
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

  // Stream method for real-time data
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

### Pattern 3: Null-Safe Widget Access

```dart
class ExpenseCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = ref.watch(expenseProvider);

    // Null-safe access
    final placeName = expense?.spentPlace ?? 'Unknown';
    final itemCount = expense?.items.length ?? 0;

    // Null-aware cascade
    expense?.items.forEach((item) {
      print(item.name);
    });

    return Text('$placeName - $itemCount items');
  }
}
```

---

## Quick Reference

### Type System

```dart
// Basic types
int, double, String, bool

// Collections
List<T>, Map<K, V>, Set<T>

// Nullability
T (non-nullable), T? (nullable)

// Type aliases
typedef MyCallback = void Function(String);

// Dynamic
dynamic (avoid if possible)
```

### Null Safety

```dart
// Operators
value?.property       // Null-aware access
value ?? default      // If-null
value!                // Null assertion (dangerous)
value ??= default     // Null-aware assignment
```

### Collections

```dart
// List
[1, 2, 3]
[...list1, ...list2]                 // Spread
[for (var x in items) x * 2]         // Collection for
[if (condition) item]                // Collection if

// Map
{'key': 'value'}
{...map1, ...map2}                   // Spread

// Set
{1, 2, 3}
```

### Async

```dart
// Future
Future<T> asyncFunction() async { ... }
await future;

// Stream
Stream<T> streamFunction() async* { yield value; }
await for (var item in stream) { ... }
```

### Class

```dart
class MyClass {
  final String field;
  const MyClass(this.field);

  factory MyClass.fromJson(Map<String, dynamic> json) { ... }

  MyClass copyWith({String? field}) { ... }
}
```

---

## Practice Exercises

### Exercise 1: Type System (15 minutes)

Convert this TypeScript code to Dart:

```typescript
interface User {
  id: string;
  name: string;
  age: number;
  email?: string;
}

const user: User = {
  id: "123",
  name: "Alice",
  age: 25
};

function greetUser(user: User): string {
  return `Hello, ${user.name}!`;
}
```

<details>
<summary>Solution</summary>

```dart
class User {
  final String id;
  final String name;
  final int age;
  final String? email;

  const User({
    required this.id,
    required this.name,
    required this.age,
    this.email,
  });
}

final user = User(
  id: '123',
  name: 'Alice',
  age: 25,
);

String greetUser(User user) {
  return 'Hello, ${user.name}!';
}
```
</details>

---

### Exercise 2: Null Safety (20 minutes)

Convert and handle null safety:

```typescript
function getUserDisplayName(user: User | null): string {
  if (user === null) {
    return "Guest";
  }
  return user.name.toUpperCase();
}

const displayName = user?.name ?? "Anonymous";
```

<details>
<summary>Solution</summary>

```dart
String getUserDisplayName(User? user) {
  if (user == null) {
    return 'Guest';
  }
  return user.name.toUpperCase();
}

// Or more concise
String getUserDisplayName(User? user) {
  return user?.name.toUpperCase() ?? 'Guest';
}

final displayName = user?.name ?? 'Anonymous';
```
</details>

---

### Exercise 3: Async Operations (30 minutes)

Convert this async TypeScript code:

```typescript
async function fetchUserData(userId: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${userId}`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching user:', error);
    throw error;
  }
}

// Usage
const user = await fetchUserData("123");
```

<details>
<summary>Solution</summary>

```dart
Future<User> fetchUserData(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('/api/users/$userId'),
    );
    final data = jsonDecode(response.body);
    return User.fromJson(data);
  } catch (error) {
    debugPrint('Error fetching user: $error');
    rethrow;
  }
}

// Usage
final user = await fetchUserData('123');
```
</details>

---

### Exercise 4: Collections & Transformations (20 minutes)

Convert this list processing code:

```typescript
const expenses = [
  { amount: 100, category: "food" },
  { amount: 50, category: "transport" },
  { amount: 200, category: "food" },
];

const foodExpenses = expenses
  .filter(e => e.category === "food")
  .map(e => e.amount);

const total = foodExpenses.reduce((sum, amount) => sum + amount, 0);
```

<details>
<summary>Solution</summary>

```dart
final expenses = [
  {'amount': 100, 'category': 'food'},
  {'amount': 50, 'category': 'transport'},
  {'amount': 200, 'category': 'food'},
];

final foodExpenses = expenses
    .where((e) => e['category'] == 'food')
    .map((e) => e['amount'] as int)
    .toList();

final total = foodExpenses.reduce((sum, amount) => sum + amount);

// Or more concise
final total = expenses
    .where((e) => e['category'] == 'food')
    .fold<int>(0, (sum, e) => sum + (e['amount'] as int));
```
</details>

---

### Exercise 5: Build a Complete Class (45 minutes)

Create an `Expense` class with:
- Properties: `id`, `amount`, `category`, `date`
- Constructor with named parameters
- `fromJson` factory constructor
- `toJson` method
- `copyWith` method
- Override `toString()`

<details>
<summary>Solution</summary>

```dart
class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, category: $category, date: $date)';
  }
}

// Usage
final expense = Expense(
  id: '1',
  amount: 100.0,
  category: 'food',
  date: DateTime.now(),
);

final json = expense.toJson();
final expenseFromJson = Expense.fromJson(json);
final updatedExpense = expense.copyWith(amount: 150.0);

print(expense);
```
</details>

---

## Next Steps

Great job! You now understand Dart fundamentals from a TypeScript perspective.

**Next Module:** [03: Riverpod State Management →](03-riverpod-state-management.md)

In the next module, you'll learn Riverpod state management and how it compares to React hooks, Context API, and Redux.

---

## Summary Checklist

- [ ] I understand Dart's basic syntax and type system
- [ ] I can work with null safety operators (?., ??, !)
- [ ] I know the difference between final, const, and var
- [ ] I can create classes with constructors and methods
- [ ] I understand Future and Stream for async operations
- [ ] I can work with List, Map, and Set collections
- [ ] I know Dart-specific features (cascade, collection if/for)
- [ ] I can read and write code in the Whisp project

**Ready?** Continue to [Module 03: Riverpod State Management](03-riverpod-state-management.md)
