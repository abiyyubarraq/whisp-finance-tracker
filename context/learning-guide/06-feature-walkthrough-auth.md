# Module 06: Feature Walkthrough - Authentication

**Duration:** 2 hours | **Difficulty:** Intermediate | **Prerequisites:** Modules 01-05

## 🎯 Learning Objectives

- Understand complete authentication flow in Whisp
- Implement login and registration screens
- Manage auth state with Riverpod StreamProvider
- Create protected routes
- Handle auth errors gracefully

---

## Complete Auth Flow

```
Authentication Flow Sequence:

    User        LoginScreen     AuthService     Firebase     AuthProvider    MainScreen
     │               │               │              │              │             │
     │ 1. Enter      │               │              │              │             │
     │ credentials   │               │              │              │             │
     │──────────────>│               │              │              │             │
     │               │               │              │              │             │
     │               │ 2. Call       │              │              │             │
     │               │ signInWith    │              │              │             │
     │               │ Email()       │              │              │             │
     │               │──────────────>│              │              │             │
     │               │               │              │              │             │
     │               │               │ 3. Auth      │              │             │
     │               │               │ enticate     │              │             │
     │               │               │─────────────>│              │             │
     │               │               │              │              │             │
     │               │               │<─4. User ────│              │             │
     │               │               │  credential  │              │             │
     │               │               │              │              │             │
     │               │<─5. Return ───│              │              │             │
     │               │  User object  │              │              │             │
     │               │               │              │              │             │
     │               │               │              │ 6. Auth      │             │
     │               │               │              │ StateChanges │             │
     │               │               │              │ (stream)     │             │
     │               │               │              │─────────────>│             │
     │               │               │              │              │             │
     │               │               │              │              │ 7. Navigate │
     │               │               │              │              │ (automatic) │
     │               │               │              │              │────────────>│
     │               │               │              │              │             │

Flow Summary:
1. User enters email and password in LoginScreen
2. LoginScreen calls AuthService.signInWithEmail()
3. AuthService authenticates with Firebase
4. Firebase returns user credential
5. AuthService returns User object to LoginScreen
6. Firebase emits authStateChanges() stream event
7. AuthProvider listens to stream and automatically navigates to MainScreen
```

## Auth Service Implementation

See [lib/services/auth_service.dart](../lib/services/auth_service.dart):

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email/password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Error handling
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Sign out
  Future<void> signOut() async => await _auth.signOut();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

## Auth State Provider

See [lib/providers/auth_provider.dart](../lib/providers/auth_provider.dart):

```dart
// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
```

## Login Screen

See [lib/screens/auth/login_screen.dart](../lib/screens/auth/login_screen.dart):

```dart
class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      // Navigation handled by AuthGate
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

## Protected Routes (AuthGate Pattern)

```dart
class AuthGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return MainScreen(); // User logged in
        }
        return LoginScreen(); // Not logged in
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

// In main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(), // Entry point
    );
  }
}
```

## React Comparison

**React with Context:**
```typescript
const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  const login = async (email: string, password: string) => {
    await signInWithEmailAndPassword(auth, email, password);
  };

  return { user, loading, login };
};
```

**Flutter with Riverpod is cleaner:**
- No manual subscription/unsubscription
- Automatic loading/error states
- Global state without Context wrapper

## Practice Exercise

**Task:** Add "Forgot Password" feature
1. Add `resetPassword(email)` method to AuthService
2. Create ForgotPasswordScreen
3. Handle success/error states
4. Test with Firebase

---

**Next Module:** [07: Feature Walkthrough - Expenses →](07-feature-walkthrough-expenses.md)
