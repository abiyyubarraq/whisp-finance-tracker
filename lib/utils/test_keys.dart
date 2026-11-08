import 'package:flutter/widgets.dart';

/// Stable widget keys that integration tests use to find widgets.
///
/// Keep each key on one widget only. Two widgets with the same key on screen
/// at the same time make `find.byKey` ambiguous.
class TestKeys {
  TestKeys._();

  static const loginEmailField = Key('login_email_field');
  static const loginPasswordField = Key('login_password_field');
  static const loginSignInButton = Key('login_sign_in_button');

  static const homeExpensesTab = Key('home_expenses_tab');
  static const homeAnalyticsTab = Key('home_analytics_tab');
  static const homeAddButton = Key('home_add_button');
  static const homeProfileButton = Key('home_profile_button');

  static const profileLogoutButton = Key('profile_logout_button');
  static const logoutConfirmButton = Key('logout_confirm_button');
}
