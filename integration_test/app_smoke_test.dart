import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and shows the login screen', (tester) async {
    final semantics = tester.ensureSemantics();

    await startApp(tester);
    await ensureSignedOut(tester);

    expectLoginScreen();
    expect(find.bySemanticsLabel('Email'), findsOneWidget);
    expect(find.bySemanticsLabel('Password'), findsOneWidget);
    expect(find.bySemanticsLabel('Sign in'), findsOneWidget);

    semantics.dispose();
  });
}
