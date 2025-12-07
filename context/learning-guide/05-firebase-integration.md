# Module 05: Firebase Integration

**Duration:** 3-4 hours | **Difficulty:** Intermediate | **Prerequisites:** Modules 01-04

## 🎯 Learning Objectives

After this module, you will:
- Understand Firebase setup in Flutter vs Google Cloud Functions
- Implement Firebase Authentication patterns
- Perform Firestore CRUD operations
- Work with real-time Firestore streams
- Upload and manage files with Firebase Storage
- Understand basic security rules

---

## 📋 Table of Contents

1. [Firebase vs Google Cloud/Node.js](#firebase-vs-google-cloudnodejs)
2. [Firebase Setup](#firebase-setup)
3. [Authentication](#authentication)
4. [Firestore Database](#firestore-database)
5. [Firebase Storage](#firebase-storage)
6. [Real-time Streams](#real-time-streams)
7. [Security Rules](#security-rules)
8. [Quick Reference](#quick-reference)
9. [Practice Exercises](#practice-exercises)

---

## Firebase vs Google Cloud/Node.js

### Comparison Table

| Feature | Google Cloud Functions (Node.js) | Firebase Flutter |
|---------|----------------------------------|------------------|
| **Authentication** | Firebase Admin SDK | Firebase Auth Flutter |
| **Database** | Firestore Admin SDK (server-side) | Cloud Firestore Flutter (client-side) |
| **Storage** | Firebase Admin Storage | Firebase Storage Flutter |
| **Security** | Full access (admin) | Security Rules (user-level) |
| **Real-time** | Manual webhooks | Built-in snapshots |
| **API Style** | REST/GraphQL endpoints | Direct SDK calls |

### Architecture Difference

**Node.js Backend (Traditional):**
```
Client → REST API → Cloud Functions → Firestore
         (Authentication)  (Business Logic)
```

**Flutter + Firebase (Client-Side):**
```
Flutter App → Firebase SDK → Firestore
              (Auth + Security Rules)
```

**Key Insight:** Flutter apps connect **directly to Firebase**, with security rules enforcing access control. No custom backend needed for CRUD operations!

---

## Firebase Setup

### Configuration Files

**Node.js (serviceAccountKey.json):**
```json
{
  "type": "service_account",
  "project_id": "your-project",
  "private_key_id": "...",
  "private_key": "...",
  "client_email": "..."
}
```

**Flutter (firebase_options.dart - auto-generated):**
```dart
// lib/firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIza...',
    appId: '1:123:android:abc',
    messagingSenderId: '123',
    projectId: 'your-project',
    storageBucket: 'your-project.appspot.com',
  );
  // ... iOS, Web configs
}
```

### Initialize Firebase

**Node.js:**
```typescript
import admin from 'firebase-admin';
import serviceAccount from './serviceAccountKey.json';

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();
```

**Flutter:**
```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MyApp()));
}
```

**Key Difference:** Flutter uses platform-specific configurations, Node.js uses service account.

---

## Authentication

### Firebase Auth Patterns

#### Pattern 1: Email/Password Authentication

**Node.js (Admin SDK - Server):**
```typescript
// Create user (admin endpoint)
export const createUser = functions.https.onCall(async (data) => {
  const { email, password } = data;
  const userRecord = await admin.auth().createUser({
    email,
    password,
  });
  return { uid: userRecord.uid };
});

// Verify token (middleware)
export const verifyToken = async (idToken: string) => {
  const decodedToken = await admin.auth().verifyIdToken(idToken);
  return decodedToken.uid;
};
```

**Flutter (Client SDK):**
```dart
// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        throw 'Email already exists';
      }
      rethrow;
    }
  }

  // Sign in
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        throw 'Incorrect password';
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

#### Pattern 2: Google Sign-In

**Flutter:**
```dart
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }
}
```

### Auth State Management with Riverpod

**React Context equivalent:**
```typescript
// React: Auth Context
const AuthContext = createContext<User | null>(null);

const AuthProvider: React.FC = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, setUser);
    return unsubscribe;
  }, []);

  return <AuthContext.Provider value={user}>{children}</AuthContext.Provider>;
};
```

**Flutter Riverpod:**
```dart
// lib/providers/auth_provider.dart
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Usage in any widget
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return Text('Hello, ${user.email}');
        }
        return Text('Not logged in');
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

## Firestore Database

### CRUD Operations Comparison

#### Create (Add Document)

**Node.js:**
```typescript
// Cloud Function
export const addExpense = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) throw new Error('Unauthorized');

  const expense = {
    userId: uid,
    amount: data.amount,
    date: admin.firestore.FieldValue.serverTimestamp(),
  };

  const docRef = await admin.firestore()
    .collection('expenses')
    .add(expense);

  return { id: docRef.id };
});
```

**Flutter:**
```dart
// lib/services/expense_service.dart
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

**Key Difference:** Flutter app directly writes to Firestore. Security rules enforce access control.

#### Read (Get Documents)

**Node.js:**
```typescript
export const getExpenses = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) throw new Error('Unauthorized');

  const snapshot = await admin.firestore()
    .collection('expenses')
    .where('userId', '==', uid)
    .get();

  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
});
```

**Flutter:**
```dart
Future<List<Expense>> getExpenses(String userId) async {
  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromFirestore(doc))
        .toList();
  } catch (e) {
    debugPrint('Error getting expenses: $e');
    rethrow;
  }
}
```

#### Update Document

**Node.js:**
```typescript
export const updateExpense = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  const { expenseId, updates } = data;

  await admin.firestore()
    .collection('expenses')
    .doc(expenseId)
    .update(updates);

  return { success: true };
});
```

**Flutter:**
```dart
Future<void> updateExpense(
  String userId,
  String expenseId,
  Expense expense,
) async {
  try {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .update(expense.toFirestore());
  } catch (e) {
    debugPrint('Error updating expense: $e');
    rethrow;
  }
}
```

#### Delete Document

**Flutter:**
```dart
Future<void> deleteExpense(String userId, String expenseId) async {
  try {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  } catch (e) {
    debugPrint('Error deleting expense: $e');
    rethrow;
  }
}
```

### Real Example from Whisp

```dart
// lib/services/expense_service.dart
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add expense with multiple items
  Future<String> addExpense(String userId, Expense expense) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .add(expense.toFirestore());

      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} - ${e.message}');
      throw 'Failed to add expense: ${e.message}';
    } catch (e) {
      debugPrint('Error adding expense: $e');
      throw 'Failed to add expense';
    }
  }

  // Get expenses with date filter
  Future<List<Expense>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('spentAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('spentAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting expenses: $e');
      rethrow;
    }
  }
}
```

---

## Firebase Storage

### Upload Files

**Node.js (Admin SDK):**
```typescript
import { Storage } from '@google-cloud/storage';

const storage = new Storage();
const bucket = storage.bucket('your-bucket');

export const uploadFile = async (file: Express.Multer.File) => {
  const blob = bucket.file(`images/${Date.now()}_${file.originalname}`);
  const stream = blob.createWriteStream({
    metadata: {
      contentType: file.mimetype,
    },
  });

  return new Promise((resolve, reject) => {
    stream.on('finish', async () => {
      const url = await blob.getSignedUrl({
        action: 'read',
        expires: '03-01-2500',
      });
      resolve(url[0]);
    });
    stream.on('error', reject);
    stream.end(file.buffer);
  });
};
```

**Flutter:**
```dart
// lib/services/expense_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ExpenseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadReceiptImage(String userId, File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('receipts')
          .child(fileName);

      // Upload file
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> deleteReceiptImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      rethrow;
    }
  }
}
```

### Real Example: Multiple Receipt Images

```dart
// Upload multiple images
Future<List<String>> uploadReceiptImages(
  String userId,
  List<File> imageFiles,
) async {
  final urls = <String>[];

  for (final file in imageFiles) {
    try {
      final url = await uploadReceiptImage(userId, file);
      urls.add(url);
    } catch (e) {
      debugPrint('Failed to upload image: $e');
      // Continue with other images
    }
  }

  return urls;
}
```

---

## Real-time Streams

### Firestore Snapshots

**React (Manual subscription):**
```typescript
useEffect(() => {
  const unsubscribe = firestore
    .collection('expenses')
    .where('userId', '==', userId)
    .onSnapshot(snapshot => {
      const expenses = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setExpenses(expenses);
    });

  return () => unsubscribe();
}, [userId]);
```

**Flutter with Riverpod (Automatic):**
```dart
// lib/providers/user_data_provider.dart
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('expenses')
      .orderBy('spentAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList());
});

// Usage (automatically updates UI)
class ExpenseList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    return expensesAsync.when(
      data: (expenses) => ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) => ExpenseCard(expense: expenses[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

**Benefits of Flutter approach:**
1. **Automatic subscription/unsubscription** - No manual cleanup
2. **Automatic rebuild** - UI updates when data changes
3. **Built-in loading/error states** - Use `.when()` method
4. **No race conditions** - Riverpod handles it

---

## Security Rules

### Firestore Rules

**Basic pattern:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data - only owner can access
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Expenses - only owner can access
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Payment sources - only owner can access
      match /paymentSources/{sourceId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

**Explanation:**
- `request.auth` - Current authenticated user
- `request.auth.uid` - User ID
- `{userId}` - Document ID wildcard
- Access only allowed if authenticated AND user owns the data

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/receipts/{imageId} {
      // Only owner can upload
      allow write: if request.auth != null && request.auth.uid == userId;

      // Only owner can read
      allow read: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Quick Reference

### Firebase Auth

```dart
// Sign up
await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

// Sign in
await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

// Sign out
await FirebaseAuth.instance.signOut();

// Current user
User? user = FirebaseAuth.instance.currentUser;

// Auth state stream
Stream<User?> authStream = FirebaseAuth.instance.authStateChanges();
```

### Firestore CRUD

```dart
// Get Firestore instance
final firestore = FirebaseFirestore.instance;

// Add document
await firestore.collection('expenses').add(data);

// Get document
DocumentSnapshot doc = await firestore.collection('expenses').doc(id).get();

// Update document
await firestore.collection('expenses').doc(id).update(data);

// Delete document
await firestore.collection('expenses').doc(id).delete();

// Query documents
QuerySnapshot snapshot = await firestore
    .collection('expenses')
    .where('amount', isGreaterThan: 100)
    .orderBy('date', descending: true)
    .limit(10)
    .get();

// Real-time stream
Stream<QuerySnapshot> stream = firestore.collection('expenses').snapshots();
```

### Firebase Storage

```dart
// Get storage instance
final storage = FirebaseStorage.instance;

// Upload file
TaskSnapshot uploadTask = await storage.ref('path/to/file').putFile(file);

// Get download URL
String url = await storage.ref('path/to/file').getDownloadURL();

// Delete file
await storage.ref('path/to/file').delete();
```

---

## Practice Exercises

### Exercise 1: Implement Authentication (60 minutes)

Create a complete auth flow:
1. Login screen with email/password
2. Registration screen
3. Auth state management with Riverpod
4. Protected route example

---

### Exercise 2: CRUD Operations (60 minutes)

Build a simple note-taking feature:
1. Create Note model with fromFirestore/toFirestore
2. Create NoteService with CRUD methods
3. Create StreamProvider for real-time notes
4. Build UI to add, view, update, delete notes

---

### Exercise 3: Image Upload (45 minutes)

Implement image upload feature:
1. Pick image from gallery
2. Upload to Firebase Storage
3. Save URL to Firestore
4. Display image from URL

---

## Next Steps

**Next Module:** [06: Feature Walkthrough - Authentication →](06-feature-walkthrough-auth.md)

Deep dive into Whisp's complete authentication implementation.

---

## Summary Checklist

- [ ] I understand Firebase setup in Flutter
- [ ] I can implement email/password authentication
- [ ] I know how to perform Firestore CRUD operations
- [ ] I understand real-time streams with Riverpod
- [ ] I can upload files to Firebase Storage
- [ ] I understand basic security rules

**Continue to:** [Module 06: Feature Walkthrough - Authentication](06-feature-walkthrough-auth.md)
