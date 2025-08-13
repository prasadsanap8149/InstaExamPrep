# InstaExamPrep

InstaExamPrep is a Flutter-based mobile application designed to help users prepare for exams. It provides a platform for creating, sharing, and taking quizzes, with features for both online and offline use. The app now supports **room-based quiz management** for educational institutions.

## Features

### Core Features
- **User Authentication:** Secure sign-in and sign-up functionality using Firebase Authentication.
- **Quiz Management:** Create, view, and manage quizzes and questions.
- **Quiz Gameplay:** Engage in interactive quizzes with a countdown timer and dynamic question display.
- **Offline Access:** Continue taking quizzes even without an internet connection.
- **Profile Management:** View and update user profiles with role-based permissions.
- **Subscription Model:** Optional subscription plans for premium features.
- **Ad Integration:** Google Mobile Ads integration for monetization.

### New Room-Based Features
- **Quiz Rooms:** Create and manage classroom-style quiz rooms for organized learning.
- **Role-Based Access:** Support for students, teachers, and admins with different permissions.
- **Invite System:** Join rooms using secure invite codes with expiration dates.
- **Room Management:** Teachers and admins can manage students and room settings.
- **Institution Support:** Link users and rooms to educational institutions.
- **Real-time Updates:** Live synchronization of room data and quiz status.

## Architecture

The application follows **Clean Architecture** principles with the following layers:

### Core Layer
- **Exceptions:** Comprehensive exception handling with custom exception types
- **Error Handler:** Centralized error management and user-friendly error messages
- **Result Pattern:** Type-safe result handling for async operations
- **Dependency Injection:** Centralized dependency management using Provider

### Data Layer
- **Repositories:** Abstract interfaces and Firebase implementations
- **Models:** Enhanced data models with validation and serialization
- **Services:** Firebase service with comprehensive error handling

### Domain Layer
- **Use Cases:** Business logic encapsulation for specific operations
- **Entities:** Core business models and domain logic

### Presentation Layer
- **Providers:** State management using Provider pattern
- **Screens:** UI screens with proper error handling and loading states
- **Widgets:** Reusable UI components

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase (Authentication, Firestore)
- **State Management:** Provider
- **Architecture:** Clean Architecture with Repository Pattern
- **Error Handling:** Result Pattern with comprehensive exception handling
- **Dependencies:**
  - `firebase_core` & `firebase_auth` - Authentication
  - `cloud_firestore` - Database
  - `provider` - State management
  - `shared_preferences` - Local storage
  - `connectivity_plus` - Network monitoring
  - `google_mobile_ads` - Monetization

## Getting Started

### Prerequisites

- Flutter SDK (3.3.4 or higher)
- Firebase Account
- Android Studio / VS Code

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/InstaExamPrep.git
   cd InstaExamPrep
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Create a new Firebase project
   - Add Android/iOS apps to your project
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Set up environment variables:**
   - Create `.env.dev` and `.env.prod` files
   - Add your Firebase configuration

5. **Run the app:**
   ```bash
   # Development
   flutter run --flavor staging --dart-define=ENVIRONMENT=staging
   
   # Production
   flutter build apk --flavor prod --release --dart-define=ENVIRONMENT=prod
   ```

## Project Structure

```
lib/
├── core/                     # Core utilities and base classes
│   ├── di/                   # Dependency injection setup
│   ├── error/                # Error handling utilities
│   ├── exceptions/           # Custom exception classes
│   └── utils/                # Utility classes (Result pattern)
├── models/                   # Enhanced data models
│   ├── enhanced_user_profile.dart
│   ├── quiz_room.dart
│   ├── enhanced_quiz.dart
│   └── ...
├── repositories/             # Data layer abstractions
│   ├── repository_interfaces.dart
│   └── firebase_repositories.dart
├── services/                 # External service integrations
│   └── enhanced_firebase_service.dart
├── use_cases/                # Business logic layer
│   └── quiz_room_use_cases.dart
├── providers/                # State management
│   └── quiz_room_provider.dart
├── screens/                  # UI screens
│   ├── room_management_screen.dart
│   ├── home_screen.dart
│   └── ...
├── widgets/                  # Reusable UI components
└── main.dart                 # Application entry point
```

## Exception Handling

The app implements comprehensive exception handling:

- **Custom Exceptions:** Specific exception types for different error scenarios
- **Error Handler:** Centralized error processing with user-friendly messages
- **Result Pattern:** Type-safe handling of success/failure states
- **Logging:** Structured error logging for debugging and crash reporting

## Room-Based Quiz System

### For Teachers/Admins:
1. Create quiz rooms for their classes
2. Generate and share invite codes
3. Manage students and room settings
4. Create room-specific quizzes
5. Monitor student progress

### For Students:
1. Join rooms using invite codes
2. Access room-specific quizzes
3. Participate in scheduled assessments
4. Track progress within rooms

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
