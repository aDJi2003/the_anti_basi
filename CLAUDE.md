# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**The Anti-Basi** - Smart fridge manager app to reduce food waste. Built for InnovHack hackathon.

Core features:
- Scan food items with camera → AI detection via Gemini
- Track inventory with expiry dates
- Get recipe suggestions based on expiring items
- Push notifications for expiring food

## Current Status

### Completed Features
- **Auth**: Email/password, Google Sign-In, SignUp with profile photo (max 2MB, 512x512)
- **Home**: Time-based greeting, expiring items dashboard, reactive updates via stream
- **Inventory**: List with filters, item detail screen with inline editing (quantity, category, expiry)
- **Scan**: Camera preview, capture, gallery picker, flash toggle
- **Scan Results**: AI detection display, manual item entry, editable items before save
- **Recipe**: Generate from expiring items, preview & save, ingredient matching with inventory
- **Profile**: User data from Firestore, settings
- **Notifications**: FCM + Local Notifications, notification center
- **Dark Mode**: Full support with inverted neutral colors

### Planned Features (Not Yet Implemented)
1. **isFrozen field** - Add frozen toggle to InventoryItem model
2. **Chef Level-Up System** - Gamification with XP, levels, streaks
3. **Add More Images** - Batch image scanning (currently shows "coming soon")
4. **Full E2E Testing**

## Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Gemini Integration | Direct API | Simpler for hackathon vs Cloud Functions |
| Confidence System | high/medium/low | high auto-selected, medium user confirms, low skipped |
| Recipe Ingredient Match | Exact name | Prevents translation mismatch (Carrot vs Wortel) |
| Expiry Calculation | Centralized `date_utils.dart` | Single source of truth |
| Recipe Flow | Generate → Preview → Save | No intermediate generatedRecipes collection |
| Home Reactivity | `inventoryStreamProvider` | Real-time updates, no manual refresh |
| Generated Recipe Preview | Bottom sheet | Avoids ShellRoute navigation conflict |

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
│   ├── theme.dart               # Material 3 theme (light + dark)
│   └── app_colors.dart          # Color constants
├── core/
│   ├── constants.dart           # App-wide constants
│   └── date_utils.dart          # Centralized expiry calculations
├── data/
│   ├── models/
│   │   ├── inventory_item.dart  # Inventory item with Firestore serialization
│   │   ├── scanned_item.dart    # Scanned item from Gemini
│   │   ├── user_profile.dart    # User profile with preferences
│   │   ├── recipe.dart          # Recipe model with RecipeIngredient
│   │   └── app_notification.dart
│   ├── repositories/
│   │   ├── inventory_repository.dart  # Firestore CRUD for inventory
│   │   └── user_repository.dart       # Firestore CRUD for user profile
│   └── services/
│       ├── camera_service.dart          # Camera operations
│       ├── gemini_service.dart          # Gemini AI (food detection + recipe)
│       └── local_notification_service.dart  # FCM + Local notifications
└── ui/
    ├── widgets/common/           # Shared widgets
    └── screens/
        ├── splash/               # Splash + auth check
        ├── auth/                 # Login + SignUp
        ├── main/                 # MainShell with bottom nav
        ├── home/                 # Dashboard (reactive via stream)
        ├── inventory/            # Inventory list with filters
        ├── item_detail/          # Item detail + edit sheets
        ├── scan/                 # Camera scanner
        ├── scan_results/         # Review + manual entry
        ├── recipe/               # Recipe generation + saved recipes
        ├── profile/              # User profile
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
├── fcmToken: string          # Push notification token
├── lastTokenUpdate: timestamp
├── platform: string          # 'android' | 'ios'
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
├── addedAt: timestamp
└── isFrozen: boolean         # PLANNED - not yet implemented
```

### Saved Recipes Subcollection
```
users/{uid}/savedRecipes/{recipeId}/
├── id, name, description, cookTime, difficulty, servings
├── proTip, usesExpiringItems[], instructions[]
├── savedAt: timestamp
└── ingredients[]: { name, amount, unit, fromInventory: boolean }
```

## Key Integrations

### Gemini AI

Location: `lib/data/services/gemini_service.dart`

**Model**: `gemini-2.5-flash-lite`

**Food Detection**:
- Sends image → Returns JSON with detected food items
- Confidence: high (90%+) auto-selected, medium (70-90%) user confirms, low skipped
- Counts countable items (eggs, bottles) - user can correct
- Safety filter rejects non-food items

**Recipe Generation**:
- Input: list of expiring ingredients from inventory
- CRITICAL: ingredient names must match inventory exactly (prevents translation mismatch)
- Output: JSON with recipes using those ingredients

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
                        │   └── /:id (RecipeDetailScreen) ← nested route
                        └── ProfileScreen (/profile)

Outside shell (full screen):
├── ScanScreen (/scan) → ScanResultsScreen (/scan-results)
├── ItemDetailScreen (/inventory/item/:id)
├── RecipePreviewScreen (/recipe-preview)
└── SettingsScreen (/settings)
```

**Navigation Rule**: Generated recipe previews use bottom sheet (not navigation) to avoid ShellRoute conflict.

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

## Continuous-Claude Integration

### Session Continuity

Project ini menggunakan Continuous-Claude untuk manajemen context. File penting:
- `thoughts/ledger.md` — Quick state snapshot
- `thoughts/handoffs/` — Detailed handoff documents

### Trigger Actions

Ketika user menyebutkan prompt berikut, **WAJIB baca file terkait dahulu**:

| Prompt User | Aksi Claude |
|-------------|-------------|
| "resume work", "continue", "lanjut", "pick up" | Baca `thoughts/ledger.md` DAN file terbaru di `thoughts/handoffs/` |
| "save state", "update ledger" | Tulis state saat ini ke `thoughts/ledger.md` |
| "create handoff", "wrap up", "done for today" | Buat file baru di `thoughts/handoffs/YYYY-MM-DD-summary.md` |

### Ledger Format

```markdown
## Current State
- **Task**: [apa yang sedang dikerjakan]
- **Progress**: [persentase dan status]
- **Files Modified**: [file yang diubah]
- **Next**: [langkah selanjutnya]
- **Blockers**: [jika ada masalah]

Updated: [timestamp]
```

### Handoff Format

```markdown
## Handoff: [Task Name]
Date: YYYY-MM-DD

### Context
[Penjelasan singkat task]

### What Was Done
1. [completed item]
2. [completed item]

### Decisions Made
- [keputusan dan alasannya]

### Next Steps
1. [ ] [todo item]
2. [ ] [todo item]

### Files to Review
- [file paths]
```
