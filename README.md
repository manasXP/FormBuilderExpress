# FormBuilderExpress

A secure SwiftUI-based KYC (Know Your Customer) form application with Firebase backend integration, designed for collecting and validating member and nominee information with banking details.

## Features

- **Multi-Step Form Flow**: Guided form completion across 6 stages
  - Member Information
  - Member Address
  - Nominee Information  
  - Nominee Address
  - Banking Details
  - Summary & Submission
- **Real-time Validation**: Comprehensive input validation with immediate feedback
- **Security-First Design**: Input sanitization, rate limiting, and data encryption
- **Auto-Save**: Automatic draft saving to prevent data loss
- **Firebase Integration**: Secure cloud storage with audit trails
- **Authentication**: Firebase Auth integration with splash screen

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Firebase project with Firestore and Authentication enabled

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd FormBuilderExpress
   ```

2. **Open in Xcode**
   ```bash
   open FormBuilderExpress.xcodeproj
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication and Firestore Database
   - Download `GoogleService-Info.plist` and add it to the project root
   - Ensure the plist file is added to the target

4. **Install Dependencies**
   Dependencies are managed through Swift Package Manager and will be resolved automatically when you build the project.

## Architecture

### MVVM Pattern
- **ViewModels**: `KYCFormViewModel`, `AuthViewModel` manage business logic and state
- **Models**: `Person`, `Account`, `Address`, `DataViewStage` define data structures
- **Views**: SwiftUI views organized by feature (Auth, KYCForm, Utils)

### Security Implementation
- **Input Sanitization**: All user inputs sanitized against XSS and injection attacks
- **Rate Limiting**: Form submissions limited to 3 attempts per 10 minutes
- **Data Encryption**: Sensitive information hashed using SHA256
- **Audit Trail**: Complete submission history with device info

### Data Flow
1. User authentication via Firebase Auth
2. Multi-step form completion with real-time validation
3. Auto-save drafts locally using UserDefaults
4. Secure submission to Firestore with audit logging
5. Sensitive data masking for display purposes

## Usage

### Running the App
1. Select a simulator or connected device
2. Press `Cmd + R` to build and run
3. The app will show a splash screen followed by authentication
4. Complete the KYC form across the guided steps

### Form Validation Rules
- **Names**: Alphabetic characters, spaces, hyphens, apostrophes only (max 48 chars)
- **Email**: Standard email format validation
- **Phone**: 10-digit US format with valid area codes
- **Age**: Minimum 18 years for both member and nominee
- **Address**: Alphanumeric with common punctuation (max 48 chars)
- **Zip Code**: 6 numeric digits
- **Account Number**: 8-17 digits
- **Routing Number**: 9 digits with checksum validation

## Building and Testing

### Build Commands
```bash
# Build for simulator
xcodebuild -project FormBuilderExpress.xcodeproj -scheme FormBuilderExpress -sdk iphonesimulator

# Build for device
xcodebuild -project FormBuilderExpress.xcodeproj -scheme FormBuilderExpress -sdk iphoneos
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project FormBuilderExpress.xcodeproj -scheme FormBuilderExpress -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -project FormBuilderExpress.xcodeproj -scheme FormBuilderExpress -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FormBuilderExpressTests/KYCFormViewModelTests
```

## Key Dependencies

- **Firebase iOS SDK** (v11.15.0): Authentication and Firestore
- **PhoneNumberKit** (v3.8.0): Phone number validation
- **iPhoneNumberField** (v0.10.4): Phone number input UI

## Project Structure

```
FormBuilderExpress/
├── FormBuilderExpressApp.swift          # Main app entry point
├── Auth/                               # Authentication module
│   ├── Model/AuthModel.swift
│   ├── View/AuthenticationView.swift
│   └── ViewModel/AuthViewModel.swift
├── KYCForm/                           # Main form module
│   ├── Model/                         # Data models
│   ├── View/                          # SwiftUI views
│   └── ViewModel/KYCFormViewModel.swift
├── Utils/                             # Shared utilities
│   ├── SecurityUtils.swift            # Security & validation
│   ├── AppTheme.swift                # UI theming
│   ├── AccessibilityUtils.swift      # Accessibility helpers
│   └── SplashScreenView.swift        # Splash screen
├── Assets.xcassets/                   # App assets
└── GoogleService-Info.plist          # Firebase configuration
```

## Security Considerations

- All user inputs are sanitized before processing
- Sensitive data is encrypted before storage
- Rate limiting prevents abuse
- Audit trails track all form submissions
- Account numbers are masked in UI display
- Debug mode uses Firebase App Check for additional security

## Contributing

1. Follow the existing MVVM architecture
2. Add comprehensive input validation for new fields
3. Include unit tests for new functionality
4. Maintain security best practices
5. Update this README for any new features

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or issues, please refer to the project documentation or create an issue in the repository.