import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../models/recipe.dart';
import '../models/scanned_item.dart';

/// Service for Gemini AI image processing
class GeminiService {
  GeminiService() {
    _initModel();
  }

  GenerativeModel? _model;
  bool _isInitialized = false;

  /// Check if service is ready
  bool get isReady => _isInitialized && _model != null;

  /// Initialize Gemini model
  void _initModel() {
    try {
      // Check if dotenv is loaded
      if (!dotenv.isInitialized) {
        debugPrint('[GeminiService] WARNING: dotenv not initialized');
        return;
      }

      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
        debugPrint('[GeminiService] WARNING: GEMINI_API_KEY not configured');
        return;
      }

      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 4096,
          responseMimeType: 'application/json',
        ),
      );

      _isInitialized = true;
      debugPrint('[GeminiService] Model initialized');
    } catch (e) {
      debugPrint('[GeminiService] ERROR initializing: $e');
      _isInitialized = false;
    }
  }

  /// Process image and extract food items
  Future<List<ScannedItem>> processImage(String imagePath) async {
    if (_model == null) {
      debugPrint('[GeminiService] Model not initialized, returning empty list');
      return [];
    }

    try {
      debugPrint('[GeminiService] Processing image: $imagePath');

      // Read image bytes
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      final imageBytes = await imageFile.readAsBytes();
      final mimeType = _getMimeType(imagePath);

      debugPrint('[GeminiService] Image size: ${imageBytes.length} bytes, type: $mimeType');

      // ROBUST PROMPT - Anti-hallucination + Safety filter
      const prompt = '''
You are a STRICT food recognition assistant for a fridge management app.
Analyze this image and identify ONLY legitimate food/grocery items that belong in a refrigerator.

CRITICAL SAFETY RULES (MUST FOLLOW):
1. ONLY detect food, beverages, and normal grocery items that belong in a fridge
2. IMMEDIATELY REJECT and return empty array if you detect:
   - Weapons, explosives, bombs, ammunition
   - Poisons, toxic substances, chemicals, cleaning products
   - Drugs, medications, pharmaceuticals
   - Non-food objects (electronics, tools, toys, etc.)
   - Inappropriate or offensive content
   - Anything that is NOT a legitimate grocery/food item
3. When in doubt, DO NOT include the item - safety first!

DETECTION RULES:
1. Only identify items you are 90%+ confident about
2. If unsure between similar items, use generic category name
3. Use English food names in lowercase
4. If item is packaged with visible label, use the label name
5. If no valid food items detected, return empty array

QUANTITY COUNTING:
- For COUNTABLE items (eggs, apples, bottles, cans, etc.): COUNT and return the actual number you see
- For UNCOUNTABLE items (milk, rice, meat, etc.): return quantity as 1
- If you can clearly see multiple of the same item, count them (e.g., 6 eggs, 3 apples)
- If quantity is unclear or partially hidden, make your best estimate
- User can always correct the quantity, so it's okay to guess

VALID CATEGORIES (use exactly these):
- protein (meat, eggs, tofu, tempeh, fish, chicken, beef, seafood)
- vegetable (all vegetables, leafy greens, root vegetables)
- fruit (all fresh fruits)
- dairy (milk, cheese, yogurt, butter, cream)
- grain (rice, bread, noodles, pasta, cereal, flour)
- condiment (sauces, spices, oil, salt, pepper, herbs)
- beverage (drinks, juice, soda, water, tea, coffee)
- other (other legitimate food items only)

CONFIDENCE LEVELS:
- "high" = 90%+ sure this is a valid food item
- "medium" = 70-90% sure (user will confirm)
- "low" = below 70% (skip these items)

OUTPUT FORMAT - Return ONLY valid JSON, no explanation:
{
  "items": [
    {"name": "eggs", "category": "protein", "quantity": 6, "confidence": "high"},
    {"name": "milk", "category": "dairy", "quantity": 1, "confidence": "high"},
    {"name": "apple", "category": "fruit", "quantity": 3, "confidence": "medium"}
  ]
}

If confidence is "medium", the app will ask user to confirm/correct.
If no valid food detected OR image contains non-food/dangerous items, return: {"items": []}
''';

      // Send to Gemini
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ]),
      ];

      debugPrint('[GeminiService] Sending request to Gemini...');
      final response = await _model!.generateContent(content);
      final responseText = response.text;

      debugPrint('[GeminiService] Response: $responseText');

      if (responseText == null || responseText.isEmpty) {
        debugPrint('[GeminiService] Empty response from Gemini');
        return [];
      }

      // Parse JSON response
      return _parseResponse(responseText);
    } catch (e, stack) {
      debugPrint('[GeminiService] ERROR processing image: $e');
      debugPrint('[GeminiService] Stack: $stack');
      return [];
    }
  }

  /// Parse Gemini response JSON into ScannedItem list
  List<ScannedItem> _parseResponse(String jsonString) {
    try {
      // Clean up JSON string (remove markdown code blocks if present)
      var cleanJson = jsonString.trim();
      if (cleanJson.contains('```')) {
        cleanJson = cleanJson
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }

      final Map<String, dynamic> data = jsonDecode(cleanJson);
      final List<dynamic> items = data['items'] ?? [];

      debugPrint('[GeminiService] Parsed ${items.length} items');

      return items.map((item) {
        final rawName = item['name'] as String? ?? 'unknown item';
        final categoryStr = item['category'] as String? ?? 'other';
        final confidenceStr = item['confidence'] as String? ?? 'low';
        // Get quantity from Gemini, default to 1 if not provided
        final quantity = (item['quantity'] as num?)?.toDouble() ?? 1.0;

        // Convert string confidence to numeric (for UI display)
        final confidenceValue = _parseConfidence(confidenceStr);

        // Skip low confidence items
        if (confidenceStr == 'low') {
          debugPrint('[GeminiService] Skipping low confidence item: $rawName');
          return null;
        }

        // Capitalize first letter of each word for display
        final name = _capitalizeWords(rawName);

        return ScannedItem(
          id: const Uuid().v4(),
          name: name,
          category: _parseCategory(categoryStr),
          quantity: quantity, // Use Gemini's count, user can adjust if wrong
          unit: _getDefaultUnit(categoryStr), // Default unit based on category
          expiryDate: null, // Will be set based on category defaults or user input
          confidence: confidenceValue,
          isSelected: confidenceStr == 'high', // Auto-select high confidence items
          isUnknown: false, // Only true for completely undetectable items
        );
      }).whereType<ScannedItem>().toList(); // Filter out nulls
    } catch (e) {
      debugPrint('[GeminiService] ERROR parsing response: $e');
      return [];
    }
  }

  /// Convert string confidence to numeric value
  double _parseConfidence(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'high':
        return 0.95;
      case 'medium':
        return 0.75;
      case 'low':
        return 0.5;
      default:
        return 0.5;
    }
  }

  /// Capitalize first letter of each word
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Get default unit based on category
  String _getDefaultUnit(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return 'L'; // milk, yogurt usually in liters
      case 'beverage':
        return 'bottles';
      case 'grain':
        return 'kg';
      case 'vegetable':
      case 'fruit':
        return 'pcs';
      case 'protein':
        return 'pcs'; // eggs, meat pieces
      case 'condiment':
        return 'bottles';
      default:
        return 'pcs';
    }
  }

  /// Parse category string to ItemCategory enum
  ItemCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return ItemCategory.dairy;
      case 'protein':
        return ItemCategory.protein;
      case 'vegetable':
        return ItemCategory.vegetable;
      case 'fruit':
        return ItemCategory.fruit;
      case 'grain':
        return ItemCategory.grain;
      case 'condiment':
        return ItemCategory.condiment;
      case 'beverage':
        return ItemCategory.beverage;
      default:
        return ItemCategory.other;
    }
  }

  /// Get MIME type from file path
  String _getMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ============ RECIPE GENERATION ============

  /// Generate recipes based on inventory items
  Future<List<Recipe>> generateRecipes(List<InventoryItem> inventory) async {
    if (_model == null) {
      debugPrint('[GeminiService] Model not initialized, returning empty list');
      return [];
    }

    if (inventory.isEmpty) {
      debugPrint('[GeminiService] No inventory items, returning empty list');
      return [];
    }

    try {
      debugPrint('[GeminiService] Generating recipes for ${inventory.length} items');

      // Build inventory list string
      final inventoryList = inventory
          .map((i) => "${i.name} (${i.quantity} ${i.unit}, exp: ${i.daysUntilExpiry} days)")
          .join(", ");

      // Get expiring items (within 3 days)
      final expiringItems = inventory
          .where((i) => i.daysUntilExpiry <= 3 && i.daysUntilExpiry >= 0)
          .map((i) => i.name)
          .toList();

      final expiringList = expiringItems.isNotEmpty
          ? expiringItems.join(", ")
          : "None expiring soon";

      debugPrint('[GeminiService] Expiring items: $expiringList');

      // Build prompt
      final prompt = _buildRecipePrompt(inventoryList, expiringList);

      // Send to Gemini
      final content = [Content.text(prompt)];

      debugPrint('[GeminiService] Sending recipe request to Gemini...');
      final response = await _model!.generateContent(content);
      final responseText = response.text;

      debugPrint('[GeminiService] Recipe response: $responseText');

      if (responseText == null || responseText.isEmpty) {
        debugPrint('[GeminiService] Empty response from Gemini');
        return [];
      }

      // Parse JSON response
      return _parseRecipeResponse(responseText, expiringItems);
    } catch (e, stack) {
      debugPrint('[GeminiService] ERROR generating recipes: $e');
      debugPrint('[GeminiService] Stack: $stack');
      return [];
    }
  }

  /// Build recipe generation prompt
  String _buildRecipePrompt(String inventoryList, String expiringList) {
    return '''
You are a helpful home chef assistant. Suggest easy recipes using available ingredients.

INGREDIENTS IN FRIDGE:
$inventoryList

PRIORITY (USE THESE FIRST - expiring soon):
$expiringList

Generate 3 recipes that:
1. Use available ingredients (prioritize expiring items)
2. Are easy to make (max 30 minutes, simple equipment)
3. Serve 1-2 portions (suitable for students/individuals)
4. Can be Asian, Western, or fusion - whatever works best with ingredients

IMPORTANT: ALL output must be in ENGLISH - recipe names, descriptions, ingredients, instructions, everything.

OUTPUT FORMAT - Return ONLY valid JSON, no explanation:
{
  "recipes": [
    {
      "name": "Recipe Name in English",
      "description": "Brief one-sentence description in English",
      "cookTime": 15,
      "difficulty": "easy",
      "servings": 2,
      "usesExpiringItems": ["tomato", "tofu"],
      "ingredients": [
        {"name": "tomato", "quantity": "2 pcs"},
        {"name": "tofu", "quantity": "1 block"},
        {"name": "salt", "quantity": "to taste"}
      ],
      "instructions": [
        {"stepNumber": 1, "title": "Prep Ingredients", "description": "Cut tofu and tomatoes into small cubes"},
        {"stepNumber": 2, "title": "Saute", "description": "Heat oil in pan, saute garlic until fragrant"},
        {"stepNumber": 3, "title": "Cook", "description": "Add tofu and tomatoes, stir well, season with salt"}
      ],
      "proTip": "Brief cooking tip (optional)"
    }
  ]
}

RULES:
- ALL text must be in English
- difficulty: "easy" (< 15 min), "medium" (15-25 min), "hard" (> 25 min)
- usesExpiringItems: only include items from PRIORITY list
- ingredients: use practical quantities (pcs, cups, tbsp, etc.)
- instructions: maximum 5 steps, clear and concise
''';
  }

  /// Parse recipe response from Gemini
  List<Recipe> _parseRecipeResponse(String jsonString, List<String> expiringItems) {
    try {
      // Clean up JSON string
      var cleanJson = jsonString.trim();
      if (cleanJson.contains('```')) {
        cleanJson = cleanJson
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }

      final Map<String, dynamic> data = jsonDecode(cleanJson);
      final List<dynamic> recipesJson = data['recipes'] ?? [];

      debugPrint('[GeminiService] Parsed ${recipesJson.length} recipes');

      return recipesJson.map((json) {
        final id = const Uuid().v4();
        return Recipe.fromGeminiJson(json as Map<String, dynamic>, id);
      }).toList();
    } catch (e) {
      debugPrint('[GeminiService] ERROR parsing recipe response: $e');
      return [];
    }
  }
}

// ============ PROVIDERS ============

/// Provider for Gemini service
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
