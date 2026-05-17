# GearUp Garage

GearUp Garage is a Flutter application for garage services with role-based
experiences for admins, customers, and service providers.

## Features

- Role-based dashboards for admin, customer, and service provider flows
- Customer booking and service discovery screens
- Customer profile management
- In-app messaging screens

## Tech Stack

- Flutter (Dart)
- Firebase (configured via `firebase_options.dart`)

## Project Structure

- `lib/admin/` - admin screens and login
- `lib/customer/` - customer flows (home, bookings, chat, profile)
- `lib/service_provider/` - service provider screens
- `lib/core/` - shared config, theme, UI, and utilities
- `lib/presentation/` - presentation-layer screens

## Getting Started

### Prerequisites

- Flutter SDK installed and on PATH
- Android Studio or VS Code with Flutter and Dart extensions

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Build (example: Android)

```bash
flutter build apk
```

## Firebase

This project includes Firebase config files for supported platforms. If you
need to regenerate config, use the FlutterFire CLI and update
`lib/firebase_options.dart`.

## License

Add a license file if you plan to open source this project.
