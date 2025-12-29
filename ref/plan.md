# The Anti-Basi - Project Plan
## Smart Fridge Manager for Students

> **Hackathon:** InnovHack - GDG SASTRA University 2025
> **Deadline:** 31 December 2025
> **Theme:** Identify real-world problems from campus or local community

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Solution Overview](#3-solution-overview)
4. [Target Users](#4-target-users)
5. [Features](#5-features)
6. [Tech Stack](#6-tech-stack)
7. [System Architecture](#7-system-architecture)
8. [Database Schema](#8-database-schema)
9. [API Integration](#9-api-integration)
10. [User Flow](#10-user-flow)
11. [UI/UX Wireframes](#11-uiux-wireframes)
12. [Project Structure](#12-project-structure)
13. [Development Phases](#13-development-phases)
14. [Submission Checklist](#14-submission-checklist)
15. [Critical Design Decisions](#15-critical-design-decisions)
16. [Demo Strategy](#16-demo-strategy)

---

## 1. Executive Summary

### Project Name
**The Anti-Basi** (Indonesian slang: "Anti Stale/Expired")

### Tagline
*"Smart Fridge Manager - Reduce Waste, Cook Smart"*

### Elevator Pitch
> Every year, 27 million tons of food is wasted in Indonesia - and it starts in our refrigerators. The Anti-Basi uses Google Gemini Vision to scan your groceries, track expiry dates automatically, and suggest recipes based on what's about to expire. No more forgotten vegetables. No more wasted money. Just smart, simple fridge management for students and young professionals.

### Google Technologies Used
| Technology | Purpose |
|------------|---------|
| **Gemini 2.5 Flash Lite** | Food detection from images (Vision AI) |
| **Gemini 2.5 Flash Lite** | Recipe generation & AI chat |
| **Firebase Auth** | User authentication (Google SSO) |
| **Cloud Firestore** | NoSQL database |
| **Firebase Storage** | Image storage |
| **Firebase Cloud Messaging** | Push notifications |

---

## 2. Problem Statement

### The Problem
Mahasiswa kos dan young professionals yang tinggal sendiri sering mengalami:

```
┌─────────────────────────────────────────────────────────────┐
│                    PAIN POINTS                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  😫 LUPA & BASI                                             │
│     "Beli sayur minggu lalu, lupa, tau-tau udah busuk"      │
│     "Telur di kulkas udah berapa minggu ya?"                │
│                                                             │
│  🤔 BINGUNG MAU MASAK APA                                   │
│     "Ada sisa bahan tapi gak tau mau diapain"               │
│     "Males mikir, akhirnya beli makan luar"                 │
│                                                             │
│  💸 BOROS & WASTE                                           │
│     "Beli bahan yang ternyata masih ada di kulkas"          │
│     "Buang makanan = buang uang"                            │
│                                                             │
│  📝 TRACKING RIBET                                          │
│     "Males catat manual satu-satu"                          │
│     "Barcode scanning? Bahan fresh gak ada barcode"         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Supporting Data
- Indonesia: **23-27 juta ton** makanan terbuang per tahun
- ~30% food waste terjadi di level rumah tangga
- Mahasiswa: Budget terbatas, tapi food waste tinggi karena kurang planning

### Why This Matters
- **Economic Impact:** Uang terbuang sia-sia
- **Environmental Impact:** Food waste = carbon footprint
- **Social Impact:** Di satu sisi makanan terbuang, di sisi lain ada yang kelaparan

---

## 3. Solution Overview

### Core Concept
Aplikasi mobile yang membantu user mengelola isi kulkas dengan:
1. **Smart Scan** - Foto bahan makanan, AI deteksi otomatis
2. **Inventory Tracking** - Catat semua bahan dengan estimasi expiry date
3. **Expiry Reminder** - Notifikasi sebelum makanan expired
4. **AI Recipe Suggestion** - Rekomendasi resep berdasarkan bahan yang ada

### Key Innovation
- **No barcode needed** - Gemini Vision bisa detect bahan fresh tanpa barcode
- **Context-aware recipes** - Prioritaskan bahan yang mau expired
- **Minimal effort** - Foto sekali, tracking otomatis

---

## 4. Target Users

### Primary Persona

```
👤 Persona: "Budi" - Mahasiswa Kos

Demografi:
├── Umur: 19-25 tahun
├── Status: Mahasiswa / Fresh graduate
├── Living: Kos / Kontrakan dengan kulkas kecil
└── Budget makan: Rp 1-1.5 juta/bulan

Behavior:
├── Belanja seminggu sekali di pasar/supermarket
├── Masak sendiri untuk hemat, tapi sering males
├── Aktif di HP, familiar dengan apps
└── Suka yang praktis, gak ribet

Pain Points:
├── Sering buang makanan karena expired
├── Bingung mau masak apa dari sisa bahan
├── Lupa apa yang sudah ada di kulkas
└── Budget terbatas, sayang kalau makanan terbuang
```

### Secondary Users
- Young professionals yang tinggal sendiri
- Siapa saja yang punya kulkas dan masak sendiri
- Shared living (kos bareng) - future feature

---

## 5. Features

### MVP Features (Must Have)

| Feature | Description | Google Tech |
|---------|-------------|-------------|
| **Smart Scan** | Foto bahan → AI detect → auto-add ke inventory | Gemini Vision |
| **Inventory Management** | List semua bahan, status expiry, CRUD operations | Firestore |
| **Expiry Tracking** | Auto-assign expiry date, status (fresh/expiring/expired) | Firestore |
| **Expiry Reminder** | Push notification H-1 dan H-Day | FCM / Local Notif |
| **AI Recipe Suggestion** | Generate resep berdasarkan bahan yang ada | Gemini Pro |
| **Recipe Detail** | Step-by-step instructions, ingredient checklist | Gemini Pro |
| **Google Sign-In(maybe)** | One-tap authentication | Firebase Auth |

### Nice-to-Have Features (If Time Permits)

| Feature | Description |
|---------|-------------|
| Smart Shopping List | Generate shopping list dari resep |
| Waste Analytics | Track berapa makanan yang terbuang vs diselamatkan |
| Voice Input | "Tambahkan 5 telur ke kulkas" |
| Shared Fridge | Multiple user untuk satu kulkas (kos bareng) |
| Dietary Preferences | Filter resep: vegetarian, halal, alergi |
| Budget Tracking | Catat harga bahan, track pengeluaran |


---

## 6. Tech Stack

### Mobile Framework
```
┌─────────────────────────────────────────────────────────────┐
│  FLUTTER 3.x (Dart)                                         │
├─────────────────────────────────────────────────────────────┤
│  Why Flutter?                                               │
│  ├── ✅ Single codebase → Android + iOS                     │
│  ├── ✅ Excellent Firebase integration                      │
│  ├── ✅ Built-in camera & image picker                      │
│  ├── ✅ Google technology (bonus point!)                    │
│  ├── ✅ Hot reload = fast development                       │
│  └── ✅ Good for hackathon timeline                         │
└─────────────────────────────────────────────────────────────┘
```

### Complete Tech Stack

| Layer | Technology | Package/Service |
|-------|------------|-----------------|
| **Framework** | Flutter 3.x | - |
| **Language** | Dart | - |
| **State Management** | Riverpod | `flutter_riverpod` |
| **Navigation** | Go Router | `go_router` |
| **Auth** | Firebase Auth | `firebase_auth` |
| **Auth Provider** | Google Sign-In | `google_sign_in` |
| **Database** | Cloud Firestore | `cloud_firestore` |
| **Storage** | Firebase Storage | `firebase_storage` |
| **AI - Vision** | Gemini 2.5 Flash Lite | `google_generative_ai` |
| **AI - Text** | Gemini 2.5 Flash Lite | `google_generative_ai` |
| **Camera** | Device Camera | `camera` |
| **Image Picker** | Gallery | `image_picker` |
| **Notifications** | Local + FCM | `flutter_local_notifications`, `firebase_messaging` |
| **UI Design** | Material 3 | Built-in |

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.0

  # Google Sign In
  google_sign_in: ^6.2.0

  # Google Gemini AI
  google_generative_ai: ^0.4.0

  # Camera & Image
  camera: ^0.10.5
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0

  # State Management
  flutter_riverpod: ^2.4.9

  # Navigation
  go_router: ^13.0.0

  # Notifications
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2

  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # Utils
  intl: ^0.18.1
  uuid: ^4.3.0
  shared_preferences: ^2.2.2
  permission_handler: ^11.2.0
  flutter_dotenv: ^5.1.0
```

### Why No GCP Needed?

```
┌─────────────────────────────────────────────────────────────┐
│  SETUP TANPA GCP (Recommended untuk Hackathon)              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  GEMINI API                                                 │
│  └── Google AI Studio (https://aistudio.google.com)         │
│      ├── ✅ GRATIS (ada quota limit)                        │
│      ├── ✅ API Key langsung dapat                          │
│      └── ✅ No billing setup                                │
│                                                             │
│  FIREBASE                                                   │
│  └── Firebase Console (https://console.firebase.google.com) │
│      ├── ✅ Free tier cukup untuk hackathon                 │
│      └── ✅ No credit card needed                           │
│                                                             │
│  TOTAL COST: $0                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ARCHITECTURE                             │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│                  │
│   FLUTTER APP    │
│   (Mobile)       │
│                  │
└────────┬─────────┘
         │
         │  HTTP / SDK
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                      FIREBASE SERVICES                          │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │             │  │             │  │             │             │
│  │    Auth     │  │  Firestore  │  │   Storage   │             │
│  │  (Google)   │  │ (Database)  │  │  (Images)   │             │
│  │             │  │             │  │             │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐                              │
│  │             │  │             │                              │
│  │     FCM     │  │  Analytics  │                              │
│  │   (Notif)   │  │             │                              │
│  │             │  │             │                              │
│  └─────────────┘  └─────────────┘                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
         │
         │  REST API
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                    GOOGLE AI STUDIO                             │
│                                                                 │
│  ┌─────────────────────┐  ┌─────────────────────┐              │
│  │                     │  │                     │              │
│  │  Gemini 2.5 Flash Lite   │  │   Gemini 2.5 Flash Lite    │              │
│  │  (Food Detection)   │  │  (Recipe Generate)  │              │
│  │                     │  │                     │              │
│  └─────────────────────┘  └─────────────────────┘              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
SCAN FLOW:
──────────
User foto bahan
       │
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Camera    │────▶│  Compress   │────▶│   Upload    │
│   Capture   │     │   Image     │     │   Storage   │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
       ┌───────────────────────────────────────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Gemini    │────▶│    Parse    │────▶│   Match     │
│   Vision    │     │    JSON     │     │  Expiry DB  │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
       ┌───────────────────────────────────────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Confirm   │────▶│    Save     │────▶│  Schedule   │
│   Screen    │     │  Firestore  │     │   Notif     │
└─────────────┘     └─────────────┘     └─────────────┘


RECIPE FLOW:
────────────
User tap "Mau masak apa?"
       │
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Fetch     │────▶│   Build     │────▶│   Gemini    │
│  Inventory  │     │   Prompt    │     │    Pro      │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
       ┌───────────────────────────────────────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Parse     │────▶│   Display   │────▶│   Update    │
│   Recipes   │     │   Cards     │     │  Inventory  │
└─────────────┘     └─────────────┘     └─────────────┘
                                        (after cooking)
```

---

## 8. Database Schema

### Firestore Collections

```
┌─────────────────────────────────────────────────────────────┐
│                   FIRESTORE SCHEMA                          │
└─────────────────────────────────────────────────────────────┘

📁 users/
│
├── {userId}/
│   │
│   ├── uid: string
│   ├── email: string
│   ├── displayName: string
│   ├── photoURL: string
│   ├── createdAt: timestamp
│   ├── lastLoginAt: timestamp
│   ├── fcmToken: string (for push notifications)
│   │
│   ├── preferences: {
│   │   ├── notificationEnabled: boolean
│   │   ├── notificationTime: string ("08:00")
│   │   ├── cookingSkill: "beginner" | "intermediate" | "advanced"
│   │   └── dietaryRestrictions: string[] (["halal", "vegetarian"])
│   │   }
│   │
│   └── 📁 inventory/ (subcollection)
│       │
│       └── {itemId}/
│           ├── id: string
│           ├── name: string              // "telur"
│           ├── displayName: string       // "Telur Ayam"
│           ├── quantity: number          // 10
│           ├── unit: string              // "pcs" | "gram" | "ml" | "pack"
│           ├── category: string          // "protein" | "vegetable" | "dairy"
│           ├── imageUrl: string          // Firebase Storage URL
│           ├── addedAt: timestamp
│           ├── expiryDate: timestamp
│           ├── status: string            // "fresh" | "expiring" | "expired"
│           ├── isConsumed: boolean
│           └── consumedAt: timestamp (nullable)


📁 foodDatabase/ (global, read-only reference)
│
└── {foodId}/
    ├── name: string                      // "telur"
    ├── displayName: string               // "Telur Ayam"
    ├── aliases: string[]                 // ["telur", "egg", "telor"]
    ├── category: string                  // "protein"
    ├── defaultExpiryDays: number         // 21
    ├── storageType: string               // "fridge" | "freezer" | "pantry"
    └── icon: string                      // "🥚"


📁 recipes/ (optional cache, can be generated on-the-fly)
│
└── {recipeId}/
    ├── name: string
    ├── description: string
    ├── cookingTime: number (minutes)
    ├── difficulty: "easy" | "medium" | "hard"
    ├── servings: number
    ├── ingredients: [
    │   { name, amount, unit, optional }
    │   ]
    ├── instructions: string[]
    ├── tags: string[]
    ├── imageUrl: string
    └── createdAt: timestamp
```

### Data Models (Dart)

```dart
// User Model
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final String? fcmToken;
  final UserPreferences preferences;
}

class UserPreferences {
  final bool notificationEnabled;
  final String notificationTime;
  final String cookingSkill;
  final List<String> dietaryRestrictions;
}

// Inventory Item Model
class InventoryItem {
  final String id;
  final String name;
  final String displayName;
  final int quantity;
  final String unit;
  final String category;
  final String? imageUrl;
  final DateTime addedAt;
  final DateTime expiryDate;
  final ItemStatus status;
  final bool isConsumed;
  final DateTime? consumedAt;

  // Computed
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;
  bool get isExpiringSoon => daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  bool get isExpired => daysUntilExpiry < 0;
}

enum ItemStatus { fresh, expiring, expired }

// Recipe Model
class Recipe {
  final String name;
  final String description;
  final int cookingTime;
  final String difficulty;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final List<String> usesExpiringItems;
  final String? tips;
}

class RecipeIngredient {
  final String name;
  final String amount;
  final String unit;
  final bool fromInventory; // true = ada di kulkas user
}
```

### Food Database Sample

```json
{
  "telur": {
    "name": "telur",
    "displayName": "Telur Ayam",
    "aliases": ["telur", "egg", "telor", "telur ayam"],
    "category": "protein",
    "defaultExpiryDays": 21,
    "storageType": "fridge",
    "icon": "🥚"
  },
  "tomat": {
    "name": "tomat",
    "displayName": "Tomat",
    "aliases": ["tomat", "tomato", "tomat merah"],
    "category": "vegetable",
    "defaultExpiryDays": 7,
    "storageType": "fridge",
    "icon": "🍅"
  },
  "tahu": {
    "name": "tahu",
    "displayName": "Tahu Putih",
    "aliases": ["tahu", "tofu", "tahu putih"],
    "category": "protein",
    "defaultExpiryDays": 5,
    "storageType": "fridge",
    "icon": "🧈"
  },
  "ayam": {
    "name": "ayam",
    "displayName": "Daging Ayam",
    "aliases": ["ayam", "chicken", "daging ayam", "ayam potong"],
    "category": "protein",
    "defaultExpiryDays": 3,
    "storageType": "fridge",
    "icon": "🍗"
  },
  "kangkung": {
    "name": "kangkung",
    "displayName": "Kangkung",
    "aliases": ["kangkung", "water spinach"],
    "category": "vegetable",
    "defaultExpiryDays": 3,
    "storageType": "fridge",
    "icon": "🥬"
  }
}
```

---

## 9. API Integration

### Gemini Vision API (Food Detection) - ROBUST VERSION

> **CRITICAL:** Jangan percaya AI untuk estimasi quantity. AI hanya identify WHAT, code kita handle WHEN (expiry).

```dart
class GeminiVisionService {
  final model = GenerativeModel(
    model: 'gemini-2.0-flash-lite', // atau model yang tersedia
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  Future<List<DetectedFood>> detectFoodFromImage(Uint8List imageBytes) async {
    // ROBUST PROMPT - Anti-hallucination
    final prompt = '''
You are a food recognition assistant. Analyze this image and identify food items.

RULES:
1. Only identify items you are 90%+ confident about
2. If unsure between similar items (spinach vs kale), use generic category: "sayuran hijau"
3. DO NOT guess quantity or weight - always return quantity as 1
4. Use Indonesian food names in lowercase
5. If item is packaged with visible label, use the label name
6. If no food items detected, return empty array

CATEGORIES (use exactly these):
- protein (meat, eggs, tofu, tempeh, fish)
- vegetable (all vegetables)
- fruit (all fruits)
- dairy (milk, cheese, yogurt)
- grain (rice, bread, noodles)
- condiment (sauces, spices, oil)
- beverage (drinks)
- other (anything else)

OUTPUT FORMAT - Return ONLY valid JSON, no explanation:
[
  {"name": "telur", "category": "protein", "confidence": "high"},
  {"name": "sayuran hijau", "category": "vegetable", "confidence": "medium"}
]

If confidence is "medium", the app will ask user to confirm/correct.
If no food detected, return: []
''';

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    final response = await model.generateContent(content);
    return _parseDetectedFoods(response.text);
  }

  List<DetectedFood> _parseDetectedFoods(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      // Extract JSON from response (handle markdown code blocks)
      String cleanJson = jsonString;
      if (jsonString.contains('```')) {
        cleanJson = jsonString
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }

      final List<dynamic> parsed = json.decode(cleanJson);
      return parsed.map((item) {
        // DEFAULT QUANTITY = 1, user will adjust
        return DetectedFood(
          name: item['name'] ?? 'unknown',
          category: item['category'] ?? 'other',
          confidence: item['confidence'] ?? 'low',
          quantity: 1, // ALWAYS DEFAULT TO 1
          unit: 'pcs', // DEFAULT UNIT
        );
      }).toList();
    } catch (e) {
      print('Error parsing Gemini response: $e');
      return [];
    }
  }
}
```

### Gemini Pro API (Recipe Generation)

```dart
class GeminiRecipeService {
  final model = GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  Future<List<Recipe>> generateRecipes({
    required List<InventoryItem> inventory,
    required List<InventoryItem> expiringItems,
    String cookingSkill = 'beginner',
  }) async {
    final inventoryList = inventory
        .map((i) => "${i.name} (${i.quantity} ${i.unit})")
        .join(", ");

    final expiringList = expiringItems
        .map((i) => "${i.name} (expires in ${i.daysUntilExpiry} days)")
        .join(", ");

    final prompt = '''
Kamu adalah asisten chef Indonesia yang membantu mahasiswa kos memasak.

BAHAN YANG TERSEDIA DI KULKAS:
$inventoryList

BAHAN YANG HARUS SEGERA DIPAKAI (PRIORITAS):
$expiringList

SKILL LEVEL: $cookingSkill

Berikan 3 rekomendasi resep yang:
1. Menggunakan bahan yang tersedia (terutama yang mau expired)
2. Sesuai skill level (${cookingSkill == 'beginner' ? 'simple, max 20 menit' : 'bisa lebih kompleks'})
3. Cocok untuk 1-2 porsi (anak kos)

Format JSON (HANYA JSON, tanpa penjelasan lain):
{
  "recipes": [
    {
      "name": "Nama Resep",
      "description": "Deskripsi singkat",
      "cookingTime": 15,
      "difficulty": "easy",
      "servings": 2,
      "usesExpiringItems": ["tomat", "tahu"],
      "ingredients": [
        {"name": "tomat", "amount": "2", "unit": "buah", "fromInventory": true},
        {"name": "garam", "amount": "1/2", "unit": "sdt", "fromInventory": false}
      ],
      "instructions": [
        "Potong tomat menjadi dadu kecil",
        "Panaskan minyak di wajan",
        "..."
      ],
      "tips": "Tips memasak (optional)"
    }
  ]
}
''';

    final response = await model.generateContent([Content.text(prompt)]);
    return _parseRecipes(response.text);
  }
}
```

---

## 10. User Flow

### Main User Flows

```
┌─────────────────────────────────────────────────────────────┐
│                     USER FLOWS                              │
└─────────────────────────────────────────────────────────────┘

FLOW 1: ONBOARDING & AUTH
═════════════════════════
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Splash  │───▶│  Login  │───▶│ Google  │───▶│  Home   │
│ Screen  │    │ Screen  │    │  SSO    │    │ Screen  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘


FLOW 2: SCAN & ADD ITEMS
════════════════════════
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Home   │───▶│ Camera  │───▶│ Gemini  │───▶│ Confirm │
│         │    │ Screen  │    │ Vision  │    │ Results │
└─────────┘    └─────────┘    └─────────┘    └────┬────┘
                                                  │
                              ┌───────────────────┘
                              │
                              ▼
                         ┌─────────┐    ┌─────────┐
                         │  Save   │───▶│ Success │
                         │ to DB   │    │  Home   │
                         └─────────┘    └─────────┘


FLOW 3: GET RECIPE
══════════════════
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Home   │───▶│ Recipe  │───▶│ Recipe  │───▶│ Cooking │
│         │    │ Screen  │    │ Detail  │    │  Done   │
└─────────┘    └─────────┘    └─────────┘    └────┬────┘
                                                  │
                              ┌───────────────────┘
                              │
                              ▼
                         ┌─────────┐
                         │ Update  │
                         │Inventory│
                         └─────────┘


FLOW 4: NOTIFICATION → ACTION
═════════════════════════════
┌─────────┐    ┌─────────┐    ┌─────────┐
│  Push   │───▶│  Open   │───▶│ Recipe  │
│ Notif   │    │  App    │    │Suggest  │
└─────────┘    └─────────┘    └─────────┘
```

---

## 11. UI/UX Wireframes

### Screen: Home Dashboard

```
┌─────────────────────────────────────┐
│ ≡  The Anti-Basi          [avatar] │
├─────────────────────────────────────┤
│                                     │
│  Selamat pagi, Budi! 👋             │
│                                     │
│  ┌─────────────────────────────────┐│
│  │  ⚠️ PERLU PERHATIAN             ││
│  │                                 ││
│  │  🍅 Tomat      - Expired besok  ││
│  │  🧀 Tahu       - Expired 2 hari ││
│  │                                 ││
│  │  [Lihat Resep untuk Bahan Ini]  ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │  📦 INVENTORY KAMU              ││
│  │                                 ││
│  │  12 items di kulkas             ││
│  │  3 expiring soon                ││
│  │                                 ││
│  │  [Lihat Semua]                  ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │  🍳 MAU MASAK APA HARI INI?     ││
│  │                                 ││
│  │  [Tanya AI untuk Rekomendasi]   ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  [🏠]    [📷 SCAN]    [📦]    [⚙️] │
│  Home     Camera    Inventory  Settings
└─────────────────────────────────────┘
```

### Screen: Camera/Scan

```
┌─────────────────────────────────────┐
│ ←  Scan Bahan Makanan              │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────────┐│
│  │                                 ││
│  │                                 ││
│  │        [ CAMERA VIEW ]          ││
│  │                                 ││
│  │    Arahkan kamera ke bahan      ││
│  │         makanan kamu            ││
│  │                                 ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│           [ 📷 CAPTURE ]            │
│                                     │
│  ─────────── atau ───────────       │
│                                     │
│         [ 🖼️ Pilih dari Galeri ]   │
│                                     │
│  💡 Tips: Foto beberapa bahan      │
│     sekaligus juga bisa!           │
│                                     │
└─────────────────────────────────────┘
```

### Screen: Scan Results

```
┌─────────────────────────────────────┐
│ ←  Konfirmasi Hasil Scan           │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────────┐│
│  │  [Thumbnail of scanned image]   ││
│  └─────────────────────────────────┘│
│                                     │
│  🤖 Gemini mendeteksi:              │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ ☑️ Telur Ayam                   ││
│  │    Qty: [10] [pcs ▼]            ││
│  │    Exp: [14 hari]               ││
│  │                           [🗑️]  ││
│  ├─────────────────────────────────┤│
│  │ ☑️ Tomat Merah                  ││
│  │    Qty: [5]  [pcs ▼]            ││
│  │    Exp: [5 hari]                ││
│  │                           [🗑️]  ││
│  └─────────────────────────────────┘│
│                                     │
│  [+ Tambah Item Manual]             │
│                                     │
│  ┌─────────────────────────────────┐│
│  │      ✅ Simpan ke Inventory     ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Screen: Inventory

```
┌─────────────────────────────────────┐
│ ≡  Inventory Kulkas        [+ Add] │
├─────────────────────────────────────┤
│  🔍 Search...                       │
├─────────────────────────────────────┤
│  [All] [⚠️ Expiring] [✅ Fresh]     │
├─────────────────────────────────────┤
│                                     │
│  ⚠️ EXPIRING SOON                   │
│  ┌─────────────────────────────────┐│
│  │ 🍅 Tomat        5 pcs           ││
│  │    ⚠️ Expired besok!            ││
│  ├─────────────────────────────────┤│
│  │ 🧈 Tahu         2 kotak         ││
│  │    ⚠️ Expired dalam 2 hari      ││
│  └─────────────────────────────────┘│
│                                     │
│  ✅ FRESH                           │
│  ┌─────────────────────────────────┐│
│  │ 🥚 Telur       10 pcs           ││
│  │    Fresh - 12 hari lagi         ││
│  ├─────────────────────────────────┤│
│  │ 🍗 Ayam        500 gram         ││
│  │    Fresh - 6 hari lagi          ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  [🏠]    [📷 SCAN]    [📦]    [⚙️] │
└─────────────────────────────────────┘
```

### Screen: Recipe Suggestions

```
┌─────────────────────────────────────┐
│ ←  Rekomendasi Resep               │
├─────────────────────────────────────┤
│                                     │
│  🤖 Berdasarkan isi kulkasmu:       │
│                                     │
│  "Kamu punya tomat dan tahu yang    │
│   harus segera dipakai!"            │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ [📸]                            ││
│  │ 🍳 Tumis Tahu Tomat             ││
│  │ ⏱️ 15 min  |  📊 Easy           ││
│  │                                 ││
│  │ Uses: ✅ Tahu ✅ Tomat           ││
│  │                                 ││
│  │ [Lihat Resep]                   ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ [📸]                            ││
│  │ 🥚 Telur Dadar Tomat            ││
│  │ ⏱️ 10 min  |  📊 Easy           ││
│  │                                 ││
│  │ Uses: ✅ Telur ✅ Tomat          ││
│  │                                 ││
│  │ [Lihat Resep]                   ││
│  └─────────────────────────────────┘│
│                                     │
│  💬 Atau tanya langsung:            │
│  ┌─────────────────────────────────┐│
│  │ "Mau masak apa?"            [➤] ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Screen: Recipe Detail

```
┌─────────────────────────────────────┐
│ ←  Tumis Tahu Tomat          [❤️]  │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │       [Recipe Image]            ││
│  └─────────────────────────────────┘│
│                                     │
│  ⏱️ 15 min | 📊 Easy | 🍽️ 2 porsi  │
│                                     │
│  ━━ 📝 BAHAN-BAHAN ━━━━━━━━━━━━━━━ │
│                                     │
│  ✅ Tahu putih - 2 kotak (ada!)     │
│  ✅ Tomat - 3 buah (ada!)           │
│  ⬜ Kecap manis - 2 sdm             │
│  ⬜ Garam - secukupnya              │
│                                     │
│  ━━ 👨‍🍳 LANGKAH ━━━━━━━━━━━━━━━━━━ │
│                                     │
│  1. Potong tahu dadu, goreng        │
│     setengah matang                 │
│                                     │
│  2. Iris bawang dan tomat           │
│                                     │
│  3. Tumis bawang hingga harum       │
│                                     │
│  4. Masukkan tomat, aduk hingga     │
│     layu                            │
│                                     │
│  5. Tambahkan tahu, kecap, garam    │
│                                     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │  ✅ Selesai Masak!              ││
│  │  (Inventory akan di-update)     ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

---

## 12. Project Structure

```
the_anti_basi/
│
├── 📁 android/
├── 📁 ios/
│
├── 📁 lib/
│   ├── 📄 main.dart
│   │
│   ├── 📁 config/
│   │   ├── 📄 app_config.dart
│   │   ├── 📄 routes.dart
│   │   └── 📄 theme.dart
│   │
│   ├── 📁 core/
│   │   ├── 📄 constants.dart
│   │   └── 📁 utils/
│   │       ├── 📄 date_utils.dart
│   │       └── 📄 validators.dart
│   │
│   ├── 📁 data/
│   │   ├── 📁 models/
│   │   │   ├── 📄 user_model.dart
│   │   │   ├── 📄 inventory_item_model.dart
│   │   │   └── 📄 recipe_model.dart
│   │   │
│   │   ├── 📁 repositories/
│   │   │   ├── 📄 auth_repository.dart
│   │   │   ├── 📄 inventory_repository.dart
│   │   │   └── 📄 recipe_repository.dart
│   │   │
│   │   └── 📁 datasources/
│   │       └── 📄 food_database.dart
│   │
│   ├── 📁 services/
│   │   ├── 📄 auth_service.dart
│   │   ├── 📄 inventory_service.dart
│   │   ├── 📄 gemini_vision_service.dart
│   │   ├── 📄 gemini_recipe_service.dart
│   │   ├── 📄 notification_service.dart
│   │   └── 📄 image_service.dart
│   │
│   ├── 📁 providers/
│   │   ├── 📄 auth_provider.dart
│   │   ├── 📄 inventory_provider.dart
│   │   └── 📄 recipe_provider.dart
│   │
│   └── 📁 ui/
│       ├── 📁 screens/
│       │   ├── 📁 splash/
│       │   ├── 📁 auth/
│       │   ├── 📁 home/
│       │   ├── 📁 scan/
│       │   ├── 📁 inventory/
│       │   ├── 📁 recipe/
│       │   └── 📁 settings/
│       │
│       ├── 📁 widgets/
│       │   ├── 📁 common/
│       │   ├── 📁 inventory/
│       │   └── 📁 recipe/
│       │
│       └── 📁 theme/
│           ├── 📄 app_colors.dart
│           └── 📄 app_text_styles.dart
│
├── 📁 assets/
│   ├── 📁 images/
│   ├── 📁 icons/
│   └── 📁 data/
│       └── 📄 food_database.json
│
├── 📄 pubspec.yaml
├── 📄 .env
└── 📄 README.md
```

---

## 13. Development Phases

### Phase 1: Foundation
- [ ] Setup Flutter project
- [ ] Configure Firebase (Auth, Firestore, Storage)
- [ ] Setup environment variables
- [ ] Implement basic navigation (Go Router)
- [ ] Create app theme & design system

### Phase 2: Authentication
- [ ] Splash screen
- [ ] Login screen UI
- [ ] Google Sign-In integration
- [ ] Auth state management
- [ ] User profile creation in Firestore

### Phase 3: Smart Scan (Core Feature)
- [ ] Camera screen UI
- [ ] Image capture & gallery picker
- [ ] Image compression
- [ ] Upload to Firebase Storage
- [ ] Gemini Vision API integration
- [ ] Parse detection results
- [ ] Confirmation screen UI
- [ ] Save to Firestore inventory

### Phase 4: Inventory Management
- [ ] Inventory list screen
- [ ] Filter & search functionality
- [ ] Item detail screen
- [ ] Edit item
- [ ] Delete / mark as consumed
- [ ] Manual add item

### Phase 5: Recipe Suggestion (Core Feature)
- [ ] Recipe suggestion screen
- [ ] Gemini Pro API integration
- [ ] Recipe cards UI
- [ ] Recipe detail screen
- [ ] "Selesai masak" → update inventory

### Phase 6: Notifications
- [ ] Local notification setup
- [ ] Schedule expiry reminders
- [ ] Notification tap handling
- [ ] (Optional) FCM for push notifications

### Phase 7: Polish & Testing
- [ ] UI/UX refinement
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states
- [ ] Testing on real devices
- [ ] Bug fixes

### Phase 8: Submission Preparation
- [ ] Create presentation deck
- [ ] Record 3-minute demo video
- [ ] Write README for GitHub
- [ ] Deploy/build APK
- [ ] Submit to hackathon

---

## 14. Submission Checklist

Per InnovHack requirements:

### Mandatory Deliverables

- [ ] **Project Deck / Presentation**
  - Problem statement
  - Solution overview
  - Target users
  - Key features
  - Google technologies used
  - Impact and future scope

- [ ] **MVP Link**
  - Working Android APK / iOS TestFlight
  - Or: Web demo link (if applicable)

- [ ] **Demo Video (3 minutes max)**
  - Problem introduction
  - Solution demo
  - Live feature walkthrough
  - Impact statement

- [ ] **GitHub Repository**
  - Complete source code
  - README with setup instructions
  - Environment variables template

- [ ] **Google Technologies List**
  - Gemini 1.5 Flash (Vision)
  - Gemini 1.5 Pro (Text)
  - Firebase Auth
  - Cloud Firestore
  - Firebase Storage
  - Firebase Cloud Messaging

- [ ] **Solution Description (100 words)**

### Sample 100-Word Description

> **The Anti-Basi** is a smart fridge management app that helps students reduce food waste. Using **Google Gemini Vision**, users can simply photograph their groceries to automatically detect and track food items with estimated expiry dates. The app sends timely reminders before items expire and uses **Gemini Pro** to suggest recipes based on available ingredients, prioritizing items that need to be used soon. Built with **Flutter** and **Firebase**, The Anti-Basi transforms how students manage their kitchen inventory, saving money and reducing the 27 million tons of food wasted annually in Indonesia.

---

## Quick Links

| Resource | URL |
|----------|-----|
| Google AI Studio | https://aistudio.google.com |
| Firebase Console | https://console.firebase.google.com |
| Flutter Docs | https://docs.flutter.dev |
| Gemini API Docs | https://ai.google.dev/docs |
| Firebase Flutter Docs | https://firebase.google.com/docs/flutter/setup |

---

## Notes

### Tips for Hackathon Success
1. **Focus on core features** - Smart Scan + Recipe AI adalah wow factor
2. **Make demo impressive** - Live scan demo akan memorable
3. **Highlight Google tech** - Gemini adalah flagship Google AI
4. **Show real impact** - Food waste reduction adalah masalah nyata
5. **Keep it simple** - MVP yang works > banyak fitur setengah jadi

### Potential Challenges & Solutions
| Challenge | Solution |
|-----------|----------|
| Gemini accuracy | Allow manual edit/correction |
| Expiry date estimation | Use lookup table for common foods |
| Offline usage | Cache inventory locally |
| Image size | Compress before upload |

---

---

## 15. Critical Design Decisions

> **Based on strategic review - these decisions are NON-NEGOTIABLE for winning**

### Decision 1: AI Responsibility Split

```
┌─────────────────────────────────────────────────────────────────┐
│                  WHO DOES WHAT?                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  GEMINI VISION (AI):                                           │
│  ├── ✅ Identify WHAT food item it is                          │
│  ├── ✅ Categorize into food groups                            │
│  ├── ❌ DO NOT estimate quantity (bad at counting)             │
│  └── ❌ DO NOT guess freshness/condition                       │
│                                                                 │
│  OUR CODE (Deterministic):                                     │
│  ├── ✅ Default quantity = 1 (user adjusts)                    │
│  ├── ✅ Calculate expiry = DateTime.now() + foodDB.expiryDays  │
│  ├── ✅ Determine status based on date math                    │
│  └── ✅ Match detected name to foodDatabase                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Decision 2: Expiry Date Logic

```dart
// CORRECT APPROACH: Database-driven expiry
DateTime calculateExpiryDate(String foodName) {
  final foodInfo = foodDatabase[foodName];

  if (foodInfo != null) {
    return DateTime.now().add(Duration(days: foodInfo.defaultExpiryDays));
  }

  // Fallback for unknown items
  return DateTime.now().add(Duration(days: 7)); // Conservative default
}

// WRONG APPROACH: Asking AI to guess expiry
// ❌ "How fresh does this tomato look?" - NEVER DO THIS
```

### Decision 3: Feature Cuts for MVP

```
┌─────────────────────────────────────────────────────────────────┐
│                    FEATURES TO CUT                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ❌ CUT - Settings Page                                        │
│     Reason: Waste of dev time, judges don't care               │
│                                                                 │
│  ❌ CUT - User Preferences (cooking skill, dietary)            │
│     Reason: Assume everyone is beginner for MVP                │
│                                                                 │
│  ❌ CUT - Edit Profile / Avatar                                │
│     Reason: Zero value for demo                                │
│                                                                 │
│  ❌ CUT - Complex Auth flows                                   │
│     Reason: Use Anonymous Auth or simple Google SSO            │
│     Fallback: Hardcode demo user if auth gives trouble         │
│                                                                 │
│  ❌ CUT - FCM Push Notifications (for MVP)                     │
│     Reason: Local notifications work, FCM setup is complex     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Decision 4: Add Gamification - "Money Saved" Counter

```dart
// Add estimatedPrice to food database
class FoodInfo {
  final String name;
  final int defaultExpiryDays;
  final int estimatedPriceIDR; // NEW: estimated price in Rupiah
  // ...
}

// Food database with prices
const foodDatabase = {
  "telur": FoodInfo(
    name: "telur",
    defaultExpiryDays: 21,
    estimatedPriceIDR: 2500, // per butir
  ),
  "tomat": FoodInfo(
    name: "tomat",
    defaultExpiryDays: 7,
    estimatedPriceIDR: 3000, // per buah
  ),
  "ayam": FoodInfo(
    name: "ayam",
    defaultExpiryDays: 3,
    estimatedPriceIDR: 35000, // per 500g
  ),
};

// When user cooks something that was expiring:
void onCookingComplete(Recipe recipe) {
  int savedAmount = 0;

  for (final ingredient in recipe.usesExpiringItems) {
    final food = foodDatabase[ingredient];
    if (food != null) {
      savedAmount += food.estimatedPriceIDR;
    }
  }

  // Show celebration popup
  showDialog(
    child: MoneySavedPopup(
      message: "Kamu baru selamatkan Rp ${savedAmount.toFormatted()}!",
      // "You just saved Rp 15,000 by cooking this!"
    ),
  );

  // Update lifetime saved counter
  userStats.totalMoneySaved += savedAmount;
}
```

### Decision 5: One-Tap Aggressive Recipe

```
WRONG UX (Decision Fatigue):
┌─────────────────────────────────────────────────────────────────┐
│  Your spinach expires tomorrow.                                 │
│  What would you like to do?                                    │
│                                                                 │
│  [ ] Find recipes                                              │
│  [ ] Set reminder                                              │
│  [ ] Mark as used                                              │
│  [ ] Ignore                                                    │
└─────────────────────────────────────────────────────────────────┘

CORRECT UX (Aggressive Suggestion):
┌─────────────────────────────────────────────────────────────────┐
│  ⚠️ Kangkung kamu expired BESOK!                               │
│                                                                 │
│  🍳 TUMIS KANGKUNG - 10 menit                                  │
│  Kamu punya semua bahannya!                                    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              🍳 MASAK SEKARANG                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│                  [Lihat resep lain]                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 16. Demo Strategy

> **12 days left. Stop planning. Start coding. But demo smart.**

### Pre-Demo Checklist

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEMO PREPARATION                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. TEST YOUR EXACT DEMO INGREDIENTS                           │
│     ├── Buy/prepare the actual items you'll scan on video      │
│     ├── Test Gemini response for EACH item 5+ times            │
│     ├── Note which items have consistent detection             │
│     └── Avoid items that Gemini struggles with                 │
│                                                                 │
│  2. RECOMMENDED DEMO ITEMS (High Detection Accuracy):          │
│     ├── ✅ Telur (eggs) - very recognizable                    │
│     ├── ✅ Tomat - distinct color and shape                    │
│     ├── ✅ Wortel - distinct color                             │
│     ├── ✅ Bawang - recognizable                               │
│     ├── ✅ Apel/Jeruk - distinct fruits                        │
│     └── ⚠️ Avoid: leafy greens (hard to differentiate)        │
│                                                                 │
│  3. PRE-SEED DATABASE                                          │
│     ├── Have some items already in inventory                   │
│     ├── Make sure some are "expiring soon" for demo            │
│     └── This shows the full flow without waiting               │
│                                                                 │
│  4. HAPPY PATH SCRIPT                                          │
│     Write exact script of what you'll do in demo video         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3-Minute Demo Script

```
┌─────────────────────────────────────────────────────────────────┐
│                    VIDEO SCRIPT (3 MIN)                         │
└─────────────────────────────────────────────────────────────────┘

[0:00 - 0:25] THE HOOK
══════════════════════
🎬 Scene: B-roll of kulkas anak kos, ada sayur busuk

Narration:
"Pernahkah kamu buka kulkas, dan menemukan sayur yang sudah
membusuk karena lupa?

Di Indonesia, 27 juta ton makanan terbuang setiap tahun.
Itu sama dengan Rp 500 triliun - uang yang terbuang sia-sia.

Kami membuat solusinya."


[0:25 - 0:45] THE SOLUTION
══════════════════════════
🎬 Scene: Show app splash, explain tagline

Narration:
"Introducing The Anti-Basi - AI-powered fridge manager.

Foto bahan makananmu, biarkan AI yang mencatat.
Dapat reminder sebelum expired.
Dapat resep dari bahan yang ada."


[0:45 - 1:30] LIVE DEMO - SCAN
══════════════════════════════
🎬 Demo: Actually scan groceries LIVE

Narration:
"Mari saya tunjukkan. Saya baru pulang belanja..."

Action:
1. Open camera screen
2. Point at groceries (eggs, tomatoes, carrots)
3. Capture photo
4. Show AI detection results
5. Quick edit quantity if needed
6. Save to inventory

"Dalam 10 detik, semua bahan tercatat dengan tanggal kadaluarsa."


[1:30 - 2:15] LIVE DEMO - RECIPE
════════════════════════════════
🎬 Demo: Show expiring items, get recipe

Narration:
"Sekarang lihat, tomat saya akan expired besok.
Daripada terbuang, saya tanya AI..."

Action:
1. Show inventory with expiring tomato
2. Tap "Masak Sekarang"
3. AI generates recipe using tomato
4. Show recipe detail
5. Tap "Selesai Masak"
6. Show "You saved Rp 5,000!" popup


[2:15 - 2:45] IMPACT & TECH
═══════════════════════════
🎬 Scene: Stats screen, tech logos

Narration:
"Dengan The Anti-Basi:
- Hemat uang dari makanan yang terbuang
- Tidak bingung mau masak apa
- Kontribusi kurangi food waste Indonesia

Dibangun dengan Google Gemini untuk AI vision,
dan Firebase untuk backend."


[2:45 - 3:00] CLOSING
═════════════════════
🎬 Scene: App logo, team, tagline

Narration:
"The Anti-Basi - Because good food deserves to be eaten,
not thrown away.

Terima kasih."
```

### Fallback Plans

```
┌─────────────────────────────────────────────────────────────────┐
│                    IF THINGS GO WRONG                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  IF: Gemini Vision fails during demo                           │
│  THEN: Have pre-recorded successful scan as backup             │
│        OR: Show manual add feature, pivot narrative            │
│                                                                 │
│  IF: Auth/Login fails                                          │
│  THEN: Use hardcoded demo account, skip auth in video          │
│                                                                 │
│  IF: Recipe generation is slow                                 │
│  THEN: Pre-cache some recipes, use loading animation           │
│                                                                 │
│  IF: App crashes                                                │
│  THEN: Record demo in multiple takes, edit together            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Development Priority (12 Days)

```
WEEK 1 (Day 1-7): CORE FEATURES
═══════════════════════════════
Day 1-2: Project setup, Firebase config, basic navigation
Day 3-4: Camera → Gemini Vision → Parse results (CRITICAL PATH)
Day 5-6: Inventory CRUD, expiry logic
Day 7:   Recipe generation with Gemini

WEEK 2 (Day 8-12): POLISH & SUBMIT
══════════════════════════════════
Day 8-9:   UI polish, error handling
Day 10:    Local notifications
Day 11:    Testing, bug fixes, demo recording
Day 12:    Video editing, submission prep, SUBMIT

⚠️ DO NOT ADD NEW FEATURES AFTER DAY 9
```

---

## Food Database (Minimal Viable)

```json
{
  "telur": {
    "name": "telur",
    "displayName": "Telur",
    "aliases": ["telur", "egg", "telor"],
    "category": "protein",
    "defaultExpiryDays": 21,
    "estimatedPriceIDR": 2500,
    "icon": "🥚"
  },
  "tomat": {
    "name": "tomat",
    "displayName": "Tomat",
    "aliases": ["tomat", "tomato"],
    "category": "vegetable",
    "defaultExpiryDays": 7,
    "estimatedPriceIDR": 3000,
    "icon": "🍅"
  },
  "wortel": {
    "name": "wortel",
    "displayName": "Wortel",
    "aliases": ["wortel", "carrot"],
    "category": "vegetable",
    "defaultExpiryDays": 14,
    "estimatedPriceIDR": 5000,
    "icon": "🥕"
  },
  "ayam": {
    "name": "ayam",
    "displayName": "Daging Ayam",
    "aliases": ["ayam", "chicken", "daging ayam"],
    "category": "protein",
    "defaultExpiryDays": 3,
    "estimatedPriceIDR": 35000,
    "icon": "🍗"
  },
  "tahu": {
    "name": "tahu",
    "displayName": "Tahu",
    "aliases": ["tahu", "tofu"],
    "category": "protein",
    "defaultExpiryDays": 5,
    "estimatedPriceIDR": 5000,
    "icon": "🧈"
  },
  "tempe": {
    "name": "tempe",
    "displayName": "Tempe",
    "aliases": ["tempe", "tempeh"],
    "category": "protein",
    "defaultExpiryDays": 4,
    "estimatedPriceIDR": 5000,
    "icon": "🫘"
  },
  "kangkung": {
    "name": "kangkung",
    "displayName": "Kangkung",
    "aliases": ["kangkung", "water spinach"],
    "category": "vegetable",
    "defaultExpiryDays": 3,
    "estimatedPriceIDR": 5000,
    "icon": "🥬"
  },
  "bayam": {
    "name": "bayam",
    "displayName": "Bayam",
    "aliases": ["bayam", "spinach"],
    "category": "vegetable",
    "defaultExpiryDays": 3,
    "estimatedPriceIDR": 5000,
    "icon": "🥬"
  },
  "bawang_merah": {
    "name": "bawang_merah",
    "displayName": "Bawang Merah",
    "aliases": ["bawang merah", "shallot", "bamer"],
    "category": "condiment",
    "defaultExpiryDays": 30,
    "estimatedPriceIDR": 8000,
    "icon": "🧅"
  },
  "bawang_putih": {
    "name": "bawang_putih",
    "displayName": "Bawang Putih",
    "aliases": ["bawang putih", "garlic", "baput"],
    "category": "condiment",
    "defaultExpiryDays": 30,
    "estimatedPriceIDR": 10000,
    "icon": "🧄"
  },
  "cabai": {
    "name": "cabai",
    "displayName": "Cabai",
    "aliases": ["cabai", "cabe", "chili"],
    "category": "condiment",
    "defaultExpiryDays": 10,
    "estimatedPriceIDR": 10000,
    "icon": "🌶️"
  },
  "nasi": {
    "name": "nasi",
    "displayName": "Nasi (Sisa)",
    "aliases": ["nasi", "rice"],
    "category": "grain",
    "defaultExpiryDays": 2,
    "estimatedPriceIDR": 5000,
    "icon": "🍚"
  },
  "mie_instant": {
    "name": "mie_instant",
    "displayName": "Mie Instant",
    "aliases": ["mie", "indomie", "mie instant", "noodle"],
    "category": "grain",
    "defaultExpiryDays": 180,
    "estimatedPriceIDR": 3500,
    "icon": "🍜"
  },
  "susu": {
    "name": "susu",
    "displayName": "Susu",
    "aliases": ["susu", "milk"],
    "category": "dairy",
    "defaultExpiryDays": 7,
    "estimatedPriceIDR": 15000,
    "icon": "🥛"
  },
  "keju": {
    "name": "keju",
    "displayName": "Keju",
    "aliases": ["keju", "cheese"],
    "category": "dairy",
    "defaultExpiryDays": 14,
    "estimatedPriceIDR": 20000,
    "icon": "🧀"
  },
  "sayuran_hijau": {
    "name": "sayuran_hijau",
    "displayName": "Sayuran Hijau",
    "aliases": ["sayuran hijau", "sayur", "greens", "vegetable"],
    "category": "vegetable",
    "defaultExpiryDays": 4,
    "estimatedPriceIDR": 5000,
    "icon": "🥬"
  },
  "buah": {
    "name": "buah",
    "displayName": "Buah",
    "aliases": ["buah", "fruit"],
    "category": "fruit",
    "defaultExpiryDays": 7,
    "estimatedPriceIDR": 10000,
    "icon": "🍎"
  },
  "unknown": {
    "name": "unknown",
    "displayName": "Item Lainnya",
    "aliases": [],
    "category": "other",
    "defaultExpiryDays": 7,
    "estimatedPriceIDR": 10000,
    "icon": "📦"
  }
}
```

---

*Last updated: December 2025*
*Hackathon: InnovHack - GDG SASTRA University 2025*
