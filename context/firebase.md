# Firebase Integration - Whisp Finance Tracker

**Firebase SDK**: Version 11+  
**Services Used**: Authentication, Cloud Firestore, Cloud Storage

---

## Firebase Configuration

Configuration is auto-generated via FlutterFire CLI:
```bash
flutterfire configure
```

Initialization in `main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## Cloud Firestore Structure (EMPHASIS)

### User-Scoped Collections

```
users/{userId}/
  expenses/{expenseId}
    - createdAt: Timestamp
    - spentAt: Timestamp
    - spentPlace: String
    - items: Array<{itemName, spentType, quantity, cost, value, tax}>
    - totalValue: Number
    - paymentSource: String
    - currency: String
    - inputMethod: 'image'|'voice'|'manual'
    - imageUrl?: String
    - receiptImages?: Array<String>
    - aiConfidence?: Number

  paymentSources/{sourceId}
    - name: String
    - isActive: Boolean
    - createdAt: Timestamp

  spentTypes/{typeId}
    - name: String
    - color: String
    - icon: String
    - isActive: Boolean
    - createdAt: Timestamp

  placeNames/{placeId}
    - name: String
    - isActive: Boolean
    - createdAt: Timestamp

  itemNames/{itemId}
    - name: String
    - isActive: Boolean
    - createdAt: Timestamp

  budgets/{budgetId}
    - category: String
    - limit: Number
    - period: String
```

### Common Firestore Patterns (EMPHASIS)

#### Real-time Streams with StreamProvider
```dart
Stream<List<Expense>> streamExpenses(String userId) {
  return FirebaseFirestore.instance
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
```

#### CRUD with Error Handling
```dart
Future<void> addExpense(String userId, Expense expense) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add(expense.toFirestore());
  } on FirebaseException catch (e) {
    debugPrint('Firebase error: ${e.code}');
    rethrow;
  }
}
```

#### Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
    }
  }
}
```

---

## Firebase Authentication

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _initializeUserData(credential.user!.uid);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found';
      case 'wrong-password': return 'Incorrect password';
      case 'email-already-in-use': return 'Email already registered';
      default: return 'Auth error: ${e.message}';
    }
  }
}
```

### Riverpod Integration
```dart
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
```

---

## Firebase Storage

### Upload Receipt Images
```dart
Future<String> uploadReceiptImage(String userId, File imageFile) async {
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'receipts/${timestamp}.jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('users/$userId/$fileName');
    
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  } on FirebaseException catch (e) {
    debugPrint('Storage error: ${e.code}');
    rethrow;
  }
}
```

---

**Document Version**: 1.0
