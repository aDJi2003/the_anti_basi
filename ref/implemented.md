# The Anti-Basi - Implementation Reference
## Smart Fridge Manager for Students

> **Hackathon:** InnovHack - GDG SASTRA University 2025
> **Status:** Core features implemented, ready for demo

---

## Table of Contents
1. [Implementation Status](#1-implementation-status)
2. [Tech Stack (Actual)](#2-tech-stack-actual)
3. [System Architecture](#3-system-architecture)
4. [Database Schema (Actual)](#4-database-schema-actual)
5. [Data Models (Actual)](#5-data-models-actual)
6. [API Integration (Actual)](#6-api-integration-actual)
7. [Project Structure (Actual)](#7-project-structure-actual)
8. [Screen Flow](#8-screen-flow)
9. [Key Implementation Decisions](#9-key-implementation-decisions)
10. [Planned Features (Not Implemented)](#10-planned-features-not-implemented)

---

## 1. Implementation Status

### Completed Features

| Feature | Status | Notes |
|---------|--------|-------|
| **Smart Scan** | ✅ Done | Gemini 2.5 Flash Lite vision, quantity counting |
| **Inventory Management** | ✅ Done | CRUD, filters, item detail with inline editing |
| **Expiry Tracking** | ✅ Done | Computed status (fresh/expiring/expired) |
| **Expiry Reminder** | ✅ Done | FCM + Local Notifications |
| **AI Recipe Suggestion** | ✅ Done | Generate, preview, save to Firestore |
| **Recipe Detail** | ✅ Done | Instructions, ingredient matching |
| **Auth** | ✅ Done | Email/password + Google Sign-In |
| **SignUp** | ✅ Done | Full form with profile photo upload |
| **Profile & Settings** | ✅ Done | Cooking skill, dietary, notifications |
| **Dark Mode** | ✅ Done | Full theme support |
| **Manual Item Entry** | ✅ Done | Add items without camera |

### Not Implemented (Planned)

| Feature | Notes |
|---------|-------|
| isFrozen field | Toggle for frozen items |
| Chef Level-Up System | XP, levels, streaks gamification |
| Add More Images | Batch scanning multiple photos |
| Money Saved Counter | Track waste prevented |
| Shared Fridge | Multi-user for roommates |

---

## 2. Tech Stack (Actual)

| Layer | Technology | Version |
|-------|------------|---------|
| **Framework** | Flutter | 3.x |
| **Language** | Dart | - |
| **State Management** | Riverpod | `flutter_riverpod: ^3.0.3` |
| **Navigation** | Go Router | `go_router: ^17.0.1` |
| **Auth** | Firebase Auth | `firebase_auth` |
| **Auth Provider** | Google Sign-In | `google_sign_in: ^6.2.1` |
| **Database** | Cloud Firestore | `cloud_firestore` |
| **Storage** | Firebase Storage | `firebase_storage` |
| **AI** | Gemini 2.5 Flash Lite | `google_generative_ai: ^0.4.7` |
| **Camera** | Device Camera | `camera: ^0.11.3` |
| **Image Picker** | Gallery | `image_picker: ^1.2.1` |
| **Push Notifications** | FCM | `firebase_messaging` |
| **Local Notifications** | Local | `flutter_local_notifications` |
| **UI Design** | Material 3 | Built-in (light + dark) |

---

## 3. System Architecture

```
┌──────────────────┐
│   FLUTTER APP    │
│   (Mobile)       │
└────────┬─────────┘
         │
         │  SDK
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FIREBASE SERVICES                          │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │    Auth     │  │  Firestore  │  │   Storage   │             │
│  │  (Google +  │  │ (Database)  │  │  (Profile   │             │
│  │   Email)    │  │             │  │   Photos)   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐                                                │
│  │     FCM     │                                                │
│  │   (Push)    │                                                │
│  └─────────────┘                                                │
└─────────────────────────────────────────────────────────────────┘
         │
         │  REST API
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GOOGLE AI STUDIO                             │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Gemini 2.5 Flash Lite                       │   │
│  │  ├── Food Detection (Vision)                             │   │
│  │  └── Recipe Generation (Text)                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Database Schema (Actual)

### Firestore Collections

```
📁 users/{userId}/
│
├── displayName: string
├── email: string
├── photoURL: string?          # Firebase Storage URL
├── createdAt: timestamp
├── fcmToken: string           # Push notification token
├── lastTokenUpdate: timestamp
├── platform: string           # 'android' | 'ios'
│
├── preferences: {
│     cookingSkill: "beginner" | "intermediate" | "advanced"
│     dietaryRestrictions: string[]
│     notificationEnabled: boolean
│   }
│
├── 📁 inventory/{itemId}/
│   ├── id: string
│   ├── name: string              # "milk" - lowercase for search
│   ├── displayName: string       # "Fresh Milk" - for display
│   ├── category: string          # dairy, protein, vegetable, etc.
│   ├── quantity: number          # double
│   ├── unit: string              # pcs, kg, g, L, mL, etc.
│   ├── expiryDate: timestamp
│   └── addedAt: timestamp
│   # NOTE: No imageUrl, isConsumed, consumedAt, status fields
│   # These are computed in-app from quantity and expiryDate
│
└── 📁 savedRecipes/{recipeId}/
    ├── name: string
    ├── description: string?
    ├── cookTime: number          # in minutes
    ├── difficulty: string        # easy, medium, hard
    ├── servings: number
    ├── calories: number?
    ├── proTip: string?
    ├── usesExpiringItems: string[]
    ├── savedAt: timestamp
    │
    ├── ingredients: [
    │     {
    │       name: string,
    │       quantity: string,     # "2 buah", "500g"
    │       fromInventory: boolean
    │     }
    │   ]
    │
    └── instructions: [
          {
            stepNumber: number,
            title: string,
            description: string
          }
        ]
```

### Key Differences from Plan

| Plan | Actual |
|------|--------|
| `imageUrl` in inventory | Not implemented |
| `status` field stored | Computed from `expiryDate` |
| `isConsumed`, `consumedAt` | Computed from `quantity <= 0` |
| `foodDatabase/` collection | Not used - Gemini handles expiry |
| `recipes/` cache collection | Not used - only `savedRecipes/` |
| `lastLoginAt` | Not implemented |
| `notificationTime` | Not implemented |

---

## 5. Data Models (Actual)

### InventoryItem

```dart
class InventoryItem {
  final String id;
  final String name;           // "telur" - for matching
  final String displayName;    // "Telur Ayam" - for display
  final ItemCategory category; // enum: dairy, protein, vegetable, etc.
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final DateTime addedAt;

  // COMPUTED GETTERS (not stored)
  bool get isConsumed => quantity <= 0;
  int get daysUntilExpiry => expiryDate.difference(today).inDays;
  ExpiryStatus get expiryStatus {
    if (days < 0) return ExpiryStatus.expired;
    if (days == 0) return ExpiryStatus.expiringToday;
    if (days <= 3) return ExpiryStatus.expiringSoon;
    return ExpiryStatus.fresh;
  }
}

enum ItemCategory {
  dairy, protein, vegetable, fruit, grain, condiment, beverage, other
}

enum ExpiryStatus {
  fresh, expiringSoon, expiringToday, expired
}
```

### Recipe

```dart
class Recipe {
  final String id;
  final String name;
  final String? description;
  final int cookTime;                    // minutes
  final RecipeDifficulty difficulty;     // enum
  final int servings;
  final int? calories;
  final String? proTip;
  final List<String> usesExpiringItems;
  final List<RecipeIngredient> ingredients;
  final List<RecipeInstruction> instructions;
  final DateTime? savedAt;
  final bool isSelected;                 // for preview selection
}

class RecipeIngredient {
  final String name;
  final String quantity;      // "2 buah", "500g"
  final bool fromInventory;   // true if from user's inventory
}

class RecipeInstruction {
  final int stepNumber;
  final String title;
  final String description;
}

enum RecipeDifficulty { easy, medium, hard }
```

### ScannedItem (for scan results)

```dart
class ScannedItem {
  final String id;
  final String name;
  final String displayName;
  final ItemCategory category;
  double quantity;
  String unit;
  DateTime expiryDate;
  final String confidence;    // "high", "medium", "low"
  bool isSelected;            // user can deselect
}
```

---

## 6. API Integration (Actual)

### Gemini Vision (Food Detection)

**Model:** `gemini-2.5-flash-lite`

```dart
class GeminiService {
  final model = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
    generationConfig: GenerationConfig(
      temperature: 0.4,
      topK: 32,
      topP: 1,
      maxOutputTokens: 4096,
      responseMimeType: 'application/json',
    ),
  );

  Future<List<ScannedItem>> processImage(String imagePath);
}
```

**Prompt Key Points:**
- Safety filter: Rejects weapons, poisons, non-food items
- Quantity counting: Gemini counts countable items (eggs, bottles)
- Confidence levels: high (90%+), medium (70-90%), low (skip)
- Categories: protein, vegetable, fruit, dairy, grain, condiment, beverage, other

**Response Format:**
```json
{
  "items": [
    {"name": "eggs", "category": "protein", "quantity": 6, "confidence": "high"},
    {"name": "milk", "category": "dairy", "quantity": 1, "confidence": "high"}
  ]
}
```

### Gemini Recipe Generation

**Model:** `gemini-2.5-flash-lite` (same model)

**Prompt Key Points:**
- Input: List of inventory items with quantities and expiry status
- Output: 3 recipes prioritizing expiring items
- CRITICAL: Ingredient names MUST match inventory names exactly (prevents translation mismatch)
- Language: English output

**Response Format:**
```json
{
  "recipes": [
    {
      "name": "Scrambled Eggs with Tomato",
      "description": "Quick and easy breakfast",
      "cookTime": 10,
      "difficulty": "easy",
      "servings": 2,
      "calories": 250,
      "proTip": "Add cheese for extra flavor",
      "usesExpiringItems": ["eggs", "tomato"],
      "ingredients": [
        {"name": "eggs", "quantity": "3 pcs", "fromInventory": true},
        {"name": "salt", "quantity": "1/2 tsp", "fromInventory": false}
      ],
      "instructions": [
        {"stepNumber": 1, "title": "Prep", "description": "Beat eggs in bowl"},
        {"stepNumber": 2, "title": "Cook", "description": "Heat pan, add eggs"}
      ]
    }
  ]
}
```

---

## 7. Project Structure (Actual)

```
lib/
├── main.dart                    # App entry (dotenv, Firebase init)
│
├── config/
│   ├── routes.dart              # GoRouter with ShellRoute
│   ├── theme.dart               # Material 3 (light + dark)
│   └── app_colors.dart          # Color constants
│
├── core/
│   ├── constants.dart           # App-wide constants
│   └── date_utils.dart          # Centralized expiry calculations
│
├── data/
│   ├── models/
│   │   ├── inventory_item.dart  # InventoryItem + ItemCategory + ExpiryStatus
│   │   ├── scanned_item.dart    # ScannedItem (from Gemini)
│   │   ├── user_profile.dart    # UserProfile + UserPreferences
│   │   ├── recipe.dart          # Recipe + RecipeIngredient + RecipeInstruction
│   │   └── app_notification.dart
│   │
│   ├── repositories/
│   │   ├── inventory_repository.dart  # Firestore CRUD
│   │   └── user_repository.dart
│   │
│   └── services/
│       ├── camera_service.dart          # Camera + gallery
│       ├── gemini_service.dart          # Vision + Recipe AI
│       └── local_notification_service.dart  # FCM + Local
│
└── ui/
    ├── widgets/common/           # Shared widgets
    │
    └── screens/
        ├── splash/               # Auth check
        ├── auth/                 # Login + SignUp
        ├── main/                 # MainShell (bottom nav)
        ├── home/                 # Dashboard (reactive stream)
        ├── inventory/            # List with filters
        ├── item_detail/          # Detail + edit sheets
        │   ├── item_detail_screen.dart
        │   ├── item_detail_controller.dart
        │   └── widgets/
        │       ├── quantity_editor_sheet.dart
        │       ├── category_editor_sheet.dart
        │       └── expiry_date_editor_sheet.dart
        ├── scan/                 # Camera
        ├── scan_results/         # Review + manual entry
        ├── recipe/               # Generate + saved recipes
        ├── profile/              # User profile
        └── notification/         # Notification center
```

---

## 8. Screen Flow

```
NAVIGATION ARCHITECTURE
═══════════════════════

ShellRoute (MainShell with bottom nav)
├── /home (HomeScreen)
├── /inventory (InventoryScreen)
├── /recipes (RecipeSuggestionScreen)
│   └── /:id (RecipeDetailScreen) ← nested route
└── /profile (ProfileScreen)

Outside Shell (full screen):
├── /scan (ScanScreen)
├── /scan-results (ScanResultsScreen)
├── /inventory/item/:id (ItemDetailScreen)
├── /recipe-preview (RecipePreviewScreen)
└── /settings (SettingsScreen)


SCAN FLOW
═════════
Camera → Capture/Gallery → Gemini Vision → Parse JSON
    → Confirm Screen (edit qty/expiry) → Save to Firestore


RECIPE FLOW
═══════════
Inventory → Select expiring items → Gemini Recipe
    → Preview (select recipes) → Save selected → Firestore

NOTE: Generated recipe previews use bottom sheet (not navigation)
      to avoid ShellRoute conflict
```

---

## 9. Key Implementation Decisions

### What Changed from Plan

| Plan Decision | Actual Implementation |
|---------------|----------------------|
| AI only identifies WHAT | AI also counts quantity for countable items |
| Quantity defaults to 1 | Gemini counts (6 eggs, 3 apples), user can correct |
| foodDatabase lookup for expiry | Gemini estimates expiry in prompt response |
| Cut FCM for MVP | FCM fully implemented |
| Cut Settings page | Settings implemented (skill, dietary, notifs) |
| Cut SignUp profile photo | Implemented (max 2MB, 512x512) |
| gemini-2.0-flash-lite | gemini-2.5-flash-lite |
| gemini-1.5-pro for recipes | gemini-2.5-flash-lite (same model) |
| Store status in Firestore | Computed from expiryDate |
| Store isConsumed | Computed from quantity <= 0 |

### Architecture Decisions (Kept)

| Decision | Implementation |
|----------|----------------|
| Riverpod Notifier pattern | All controllers use `Notifier<State>` |
| Centralized expiry logic | `lib/core/date_utils.dart` |
| Dynamic ingredient validation | Computed on view, not stored |
| Single savedRecipes collection | No generatedRecipes collection |
| Dark mode pattern | Invert neutral colors, keep accent colors |
| Home reactivity | Uses `inventoryStreamProvider` for real-time |

---

## 10. Planned Features (Not Implemented)

### isFrozen Field

```dart
// Add to InventoryItem
final bool isFrozen;  // default false

// Questions to resolve:
// - Extend expiry calculation for frozen items?
// - Where to add frozen toggle in UI?
```

### Chef Level-Up System

| Level | Title | XP Required |
|-------|-------|-------------|
| 1 | Beginner Chef | 0 |
| 2 | Home Cook | 500 XP |
| 3 | Expert Chef | 2000 XP |

| Action | XP |
|--------|-----|
| Scan items | +10 |
| Add manual | +5 |
| Consume before expiry | +15 |
| Item expires (waste) | -10 |
| Generate recipes | +10 |
| Complete recipe | +50 |
| 7-day streak | +100 |

### Add More Images

- Allow batch scanning multiple images
- Currently shows "coming soon" snackbar

### Money Saved Counter

```dart
// Track when user cooks expiring items
void onCookingComplete(Recipe recipe) {
  int savedAmount = 0;
  for (final ingredient in recipe.usesExpiringItems) {
    savedAmount += estimatedPrice[ingredient];
  }
  showCelebration("You saved Rp $savedAmount!");
  userStats.totalMoneySaved += savedAmount;
}
```

---

*Last updated: December 2025*
*Based on commit: e5b2d39*
