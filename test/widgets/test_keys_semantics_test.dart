import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisper_finance_tracker/screens/auth/login_screen.dart';
import 'package:whisper_finance_tracker/utils/test_keys.dart';
import 'package:whisper_finance_tracker/widgets/common/gradient_action_button.dart';
import 'package:whisper_finance_tracker/widgets/common/logout_dialog.dart';

// Plain ThemeData instead of AppTheme: AppTheme loads Google Fonts over the
// network, which unit tests must not do.
Widget _app(Widget home, {ThemeMode themeMode = ThemeMode.light}) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: home,
    ),
  );
}

void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('login screen exposes keys and labels in ${themeMode.name} '
        'theme', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(const LoginScreen(), themeMode: themeMode));

      expect(find.byKey(TestKeys.loginEmailField), findsOneWidget);
      expect(find.byKey(TestKeys.loginPasswordField), findsOneWidget);
      expect(find.byKey(TestKeys.loginSignInButton), findsOneWidget);

      // Exact matches: a label read twice (for example "Sign in\nSign In")
      // would not match.
      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      expect(find.bySemanticsLabel('Password'), findsOneWidget);
      expect(find.bySemanticsLabel('Sign in'), findsOneWidget);
      expect(
        tester.getSemantics(find.byKey(TestKeys.loginSignInButton)),
        containsSemantics(label: 'Sign in', isButton: true, hasTapAction: true),
      );

      semantics.dispose();
    });
  }

  testWidgets('email field key targets the email input', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen()));

    await tester.enterText(
      find.byKey(TestKeys.loginEmailField),
      'someone@example.com',
    );
    await tester.enterText(
      find.byKey(TestKeys.loginPasswordField),
      'typed-password',
    );

    expect(find.text('someone@example.com'), findsOneWidget);
    expect(find.text('typed-password'), findsOneWidget);
  });

  testWidgets('gradient action button uses its semantic label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: GradientActionButton(
            key: TestKeys.homeProfileButton,
            icon: Icons.person_rounded,
            semanticLabel: 'Profile',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byKey(TestKeys.homeProfileButton)),
      containsSemantics(label: 'Profile', isButton: true, hasTapAction: true),
    );

    semantics.dispose();
  });

  testWidgets('logout dialog confirm button has a key and label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TextButton(
              onPressed: () => showLogoutDialog(context, ref),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byKey(TestKeys.logoutConfirmButton), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(TestKeys.logoutConfirmButton)),
      containsSemantics(
        label: 'Confirm logout',
        isButton: true,
        hasTapAction: true,
      ),
    );

    semantics.dispose();
  });
}
