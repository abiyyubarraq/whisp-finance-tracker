# Module 11: Exercises & Challenges

**Duration:** Variable (10-40 hours) | **Difficulty:** All Levels | **Prerequisites:** All previous modules

## 🎯 Goals

- Reinforce learning through hands-on practice
- Build real features from scratch
- Gain confidence in Flutter development
- Achieve independence: rebuild Whisp without AI help

---

## 📋 Exercise Categories

1. [Warm-up Exercises](#warm-up-exercises) - Quick practice (30-60 min each)
2. [Feature Implementations](#feature-implementations) - Medium complexity (2-4 hours each)
3. [Mini Projects](#mini-projects) - Complete features (4-8 hours each)
4. [Final Challenge](#final-challenge) - Rebuild major functionality (8-16 hours)

---

## Warm-up Exercises

### Exercise 1: Category Color Picker (45 minutes)

**Goal:** Add a color picker for expense categories

**Requirements:**
1. Add color field to SpentType model
2. Create color picker widget (use `flutter_colorpicker` package)
3. Allow users to customize category colors
4. Display colored icons in category dropdown
5. Save color to Firestore

**Files to modify:**
- `lib/models/spent_type.dart`
- `lib/screens/manage_data_screen.dart`

**Hints:**
```dart
// Add to SpentType model
final String colorHex; // Store as "#FF5733"

// Convert to Color
Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xff')));
```

---

### Exercise 2: Expense Search (60 minutes)

**Goal:** Add search functionality to expense list

**Requirements:**
1. Add search bar in app bar
2. Filter expenses by place name or item name
3. Debounce search input (wait 300ms after typing stops)
4. Show "No results" state when search returns empty
5. Clear search button

**Files to modify:**
- `lib/screens/expense_list_screen.dart`

**Hints:**
```dart
import 'dart:async';

Timer? _debounce;

void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () {
    setState(() {
      _searchQuery = query;
    });
  });
}
```

---

### Exercise 3: Export to CSV (90 minutes)

**Goal:** Export expenses to CSV file

**Requirements:**
1. Create ExportService with `exportToCSV` method
2. Generate CSV with columns: Date, Place, Items, Total, Payment Source
3. Use `path_provider` to save file
4. Use `share_plus` to share file
5. Add export button in expense list screen
6. Show success notification with file path

**Packages needed:**
```yaml
dependencies:
  csv: ^6.0.0
  path_provider: ^2.1.0
  share_plus: ^7.0.0
```

**Hints:**
```dart
import 'package:csv/csv.dart';
import 'dart:io';

Future<File> exportToCSV(List<Expense> expenses) async {
  List<List<dynamic>> rows = [
    ['Date', 'Place', 'Items', 'Total', 'Payment'],
  ];

  for (var expense in expenses) {
    rows.add([
      expense.spentAt.toString(),
      expense.spentPlace,
      expense.items.map((i) => i.name).join(', '),
      expense.totalValue,
      expense.paymentSource,
    ]);
  }

  String csv = const ListToCsvConverter().convert(rows);
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.csv');
  return await file.writeAsString(csv);
}
```

---

## Feature Implementations

### Feature 1: Recurring Expenses (3-4 hours)

**Goal:** Add support for recurring expenses (daily, weekly, monthly)

**Requirements:**
1. Create `RecurringExpense` model with:
   - All expense fields
   - Recurrence pattern (daily, weekly, monthly)
   - Start date and end date (optional)
   - Next occurrence date
2. Create `RecurringExpenseService`
3. Create screen to add/manage recurring expenses
4. Background service to create expenses automatically
5. Notification when recurring expense is created

**Architecture:**
```
lib/
├── models/
│   └── recurring_expense.dart
├── services/
│   └── recurring_expense_service.dart
├── screens/
│   ├── recurring_expenses_screen.dart
│   └── add_recurring_expense_screen.dart
```

**Bonus:**
- Skip occurrences
- Edit future occurrences
- View history of created expenses

---

### Feature 2: Budget Alerts (2-3 hours)

**Goal:** Notify users when approaching budget limits

**Requirements:**
1. Enhance `BudgetService` to calculate spending percentage
2. Create notification when 80% of budget is reached
3. Create notification when budget is exceeded
4. Show visual indicators (colors) in budget screen
5. Add settings to enable/disable alerts

**Visual indicators:**
- Green: < 60% of budget
- Yellow: 60-80% of budget
- Orange: 80-100% of budget
- Red: > 100% (exceeded)

**Files to create/modify:**
- `lib/services/budget_service.dart` (enhance)
- `lib/services/notification_service.dart` (enhance)
- `lib/widgets/budget/budget_progress_card.dart` (new)

---

### Feature 3: Expense Statistics (3-4 hours)

**Goal:** Create detailed statistics screen

**Requirements:**
1. Total spending by category (pie chart)
2. Spending trend over time (line chart)
3. Top spending locations
4. Average daily/weekly/monthly spending
5. Comparison with previous period
6. Date range selector

**Packages:**
```yaml
dependencies:
  fl_chart: ^0.66.0
```

**Charts to create:**
- Pie chart for category distribution
- Line chart for spending trend
- Bar chart for top locations

**Files to create:**
- `lib/screens/statistics_screen.dart`
- `lib/widgets/statistics/pie_chart_widget.dart`
- `lib/widgets/statistics/line_chart_widget.dart`
- `lib/widgets/statistics/bar_chart_widget.dart`

---

## Mini Projects

### Project 1: Complete Categories Management (4-6 hours)

**Goal:** Build a full CRUD system for expense categories

**Requirements:**

**Part 1: Model & Service (1 hour)**
1. Review `SpentType` model
2. Implement all CRUD methods in `SpentTypeService`
3. Add provider in `user_data_provider.dart`

**Part 2: List Screen (2 hours)**
1. Create `ManageCategoriesScreen`
2. Display all categories with icons and colors
3. Add search functionality
4. Show active/inactive status
5. Swipe to delete gesture
6. Pull to refresh

**Part 3: Add/Edit Screen (1-2 hours)**
1. Create `CategoryFormScreen`
2. Icon picker (from Material icons)
3. Color picker
4. Name validation
5. Save to Firestore

**Part 4: Polish (1 hour)**
1. Empty state when no categories
2. Loading shimmer
3. Error handling
4. Confirmation dialogs
5. Success/error notifications

**Deliverables:**
- Working categories management
- Clean UI following Material 3
- All best practices implemented
- Code review checklist completed

---

### Project 2: Expense Attachments (5-7 hours)

**Goal:** Allow users to attach multiple photos to expenses

**Requirements:**

**Part 1: Storage Integration (2 hours)**
1. Enhance `ExpenseService` to handle multiple images
2. Implement batch upload to Firebase Storage
3. Store image URLs in expense document
4. Implement image deletion

**Part 2: Image Picker UI (2 hours)**
1. Multi-image picker (camera + gallery)
2. Image preview grid
3. Remove image before upload
4. Upload progress indicator
5. Compress images before upload

**Part 3: Image Viewer (1-2 hours)**
1. Full-screen image viewer
2. Swipe between images
3. Zoom and pan
4. Delete image (with confirmation)
5. Share image

**Part 4: Integration (1-2 hours)**
1. Integrate with manual input tab
2. Integrate with expense detail screen
3. Update expense edit functionality
4. Handle offline mode

**Packages:**
```yaml
dependencies:
  image_picker: ^1.0.0
  photo_view: ^0.14.0
  flutter_image_compress: ^2.0.0
```

---

### Project 3: Offline Mode (6-8 hours)

**Goal:** Allow app to work without internet connection

**Requirements:**

**Part 1: Local Database (3 hours)**
1. Set up Hive or Drift for local storage
2. Create local expense cache
3. Sync strategy: local-first with cloud backup
4. Detect online/offline status

**Part 2: Sync Logic (2-3 hours)**
1. Queue pending operations (add, update, delete)
2. Auto-sync when online
3. Conflict resolution strategy
4. Sync status indicator

**Part 3: UI Adaptations (1-2 hours)**
1. Show offline banner
2. Indicate unsync data (badge/icon)
3. Manual sync button
4. Sync progress indicator

**Packages:**
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^5.0.0
```

---

## Final Challenge

### Rebuild Expense List Screen (8-12 hours)

**Goal:** Rebuild the complete expense list screen from scratch without looking at existing code

**Requirements:**

**Phase 1: Planning (1 hour)**
1. Sketch UI on paper
2. List required features
3. Plan component hierarchy
4. Identify providers needed

**Phase 2: Core Functionality (3-4 hours)**
1. Create expense list screen
2. Fetch expenses from StreamProvider
3. Display expenses in ListView.builder
4. Handle loading, error, and empty states
5. Navigate to expense detail on tap

**Phase 3: Filtering (2-3 hours)**
1. Category filter
2. Date range filter
3. Payment source filter
4. Search functionality
5. Filter UI (chips, bottom sheet, etc.)

**Phase 4: Actions (1-2 hours)**
1. Delete expense (with confirmation)
2. Edit expense
3. Share expense
4. Pull to refresh

**Phase 5: Polish (1-2 hours)**
1. Smooth animations
2. Loading shimmer
3. Empty state illustration
4. Error retry functionality
5. Responsive design

**Phase 6: Testing (1 hour)**
1. Test all filters
2. Test edge cases (no data, error states)
3. Test navigation
4. Test deletion
5. Verify best practices

**Success Criteria:**
- [ ] All features working
- [ ] Code follows best practices
- [ ] No code duplication
- [ ] Error handling implemented
- [ ] User feedback for all actions
- [ ] Responsive design
- [ ] Smooth animations
- [ ] Code is readable and maintainable

---

## Code Review Practice

### Review Checklist

Use this checklist to review your own code or practice with existing project code:

**Architecture:**
- [ ] Proper separation of concerns (models, services, providers, screens)
- [ ] No business logic in widgets
- [ ] Services handle Firebase operations
- [ ] Providers manage state

**Code Quality:**
- [ ] No code duplication
- [ ] Functions are small and focused
- [ ] Variables have meaningful names
- [ ] Comments explain "why", not "what"

**Error Handling:**
- [ ] Try-catch blocks around async operations
- [ ] User-friendly error messages
- [ ] Graceful degradation (fallback values)

**User Experience:**
- [ ] Loading indicators for all async operations
- [ ] Success/error notifications
- [ ] Confirmation dialogs for destructive actions
- [ ] Empty states with helpful messages

**Performance:**
- [ ] `const` constructors where possible
- [ ] `ListView.builder` for long lists
- [ ] Avoid unnecessary rebuilds
- [ ] Images are compressed

**Security:**
- [ ] No hardcoded secrets
- [ ] Input validation
- [ ] Data sanitization
- [ ] Firebase security rules implemented

---

## Final Project: Add Your Own Feature

**Goal:** Design and implement a completely new feature of your choice

**Ideas:**
- Expense categories with subcategories
- Split expenses with friends
- Receipt OCR with multiple languages
- Savings goals tracker
- Bill reminders
- Expense templates
- Location-based expense tracking
- Integration with bank APIs

**Process:**
1. **Plan** (2-3 hours)
   - Define feature requirements
   - Design data models
   - Sketch UI mockups
   - Plan architecture

2. **Implement** (10-20 hours)
   - Create models
   - Build services
   - Set up providers
   - Build UI screens
   - Integrate with existing app

3. **Polish** (2-4 hours)
   - Add animations
   - Improve error handling
   - Add loading states
   - Write documentation

4. **Test** (2-3 hours)
   - Manual testing
   - Edge cases
   - Error scenarios
   - Performance

---

## Completion Milestone

### You've Mastered Flutter When:

- [ ] You can read and understand all code in Whisp project
- [ ] You can add new features without guidance
- [ ] You instinctively follow best practices
- [ ] You can explain architectural decisions
- [ ] You can debug errors efficiently
- [ ] You think in widgets and providers
- [ ] You can rebuild core features from scratch
- [ ] You feel confident starting new Flutter projects

---

## Next Steps

### Continue Learning:
1. **Flutter Advanced Topics**
   - Animations and transitions
   - Custom painters
   - Platform channels
   - Testing (unit, widget, integration)

2. **Firebase Advanced Features**
   - Cloud Functions
   - Remote Config
   - Analytics
   - Crashlytics

3. **Architecture Patterns**
   - Clean Architecture deep dive
   - MVVM pattern
   - BLoC pattern
   - Repository pattern

4. **Real-World Skills**
   - CI/CD pipelines
   - App store deployment
   - Performance profiling
   - Monitoring and analytics

### Resources:
- [Flutter Official Docs](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Flutter Documentation](https://firebase.flutter.dev)
- [Flutter Community](https://flutter.dev/community)

---

## Congratulations! 🎉

You've completed the Whisp Finance Tracker Learning Guide!

You now have the skills to:
- Build production-ready Flutter apps
- Integrate Firebase services
- Implement clean architecture
- Follow best practices
- Work with AI APIs
- Create beautiful UIs with Material 3

**Most importantly:** You can rebuild this project from scratch!

Keep practicing, keep building, and welcome to the Flutter community! 🚀

---

**Return to:** [Learning Guide Index](00-index.md)
