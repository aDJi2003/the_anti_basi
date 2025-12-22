# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run on specific device
flutter run -d chrome        # Web
flutter run -d android       # Android emulator/device
flutter run -d ios           # iOS simulator/device

# Build for release
flutter build apk            # Android
flutter build ios            # iOS
flutter build web            # Web

# Analyze code for issues
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Format code
dart format lib/
```

## Project Architecture

This is a Flutter mobile application with the following planned structure:

- **State Management**: Riverpod (`flutter_riverpod`)
- **Routing**: go_router for declarative navigation
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **AI Integration**: Google Generative AI (`google_generative_ai`)

### Directory Structure

```
lib/
├── config/        # App configuration (routes, theme)
├── core/          # Core constants and utilities
└── main.dart      # App entry point
```

### Key Dependencies

- Firebase stack: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`
- Authentication: `google_sign_in`
- Image handling: `camera`, `image_picker`, `flutter_image_compress`, `cached_network_image`
- Environment: `flutter_dotenv` (requires `.env` file in project root)

## Configuration

The app uses `flutter_dotenv` for environment variables. Ensure a `.env` file exists at the project root with required API keys before running.

Assets are expected in:
- `assets/images/`
- `assets/icons/`
- `assets/data/`
