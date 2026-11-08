import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:whisper_finance_tracker/utils/test_keys.dart';

import 'helpers/app_harness.dart';

// Filled from .ship.defines.json via --dart-define-from-file. Never put the
// test account in code.
const testEmail = String.fromEnvironment('TEST_EMAIL');
const testPassword = String.fromEnvironment('TEST_PASSWORD');

String? _skipReason() {
  final missing = [
    if (testEmail.isEmpty) 'TEST_EMAIL',
    if (testPassword.isEmpty) 'TEST_PASSWORD',
  ];
  if (missing.isEmpty) return null;
  return 'Missing dart-define ${missing.join(' and ')}. Fill the test account '
      'in .ship.defines.json and run with '
      '--dart-define-from-file=.ship.defines.json.';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // `testWidgets` only takes `skip: bool`; `group` also accepts a reason.
  group('login', () {
    testWidgets('signs in with the test account and signs out', (tester) async {
      // Leave the device signed out even when a step below fails.
      addTearDown(signOutIfSignedIn);
      final semantics = tester.ensureSemantics();

      await startApp(tester);
      await ensureSignedOut(tester);

      await tester.enterText(loginEmailField, testEmail);
      await tester.enterText(loginPasswordField, testPassword);
      FocusManager.instance.primaryFocus?.unfocus();
      await waitForTransition(tester);
      await tester.ensureVisible(loginSignInButton);
      await tester.pump();
      await tester.tap(loginSignInButton);

      await pumpUntilFound(
        tester,
        homeAddButton,
        waitingFor: 'the home screen after sign-in (check the test account)',
      );
      expectKeyWithLabel(tester, TestKeys.homeExpensesTab, 'Expenses tab');
      expectKeyWithLabel(tester, TestKeys.homeAnalyticsTab, 'Analytics tab');
      expectKeyWithLabel(tester, TestKeys.homeAddButton, 'Add expense');
      expectKeyWithLabel(tester, TestKeys.homeProfileButton, 'Profile');

      await tester.tap(find.byKey(TestKeys.homeProfileButton));
      final logoutButton = find.byKey(TestKeys.profileLogoutButton);
      await pumpUntilFound(
        tester,
        logoutButton,
        waitingFor: 'the profile screen',
      );
      await waitForTransition(tester);
      await tester.ensureVisible(logoutButton);
      await tester.pump();
      expectKeyWithLabel(tester, TestKeys.profileLogoutButton, 'Logout');
      await tester.tap(logoutButton);

      final confirmButton = find.byKey(TestKeys.logoutConfirmButton);
      await pumpUntilFound(
        tester,
        confirmButton,
        waitingFor: 'the logout dialog',
      );
      await waitForTransition(tester);
      expectKeyWithLabel(
        tester,
        TestKeys.logoutConfirmButton,
        'Confirm logout',
      );
      await tester.tap(confirmButton);

      await pumpUntil(
        tester,
        () => FirebaseAuth.instance.currentUser == null,
        waitingFor: 'Firebase to sign out',
      );

      // Current app behaviour: logout does not close the profile page. The
      // login screen is built under it and shows once the page is popped,
      // as the Android back button would do.
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .popUntil((route) => route.isFirst);

      await pumpUntilFound(
        tester,
        loginEmailField,
        waitingFor: 'the login screen after logout',
      );
      expectLoginScreen();

      semantics.dispose();
    });
  }, skip: _skipReason());
}
