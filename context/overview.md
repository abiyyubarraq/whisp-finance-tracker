# Whisp Finance Tracker - Project Overview

**Whisp Finance Tracker** is an AI-powered expense tracking Flutter application designed for comprehensive personal finance management with multiple input methods, itemized expense tracking, budget management, and advanced analytics.

**Tech Stack**: Flutter 3.38+, Dart 3.2+, Riverpod 3.0+, Firebase 11+
**Platform**: Multi-platform (iOS, Android, Web, Desktop)
**Version**: 0.1.0 (Beta)

---

## Project Purpose

Whisp Finance Tracker simplifies personal expense tracking by offering:
- **AI-Powered Input**: Scan receipts or use voice commands for instant expense entry
- **Itemized Tracking**: Track individual items within each expense
- **Budget Management**: Set and monitor budgets per category
- **Smart Analytics**: Visual insights into spending patterns
- **Export Capabilities**: Generate Excel and PDF reports

---

## Core Architecture

### Key Architectural Decisions

1. **State Management**: Riverpod for reactive, declarative state management
2. **Backend**: Firebase ecosystem (Auth, Firestore, Storage)
3. **AI Integration**: Google Generative AI (Gemini) for OCR and voice transcription
4. **UI Framework**: Material 3 with custom glassmorphism design
5. **Architecture Pattern**: Clean Architecture with clear layer separation
6. **Data Flow**: Reactive streams via StreamProvider from Firestore

### Architectural Layers

- **Models**: Immutable data structures with Firestore serialization
- **Services**: Business logic and external integrations
- **Providers**: Riverpod state management and dependency injection
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **Utils**: Helper functions and constants

---

## Key Features

### 1. Multi-Input Expense Entry

**Three Input Methods**:

#### Image Input Tab
- Camera or gallery image selection
- Google Gemini Vision API for receipt OCR
- Automatic extraction of:
  - Store/merchant name
  - Date and time
  - Individual items with prices
  - Total amount
  - Currency
- Manual review and correction interface
- Receipt image storage in Firebase Storage

#### Voice Input Tab
- Audio recording with real-time feedback
- Google Gemini Audio API for transcription
- Natural language expense extraction
- Support for conversational input
- Review and edit before saving

#### Manual Input Tab
- Traditional form-based entry
- Support for itemized expenses (multiple items per transaction)
- Dynamic payment source selection
- Category/spent type selection
- Date and time pickers
- Currency selection
- Tax and quantity tracking per item

### 2. Itemized Expense Tracking

**ExpenseItem Model**:
- Individual item name
- Quantity
- Unit cost
- Total value
- Tax amount
- Spent type (category)

**Benefits**:
- Granular expense tracking
- Per-item categorization
- Detailed analytics by item type
- Better budget allocation insights

### 3. Expense Management

**Expense List Screen**:
- Chronological expense display
- Summary cards with period totals
- Filter by:
  - Date range (custom, week, month, year)
  - Payment source
  - Category (spent type)
  - Input method
- Sort by:
  - Date (newest/oldest)
  - Amount (highest/lowest)
  - Place (A-Z)
- Swipe actions (edit, delete)
- Detailed expense view with all items

**Features**:
- Real-time updates from Firestore
- Loading states (shimmer effects)
- Error states with retry
- Empty states with helpful messages
- Pull-to-refresh

### 4. Budget Tracking

**Budget Service**:
- Category-based budget limits
- Period-based tracking (daily, weekly, monthly, yearly)
- Budget vs actual comparison
- Warning alerts when approaching limits
- Budget suggestions based on spending patterns

**Implementation**:
- Firestore-based budget storage
- Real-time budget monitoring
- Notification integration for budget alerts

### 5. Analytics & Insights

**Analytics Screen**:
- Visual charts using fl_chart package:
  - Pie charts (category breakdown)
  - Bar charts (daily/weekly spending)
  - Line charts (spending trends)
- Period-based comparisons
- Top spending categories
- Payment source breakdown
- Monthly/yearly summaries

**Insights**:
- Spending patterns identification
- Budget vs actual analysis
- Category-wise spending trends
- Predictive insights (coming soon)

### 6. Payment Sources Management

**Payment Sources**:
- Custom payment methods (Cash, Credit Card, Debit Card, etc.)
- Active/inactive status
- Ordering for dropdown priority
- User-defined sources
- Default payment source selection

**Management**:
- Add/edit/delete payment sources
- Reorder sources
- Archive unused sources
- Icons for visual identification

### 7. Spent Types (Categories) Management

**Spent Types**:
- Custom expense categories
- Color coding for visual distinction
- Icon selection (600+ Material Icons)
- Active/inactive status
- Ordering for UI priority

**Default Categories**:
- Food & Dining
- Transportation
- Shopping
- Entertainment
- Bills & Utilities
- Health & Fitness
- Education
- Others

### 8. Data Export

**Export Service**:
- **Excel Export**:
  - Detailed expense reports
  - Itemized breakdown
  - Summary sheets
  - Formatted cells with colors
  - Auto-sized columns
- **PDF Export**:
  - Professional invoice-style reports
  - Company branding
  - Itemized details
  - Summary totals
- **Share Functionality**: Direct sharing via system share sheet

### 9. User Profile & Settings

**Profile Screen**:
- User information display
- Theme toggle (dark/light mode)
- Currency selection
- Payment sources management
- Spent types management
- Logout functionality

---

## Tech Stack Details

### Frontend (Flutter)

**Core**:
- Flutter 3.38+ (latest stable)
- Dart 3.2+ with null safety

**State Management**:
- flutter_riverpod ^3.0.3 (reactive state management)
- StreamProvider for real-time Firestore data
- StateProvider for UI state

**UI/UX**:
- Material 3 design system
- google_fonts ^6.2.1 (Poppins font family)
- Custom glassmorphism effects
- fl_chart ^1.1.1 (charts and graphs)
- shimmer ^3.0.0 (loading effects)
- table_calendar ^3.1.2 (calendar widget)

### Backend (Firebase)

**Firebase Services**:
- firebase_core ^4.2.1
- firebase_auth ^6.1.2 (email/password authentication)
- cloud_firestore ^6.1.0 (NoSQL database)
- firebase_storage ^13.0.4 (image storage)

**Security**:
- Firestore security rules
- UID-based data isolation
- Authenticated requests only

### AI Integration

**Google Generative AI**:
- google_generative_ai ^0.4.4
- Gemini 1.5 Flash model for:
  - Receipt image OCR
  - Voice transcription
  - Natural language processing

**Capabilities**:
- Multi-modal input (image + text)
- JSON-formatted responses
- High accuracy extraction
- Cost-effective processing

### Media & Input

**Media Handling**:
- image_picker ^1.1.2 (gallery/camera selection)
- camera ^0.11.0+1 (camera access)
- image ^4.3.0 (image manipulation)
- record ^6.1.2 (audio recording)
- permission_handler ^12.0.1 (runtime permissions)

### Export & Sharing

**Data Export**:
- excel ^4.0.4 (Excel file generation)
- pdf ^3.11.1 (PDF generation)
- share_plus ^12.0.1 (system share integration)

### Utilities

**Core Utilities**:
- uuid ^4.5.1 (unique ID generation)
- intl ^0.20.2 (internationalization & date formatting)
- path_provider ^2.1.4 (file system access)
- shared_preferences ^2.3.2 (local storage)
- connectivity_plus ^7.0.0 (network status)
- logger ^2.4.0 (debugging logs)

**Notifications**:
- flutter_local_notifications ^19.5.0
- timezone ^0.10.1
- home_widget ^0.8.1 (home screen widgets)

---

## Directory Structure Overview

### Top-Level Organization

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase config
├── config/                      # App configuration
├── models/                      # Data models (6 files)
├── providers/                   # Riverpod providers (3 files)
├── screens/                     # UI screens (10+ screens)
├── services/                    # Business logic (7 services)
├── widgets/                     # Reusable components (20+ widgets)
└── utils/                       # Helper functions (5 utilities)
```

### Models

| Model | Purpose |
|-------|---------|
| `expense.dart` | Main expense model with Firestore serialization |
| `expense_item.dart` | Individual expense item (itemized) |
| `expense_data.dart` | AI extraction result structure |
| `budget.dart` | Budget tracking model |
| `payment_source.dart` | Payment method model |
| `spent_type.dart` | Expense category model |

### Services

| Service | Responsibility |
|---------|---------------|
| `auth_service.dart` | Firebase Authentication operations |
| `gemini_service.dart` | Google Generative AI integration |
| `export_service.dart` | Excel and PDF export |
| `budget_service.dart` | Budget tracking logic |
| `payment_source_service.dart` | Payment source CRUD |
| `spent_type_service.dart` | Spent type CRUD |
| `notification_service.dart` | Local notifications |

### Key Screens

| Screen | Description |
|--------|-------------|
| `main_screen.dart` | Tab navigation hub (Home, Analytics, Profile) |
| `expense_list_screen.dart` | Main expense display with filters/sorts |
| `analytics_screen.dart` | Charts and spending insights |
| `profile_screen.dart` | User profile and settings |
| `auth/login_screen.dart` | Email/password login |
| `auth/register_screen.dart` | User registration |
| `input_tabs/image_input_tab.dart` | Receipt scanning |
| `input_tabs/voice_input_tab.dart` | Voice expense entry |
| `input_tabs/manual_input_tab.dart` | Manual form entry |

---

## Development Status

### Current Version: 0.1.0 (Beta)

**Recently Implemented** (from git history):
- ✅ Itemized expense support (multiple items per transaction)
- ✅ Dynamic payment source management
- ✅ Dynamic spent type management
- ✅ Enhanced manual input with validation
- ✅ Improved ExpenseListScreen structure
- ✅ Filter and sort enhancements
- ✅ Loading and error state improvements
- ✅ Summary card implementation
- ✅ Expense details dialog

**In Progress**:
- Budget tracking and alerts
- Advanced analytics features
- Recurring expenses
- Offline support
- Multi-user support (family accounts)

**Planned Features**:
- Receipt scanning improvements (multiple receipts)
- Voice command enhancements
- Smart categorization (ML-based)
- Bill reminders
- Expense splitting
- Cloud sync optimization
- Widget for home screen
- Wear OS support

---

## Target Users

- **Primary**: Individuals tracking personal expenses
- **Secondary**: Small business owners managing business expenses
- **Use Cases**:
  - Daily expense tracking
  - Budget monitoring
  - Receipt management
  - Tax preparation
  - Financial planning

---

## Competitive Advantages

1. **AI-Powered Input**: Faster expense entry with Gemini AI
2. **Itemized Tracking**: Granular expense details
3. **Beautiful UI**: Modern Material 3 with glassmorphism
4. **Multi-Platform**: Works on mobile, web, and desktop
5. **Offline-First**: Local storage with cloud sync (coming soon)
6. **Privacy-Focused**: User data isolated by UID
7. **Open Architecture**: Easy to extend and customize

---

## Performance Considerations

- **Real-time Updates**: Firestore streams via StreamProvider
- **Lazy Loading**: Pagination for large expense lists (planned)
- **Image Optimization**: Compressed images before upload
- **Caching**: Shared preferences for user settings
- **Code Splitting**: Lazy-loaded screens (minimal currently)
- **Widget Optimization**: Const constructors where possible

---

## Security & Privacy

- **Authentication**: Firebase Auth with email/password
- **Data Isolation**: UID-based Firestore security rules
- **Storage**: Secure receipt image storage
- **API Keys**: Environment variables (not in version control)
- **Encryption**: Firebase encryption at rest and in transit
- **Privacy**: No data sharing with third parties

---

**Document Version**: 1.0
**Last Updated**: 2025-11
**Maintained by**: Development Team
