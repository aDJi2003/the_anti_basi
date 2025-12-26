# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**The Anti-Basi** - Smart fridge manager app to reduce food waste. Built for InnovHack hackathon.

Core features:
- Scan food items with camera → AI detection via Gemini
- Track inventory with expiry dates
- Get recipe suggestions based on expiring items
- Push notifications for expiring food

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

# Format code
dart format lib/
```

## Project Architecture

### Tech Stack
- **Framework**: Flutter 3.x with Material Design 3
- **State Management**: Riverpod (Notifier pattern, NOT StateNotifier)
- **Routing**: go_router with ShellRoute for persistent bottom nav
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **AI Integration**: Google Generative AI (Gemini 2.5 Flash Lite)

### Directory Structure

```
lib/
├── main.dart                    # App entry point (loads dotenv, Firebase)
├── config/
│   ├── routes.dart              # GoRouter configuration with ShellRoute
│   ├── theme.dart               # Material 3 theme
│   └── app_colors.dart          # Color constants
├── core/
│   └── constants.dart           # App-wide constants
├── data/
│   ├── models/
│   │   ├── inventory_item.dart  # Inventory item with Firestore serialization
│   │   ├── scanned_item.dart    # Scanned item from Gemini
│   │   ├── user_profile.dart    # User profile with preferences
│   │   ├── recipe.dart          # Recipe model
│   │   └── app_notification.dart
│   ├── repositories/
│   │   ├── inventory_repository.dart  # Firestore CRUD for inventory
│   │   └── user_repository.dart       # Firestore CRUD for user profile
│   └── services/
│       ├── camera_service.dart   # Camera operations (capture, gallery)
│       └── gemini_service.dart   # Gemini AI for food detection
└── ui/
    ├── widgets/common/           # Shared widgets (buttons, text fields, nav)
    └── screens/
        ├── splash/               # Splash screen + auth check
        ├── auth/                 # Login screen with email/password & Google
        ├── main/                 # MainShell with bottom nav
        ├── home/                 # Dashboard with expiring items
        ├── inventory/            # Inventory list with filters
        ├── scan/                 # Camera scanner
        ├── scan_results/         # Review scanned items before saving
        ├── recipe/               # Recipe suggestions
        ├── profile/              # User profile & settings
        └── notification/         # Notification center
```

### Screen Architecture Pattern

Each screen follows this pattern:
```
screen_name/
├── screen_name_screen.dart      # UI (ConsumerWidget or ConsumerStatefulWidget)
├── screen_name_controller.dart  # Logic (Notifier<ScreenState>)
└── widgets/                     # Screen-specific widgets
```

### Riverpod Pattern

```dart
// State class
class ScreenState {
  const ScreenState({...});
  final bool isLoading;
  // ... other fields
  ScreenState copyWith({...});
}

// Controller (Notifier pattern)
class ScreenController extends Notifier<ScreenState> {
  @override
  ScreenState build() {
    _loadData();
    return const ScreenState(isLoading: true);
  }

  Future<void> _loadData() async {...}
}

// Provider
final screenControllerProvider =
    NotifierProvider<ScreenController, ScreenState>(ScreenController.new);
```

## Firestore Schema

### Users Collection
```
users/{uid}/
├── displayName: string
├── email: string
├── photoURL: string?
├── createdAt: timestamp
└── preferences: {
      cookingSkill: "beginner" | "intermediate" | "advanced"
      dietaryRestrictions: string[]
      notificationEnabled: boolean
    }
```

### Inventory Subcollection
```
users/{uid}/inventory/{itemId}/
├── id: string
├── name: string              # lowercase for search (e.g., "milk")
├── displayName: string       # display name (e.g., "Fresh Milk")
├── category: string          # dairy, protein, vegetable, fruit, grain, condiment, beverage, other
├── quantity: number
├── unit: string              # pcs, kg, g, L, mL, bottles, cans, bags, boxes, packs
├── expiryDate: timestamp
└── addedAt: timestamp
```

## Key Integrations

### Gemini AI (Food Detection)

Location: `lib/data/services/gemini_service.dart`

- Model: `gemini-2.5-flash-lite`
- Sends image → Returns JSON with detected food items
- Anti-hallucination prompt (from plan.md):
  - Only 90%+ confidence items
  - Quantity always defaults to 1 (user adjusts)
  - Confidence levels: "high", "medium", "low" (low items skipped)

```dart
// Usage
final items = await geminiService.processImage(imagePath);
```

### Camera Service

Location: `lib/data/services/camera_service.dart`

- Initialize camera with back camera
- Toggle flash
- Capture photo → returns file path
- Pick from gallery via image_picker

### Firebase Auth

- Email/password login
- Google Sign-In
- Auth state check in splash_controller.dart

## Environment Variables

File: `.env` (must be in assets)

```env
GEMINI_API_KEY=your_api_key_here
```

Required in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - .env
```

## Navigation Flow

```
SplashScreen
    ↓ (check auth)
    ├── Not logged in → LoginScreen
    └── Logged in → MainShell (with bottom nav)
                        ├── HomeScreen (/home)
                        ├── InventoryScreen (/inventory)
                        ├── RecipesScreen (/recipes)
                        └── ProfileScreen (/profile)

Overlay screens (outside shell):
├── ScanScreen (/scan) → ScanResultsScreen (/scan-results)
└── SettingsScreen (/settings)
```

## Key Dependencies

```yaml
# State & Navigation
flutter_riverpod: ^3.0.3
go_router: ^17.0.1

# Firebase
firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging
google_sign_in: ^6.2.1

# AI
google_generative_ai: ^0.4.7

# Camera & Images
camera: ^0.11.3
image_picker: ^1.2.1
path_provider: ^2.1.5

# Environment
flutter_dotenv: ^6.0.0
```

## Code Style Notes

- Use `const` constructors where possible
- Controllers use Notifier pattern (not StateNotifier)
- Computed getters for derived state (e.g., `isConsumed`, `expiryStatus`)
- Debug prints with prefixes: `[ControllerName] message`
- Error handling with try-catch and user-friendly messages
