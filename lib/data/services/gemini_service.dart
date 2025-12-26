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

      // ROBUST PROMPT - Anti-hallucination (from plan.md)
      const prompt = '''
You are a food recognition assistant. Analyze this image and identify food items.

RULES:
1. Only identify items you are 90%+ confident about
2. If unsure between similar items, use generic category name
3. DO NOT guess quantity or weight - always return quantity as 1
4. Use English food names in lowercase
5. If item is packaged with visible label, use the label name
6. If no food items detected, return empty array

CATEGORIES (use exactly these):
- protein (meat, eggs, tofu, tempeh, fish, chicken, beef)
- vegetable (all vegetables)
- fruit (all fruits)
- dairy (milk, cheese, yogurt, butter)
- grain (rice, bread, noodles, pasta, cereal)
- condiment (sauces, spices, oil, salt, pepper)
- beverage (drinks, juice, soda)
- other (anything else)

CONFIDENCE LEVELS:
- "high" = 90%+ sure
- "medium" = 70-90% sure (user will confirm)
- "low" = below 70% (skip these items)

OUTPUT FORMAT - Return ONLY valid JSON, no explanation:
{
  "items": [
    {"name": "eggs", "category": "protein", "confidence": "high"},
    {"name": "milk", "category": "dairy", "confidence": "high"},
    {"name": "green vegetable", "category": "vegetable", "confidence": "medium"}
  ]
}

If confidence is "medium", the app will ask user to confirm/correct.
If no food detected, return: {"items": []}
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
          quantity: 1, // ALWAYS DEFAULT TO 1 - user will adjust
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
          .map((i) => "${i.name} (${i.quantity} ${i.unit}, exp: ${i.daysUntilExpiry} hari)")
          .join(", ");

      // Get expiring items (within 3 days)
      final expiringItems = inventory
          .where((i) => i.daysUntilExpiry <= 3 && i.daysUntilExpiry >= 0)
          .map((i) => i.name)
          .toList();

      final expiringList = expiringItems.isNotEmpty
          ? expiringItems.join(", ")
          : "Tidak ada yang segera expired";

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
Kamu adalah chef Indonesia yang membantu mahasiswa kos memasak dengan bahan yang ada.

BAHAN DI KULKAS:
$inventoryList

PRIORITAS (HARUS SEGERA DIPAKAI):
$expiringList

Berikan 3 resep yang:
1. Menggunakan bahan yang ada (terutama yang expiring)
2. Mudah dibuat (max 30 menit, peralatan sederhana)
3. Cocok untuk 1-2 porsi (anak kos)
4. Resep Indonesia atau fusion yang familiar

FORMAT JSON (HANYA JSON, tanpa penjelasan):
{
  "recipes": [
    {
      "name": "Nama Resep",
      "description": "Deskripsi singkat dalam 1 kalimat",
      "cookTime": 15,
      "difficulty": "easy",
      "servings": 2,
      "usesExpiringItems": ["tomat", "tahu"],
      "ingredients": [
        {"name": "tomat", "quantity": "2 buah"},
        {"name": "tahu", "quantity": "1 kotak"},
        {"name": "garam", "quantity": "secukupnya"}
      ],
      "instructions": [
        {"stepNumber": 1, "title": "Siapkan Bahan", "description": "Potong tahu dan tomat menjadi dadu kecil"},
        {"stepNumber": 2, "title": "Tumis", "description": "Panaskan minyak, tumis bawang hingga harum"},
        {"stepNumber": 3, "title": "Masak", "description": "Masukkan tahu dan tomat, aduk rata, tambahkan garam"}
      ],
      "proTip": "Tips memasak singkat (opsional)"
    }
  ]
}

RULES:
- difficulty: "easy" (< 15 min), "medium" (15-25 min), "hard" (> 25 min)
- usesExpiringItems hanya diisi dengan bahan dari daftar PRIORITAS
- ingredients harus realistis untuk mahasiswa kos
- instructions maksimal 5 langkah, jelas dan singkat
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
