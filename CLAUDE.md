# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This repository contains two iOS projects:

### FormBuilderExpress
A SwiftUI KYC (Know Your Customer) form application with Firebase backend integration. Features a multi-step form with validation, authentication, and secure data handling.

**Key Architecture:**
- **MVVM Pattern**: ViewModels (`KYCFormViewModel`, `AuthViewModel`) manage business logic and state
- **Form Flow**: Multi-step form using `DataViewStage` enum to navigate between steps:
  - Member Info → Member Address → Nominee Info → Nominee Address → Bank Details → Summary
- **Firebase Integration**: Uses Firestore for data persistence and Firebase Auth for authentication
- **Security-First Design**: Input sanitization, rate limiting, and data encryption via `SecurityUtils.swift`

**Dependencies:**
- Firebase iOS SDK (Auth, Firestore, App Check)
- PhoneNumberKit for phone validation
- iPhoneNumberField for UI phone input

### SwiftUIDemo
A basic SwiftUI application demonstrating SwiftData integration with CRUD operations for Item entities.

**Key Architecture:**
- **SwiftData**: Uses `@Model` classes and `ModelContainer` for data persistence
- **Navigation**: NavigationSplitView for master-detail layout

## Common Development Commands

### Building and Testing
```bash
# Build FormBuilderExpress
xcodebuild -project FormBuilderExpress/FormBuilderExpress.xcodeproj -scheme FormBuilderExpress -sdk iphonesimulator

# Run FormBuilderExpress tests
xcodebuild test -project FormBuilderExpress/FormBuilderExpress.xcodeproj -scheme FormBuilderExpress -destination 'platform=iOS Simulator,name=iPhone 15'

# Build SwiftUIDemo
xcodebuild -project SwiftUIDemo/SwiftUIDemo.xcodeproj -scheme SwiftUIDemo -sdk iphonesimulator
```

### Running in Simulator
Both projects can be opened in Xcode and run using the standard Xcode build and run process (Cmd+R).

## FormBuilderExpress Specific Guidelines

### Form Validation Architecture
- All validation logic is centralized in `SecurityUtils.swift` using String extensions
- Each form step has corresponding validation state in `KYCFormViewModel`
- Age validation requires minimum 18 years for both member and nominee
- Phone numbers must be 10 digits (US format) with valid area codes

### Security Implementation
- **Input Sanitization**: All user inputs are sanitized using `String.sanitized` extension
- **Rate Limiting**: Form submissions are rate-limited (3 attempts per 10 minutes)
- **Data Encryption**: Sensitive data is hashed using SHA256 before storage
- **Audit Trail**: All form submissions create audit log entries

### Data Models
- `Person`: Member and nominee information with embedded address
- `Account`: Banking information with account/routing number validation  
- `Address`: Standard US address format with zip code validation
- `DataViewStage`: Enum controlling form navigation flow

### Firebase Configuration
- Requires `GoogleService-Info.plist` for Firebase configuration
- Uses App Check for security in debug mode
- Data is stored in user-specific subcollections in Firestore

### Auto-Save Feature
- Form data is automatically saved locally using UserDefaults
- Debounced auto-save triggers every 2 seconds after user input
- Draft data is restored when user returns to the app

## Testing
- FormBuilderExpress uses XCTest framework
- Test target: `FormBuilderExpressTests`
- Key test files: `KYCFormViewModelTests.swift`
- SwiftUIDemo has minimal test setup

## File Organization
- **Auth/**: Authentication views, models, and view models
- **KYCForm/**: Multi-step form implementation (Model/View/ViewModel structure)
- **Utils/**: Shared utilities including security, theming, and accessibility helpers