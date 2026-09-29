import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisper_finance_tracker/main.dart' as app;
import 'package:whisper_finance_tracker/utils/test_keys.dart';

/// Emulator boot, Firebase and network calls can be slow, so waits are long.
const defaultTimeout = Duration(seconds: 30);

final loginEmailField = find.byKey(TestKeys.loginEmailField);
final loginPasswordField = find.byKey(TestKeys.loginPasswordField);
final loginSignInButton = find.byKey(TestKeys.loginSignInButton);
final homeAddButton = find.byKey(TestKeys.homeAddButton);

/// Pumps frames until [condition] is true, and fails the test after [timeout].
///
/// Use this instead of `pumpAndSettle`: the app shows endless loading
/// animations, so `pumpAndSettle` can wait forever.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required String waitingFor,
  Duration timeout = defaultTimeout,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out after ${timeout.inSeconds} s waiting for $waitingFor.');
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  required String waitingFor,
  Duration timeout = defaultTimeout,
}) {
  return pumpUntil(
    tester,
    () => finder.evaluate().isNotEmpty,
    waitingFor: waitingFor,
    timeout: timeout,
  );
}

/// Waits long enough for a page or dialog transition to finish, so the next
/// tap lands on a widget that is no longer moving.
Future<void> waitForTransition(WidgetTester tester) {
  return tester.pump(const Duration(seconds: 1));
}

/// Starts the real app (Firebase included) and waits for its first screen.
///
/// The first screen is the login screen, or the home screen when the device
/// still has a signed-in session from an earlier run.
Future<void> startApp(WidgetTester tester) async {
  app.main();
  await pumpUntil(
    tester,
    () =>
        loginEmailField.evaluate().isNotEmpty ||
        homeAddButton.evaluate().isNotEmpty,
    waitingFor: 'the login or home screen after app start',
  );
}

/// Signs out any session left on the device and waits for the login screen.
Future<void> ensureSignedOut(WidgetTester tester) async {
  await signOutIfSignedIn();
  await pumpUntilFound(
    tester,
    loginEmailField,
    waitingFor: 'the login screen after sign-out',
  );
}

Future<void> signOutIfSignedIn() async {
  if (Firebase.apps.isEmpty) return;
  if (FirebaseAuth.instance.currentUser != null) {
    await FirebaseAuth.instance.signOut();
  }
}

void expectLoginScreen() {
  expect(loginEmailField, findsOneWidget);
  expect(loginPasswordField, findsOneWidget);
  expect(loginSignInButton, findsOneWidget);
}

/// Checks that exactly one widget has [key] and that its semantics node has
/// [label]. Needs semantics on (`tester.ensureSemantics()`).
void expectKeyWithLabel(WidgetTester tester, Key key, String label) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  expect(tester.getSemantics(finder), containsSemantics(label: label));
}
