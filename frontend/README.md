# Frontend Setup Instructions

## Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extension
- Android/iOS simulator or physical device

## Quick Setup

1. **Install dependencies:**

   ```bash
   flutter pub get
   ```

2. **Run the app:**

   ```bash
   flutter run
   ```

   Choose your target device when prompted.

## Features

- **Material 3 Design** - Modern, responsive UI
- **Authentication** - Secure login/signup with JWT
- **Dashboard** - Personalized user dashboard
- **File Upload** - Upload images, CSV, text files
- **CRUD Operations** - Manage records with full CRUD
- **Analytics** - Interactive charts with fl_chart
- **State Management** - Provider pattern for app state

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/               # UI screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── upload_screen.dart
│   ├── records_screen.dart
│   └── analytics_screen.dart
└── services/              # Business logic
    ├── auth_service.dart  # Authentication
    └── api_service.dart   # API communication
```

## Configuration

Update the API base URL in `lib/services/api_service.dart` if needed:

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

For physical devices, use your computer's IP address:

```dart
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

## Demo Credentials

- Email: demo@demo.com
- Password: demo123

## Development

- Hot reload: Save files to see changes instantly
- Debug mode: Use Flutter DevTools for debugging
- Build release: `flutter build apk` or `flutter build ios`
