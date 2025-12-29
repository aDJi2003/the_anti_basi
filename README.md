# The Anti-Basi 🍎🥦🧊

**Smart Fridge Manager - Reduce Waste, Cook Smart**

> **Hackathon Project:** InnovHack - GDG SASTRA University 2025

**The Anti-Basi** (Indonesian slang: "Anti Stale/Expired") is a smart mobile application designed to help students and young professionals manage their fridge inventory, track food expiry dates, and discover recipes based on available ingredients using Google Gemini AI.

Every year, millions of tons of food are wasted. The Anti-Basi aims to solve this by making fridge management effortless and intelligent.

## ✨ Key Features

### 📸 Smart Scan (Gemini Vision)
*   **AI-Powered Detection:** Simply take a photo of your groceries.
*   **No Barcodes Needed:** Gemini Vision automatically identifies fresh produce, packaged goods, and counts quantities.
*   **Instant Inventory:** Automatically adds items to your digital fridge with categorized tags.

### 📦 Inventory Management
*   **Expiry Tracking:** Automatic status updates (✅ Fresh, ⚠️ Expiring Soon, ❌ Expired).
*   **Visual Organization:** Clean list view with color-coded indicators.
*   **Easy Edits:** Quickly adjust quantities or details if needed.

### 👨‍🍳 AI Recipe Suggestions
*   **Waste-Reducing Recipes:** Generates recipes specifically using ingredients that are about to expire.
*   **Context-Aware:** Suggests meals based on your available inventory.
*   **Complete Guide:** Provides ingredients lists and step-by-step cooking instructions.

### 🔔 Smart Notifications
*   **Expiry Reminders:** Get push notifications before your food goes bad.
*   **Actionable Alerts:** Click a notification to immediately see recipe ideas for that item.

### 👤 User Profile
*   **Preferences:** Set your cooking skill level and dietary restrictions.
*   **Theme Support:** Beautiful UI with full Dark Mode & Light Mode support.

## 🛠 Tech Stack

Built with ❤️ using Google Technologies:

*   **Framework:** Flutter 3.x (Dart)
*   **AI Intelligence:** Google Gemini 2.5 Flash Lite
    *   *Vision:* For food detection and counting.
    *   *Generative Text:* For recipe creation and context awareness.
*   **Backend & Cloud:** Firebase
    *   *Authentication:* Google Sign-In & Email/Password.
    *   *Cloud Firestore:* Real-time database for inventory and users.
    *   *Cloud Messaging (FCM):* Push notifications.
    *   *Storage:* Profile photos and assets.
*   **State Management:** Riverpod
*   **Navigation:** Go Router

## 🚀 Getting Started

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed (v3.10+ recommended)
*   [Firebase CLI](https://firebase.google.com/docs/cli)
*   Google AI Studio API Key (for Gemini)

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/the_anti_basi.git
    cd the_anti_basi
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Environment Setup**
    Create a `.env` file in the root directory and add your Gemini API Key:
    ```env
    GEMINI_API_KEY=your_actual_api_key_here
    ```

4.  **Firebase Configuration**
    *   Create a project in the [Firebase Console](https://console.firebase.google.com/).
    *   Configure Android (`google-services.json`) and iOS (`GoogleService-Info.plist`) apps.
    *   Place the configuration files in `android/app/` and `ios/Runner/` respectively.

5.  **Run the App**
    ```bash
    flutter run
    ```

## 📱 Project Structure

The project follows a clean architecture approach:

```
lib/
├── config/       # App configuration (routes, themes, colors)
├── core/         # Core utilities and constants (date logic, formatters)
├── data/         # Data layer
│   ├── models/       # Data models (InventoryItem, Recipe, etc.)
│   ├── repositories/ # Firestore interactions
│   ├── services/     # External services (Gemini, Camera, FCM)
│   └── providers/    # Riverpod state providers
├── ui/           # Presentation layer
│   ├── screens/      # Application screens (Home, Scan, Inventory, Recipe)
│   └── widgets/      # Reusable UI components
└── main.dart     # Application entry point
```

## 🤝 Contributing

Contributions are welcome! Whether it's reporting a bug, suggesting a feature, or writing code, we value your feedback.

---

*Because good food deserves to be eaten, not thrown away.*