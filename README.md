# Whisp Finance Tracker

A cross-platform Flutter mobile application for financial expense tracking with AI-powered data extraction, Firebase backend, and glassmorphism UI design with dark/light theme support.

## Features

- 🔐 **Authentication**: Email/password authentication with Firebase
- 📸 **Image Input**: Scan receipts using Gemini Vision API
- 🎤 **Voice Input**: Record voice descriptions of expenses
- ✍️ **Manual Input**: Traditional form-based expense entry
- 📊 **Analytics**: Visual charts and spending insights
- 💰 **Budget Tracking**: Set and monitor budgets with alerts
- 🎨 **Glassmorphism UI**: Modern glassmorphic design with dark/light themes
- 📤 **Export**: Export expenses to Excel and PDF
- 🔔 **Notifications**: Budget alerts and daily reminders

## Prerequisites

- Flutter SDK 3.38+ (Stable)
- Dart 3.2+
- Firebase project
- Google Gemini API key

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Configuration

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase:
```bash
flutterfire configure
```

This will generate the `lib/firebase_options.dart` file automatically.

3. Set up Firebase services:
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Set up Firebase Storage
   - Configure Firestore security rules (see below)

### 3. Firestore Security Rules

Add these rules to your Firestore database:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 4. Environment Variables

Set your Gemini API key when running the app:

**For Development:**
```bash
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

**For Release Build:**
```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=your_api_key_here
flutter build ios --release --dart-define=GEMINI_API_KEY=your_api_key_here
```

Alternatively, you can modify `lib/config/env.dart` to use a different method for storing the API key.

### 5. Platform-Specific Setup

#### Android

1. Add permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

#### iOS

1. Add permissions to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to scan receipts</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record voice expenses</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select receipt images</string>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   ├── theme.dart           # Theme configuration
│   └── env.dart             # Environment variables
├── models/
│   ├── expense.dart         # Expense data model
│   ├── budget.dart          # Budget data model
│   ├── expense_data.dart    # AI extraction data model
│   ├── payment_source.dart  # Payment source model
│   └── spent_type.dart     # Expense category model
├── providers/
│   ├── auth_provider.dart   # Authentication state
│   └── theme_provider.dart  # Theme state
├── screens/
│   ├── auth/                # Authentication screens
│   ├── input_tabs/          # Expense input tabs
│   ├── main_screen.dart     # Main navigation
│   ├── expense_list_screen.dart
│   ├── analytics_screen.dart
│   ├── profile_screen.dart
│   └── add_expense_modal.dart
├── services/
│   ├── auth_service.dart    # Authentication logic
│   ├── gemini_service.dart # AI extraction
│   ├── export_service.dart # Export functionality
│   ├── budget_service.dart  # Budget management
│   └── notification_service.dart
├── widgets/
│   ├── glass_container.dart # Glassmorphism widget
│   ├── expense_card.dart    # Expense list item
│   ├── theme_toggle.dart    # Theme switcher
│   └── confirm_expense_form.dart
└── utils/
    ├── constants.dart       # Default data
    ├── filter_sort.dart     # Filter/sort utilities
    └── test_keys.dart       # Widget keys used by tests

test/                        # Unit and widget tests (offline)
integration_test/            # On-device tests (real Firebase, test account)
└── helpers/                 # Shared start / wait / sign-out helpers
.maestro/                    # Maestro UI flows
```

## Usage

### Adding Expenses

1. **Image Input**: Tap the camera icon, take/select a receipt photo, and let AI extract the data
2. **Voice Input**: Hold the microphone button, describe your expense, and AI will process it
3. **Manual Input**: Fill out the form with expense details manually

### Managing Data

- **Payment Sources**: Add/edit payment methods in Profile > Payment Sources
- **Categories**: Customize expense categories in Profile > Expense Categories
- **Budgets**: Set weekly/monthly budgets in Profile > Budgets

### Analytics

View spending insights, category breakdowns, and period comparisons in the Analytics tab.

## Default Data

On registration, users get:
- **Payment Sources**: Cash, Credit Card, Debit Card, Bank Transfer, E-Wallet
- **Categories**: Food, Coffee, Transportation, Utilities, Shopping, Entertainment, Health, Education, Other

## Testing

| Kind | Folder | Needs |
|---|---|---|
| Unit and widget tests | `test/` | Nothing. Runs offline, no Firebase. |
| Integration tests | `integration_test/` | Android emulator, Firebase config, `.ship.defines.json` |
| Maestro smoke flow | `.maestro/` | Android emulator, debug build installed, [Maestro CLI](https://maestro.mobile.dev) |

Integration tests use the real Firebase project. They sign in only with the test account and create no data. If a future test must create data, prefix it with `ship-test-` and delete it at the end.

### 1. Create `.ship.defines.json`

Create `.ship.defines.json` in the project root. It is git-ignored: never commit it. Use the test account only, never a real user's account.

```json
{
  "GEMINI_API_KEY": "<your Gemini API key>",
  "TEST_EMAIL": "<test account email>",
  "TEST_PASSWORD": "<test account password>"
}
```

Pass it to builds and tests with `--dart-define-from-file=.ship.defines.json`. The tests read the values with `String.fromEnvironment`, so nothing is hard-coded.

### 2. Unit and widget tests

```bash
flutter test
```

### 3. Integration tests (Android emulator)

```bash
flutter devices   # find the emulator id, for example emulator-5554

flutter test integration_test/app_smoke_test.dart -d <emulator> --dart-define-from-file=.ship.defines.json
flutter test integration_test/login_test.dart -d <emulator> --dart-define-from-file=.ship.defines.json
```

- `app_smoke_test.dart` starts the app, signs out any saved session, and checks the login screen.
- `login_test.dart` signs in with `TEST_EMAIL` / `TEST_PASSWORD`, checks the home screen, then logs out through Profile. When either value is empty, the test is **skipped** (not failed) and the skip reason names the missing value.

### 4. Maestro smoke flow

Install the debug build on the emulator first, then run the flow. `--target-platform android-x64` builds only for the x86_64 emulator, so the APK is much smaller and fits on an emulator with little free storage:

```bash
flutter build apk --debug --target-platform android-x64 --dart-define-from-file=.ship.defines.json
adb install -r build/app/outputs/flutter-apk/app-debug.apk

maestro test .maestro/smoke.yaml
# with more than one device connected:
maestro --device <emulator> test .maestro/smoke.yaml
```

The flow clears the app data first (`clearState`), so it always starts signed out, and checks that the login screen shows.

### Keys and labels for tests

Widgets that tests need have a key in `lib/utils/test_keys.dart` (for Flutter tests) and a screen reader label (for Maestro, which matches labels and visible text).

| Screen | Key (`TestKeys.`) | Label |
|---|---|---|
| Login | `loginEmailField`, `loginPasswordField` | `Email`, `Password` (from the field hint) |
| Login | `loginSignInButton` | `Sign in` |
| Home | `homeExpensesTab`, `homeAnalyticsTab` | `Expenses tab`, `Analytics tab` |
| Home | `homeAddButton`, `homeProfileButton` | `Add expense`, `Profile` |
| Profile | `profileLogoutButton` | `Logout` |
| Logout dialog | `logoutConfirmButton` | `Confirm logout` |

## Troubleshooting

### Firebase Errors
- Ensure `firebase_options.dart` is properly generated
- Check Firebase project configuration
- Verify security rules are set correctly

### Gemini API Errors
- Verify API key is correct
- Check API quota limits
- Ensure internet connection is available

### Build Errors
- Run `flutter clean` and `flutter pub get`
- Check Flutter and Dart versions
- Verify all dependencies are compatible

## Contributing

This is a complete implementation. Feel free to extend with:
- Additional chart types
- More export formats
- Home screen widgets
- Advanced filtering options
- Multi-currency support enhancements

## License

This project is provided as-is for educational and development purposes.
