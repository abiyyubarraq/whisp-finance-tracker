import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../models/expense_data.dart';
import '../config/env.dart';

class GeminiService {
  late final GenerativeModel model;

  GeminiService() {
    model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: Env.geminiApiKey,
    );
  }

  Future<ExpenseData> extractFromImage(XFile imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      const prompt = '''
Analyze this receipt image and extract expense information. Return ONLY a JSON object with this exact structure:

{
  "spentAt": "YYYY-MM-DD HH:MM:SS",
  "spentPlace": "vendor name",
  "desc": "detailed list of items purchased",
  "value": numeric_amount_only,
  "paymentSource": "payment method if visible or empty string",
  "spentType": "category",
  "confidence": "high/medium/low"
}

Rules:
- spentAt: Extract date/time from receipt. If not visible, use current date/time
- spentPlace: Vendor/merchant name
- desc: Comma-separated list of purchased items
- value: Total amount as number only (no currency symbol)
- paymentSource: Only if clearly visible (e.g., "Visa ending in 1234", "Cash"), otherwise empty string
- spentType: Categorize as one of: food, coffee, transportation, utilities, shopping, entertainment, health, education, other
- confidence: 
  * "high" if all fields clearly visible
  * "medium" if 1-2 fields unclear
  * "low" if 3+ fields unclear or receipt is blurry

Return ONLY the JSON, no additional text.
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await model.generateContent(content);
      final jsonStr = _cleanJsonResponse(response.text ?? '');

      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return ExpenseData.fromJson(data);
    } catch (e) {
      throw GeminiException('Failed to extract data from image: $e');
    }
  }

  Future<ExpenseData> extractFromAudio(XFile audioFile) async {
    try {
      final audioBytes = await audioFile.readAsBytes();

      const prompt = '''
Listen to this audio recording and extract expense information. The user is describing a purchase they made.

Return ONLY a JSON object with this exact structure:

{
  "spentAt": "YYYY-MM-DD HH:MM:SS",
  "spentPlace": "vendor/location",
  "desc": "description of purchase",
  "value": numeric_amount_only,
  "paymentSource": "payment method",
  "spentType": "category",
  "confidence": "high/medium/low"
}

Rules:
- spentAt: If user mentions date/time, use it. Otherwise use current date/time
- spentPlace: Vendor or location name
- desc: What was purchased
- value: Amount as number only
- paymentSource: Payment method mentioned (e.g., "credit card", "cash", "debit card")
- spentType: Categorize as: food, coffee, transportation, utilities, shopping, entertainment, health, education, other
- confidence:
  * "high" if all information clearly stated
  * "medium" if 1-2 details unclear
  * "low" if multiple details missing or unclear

Example input: "I spent 25 dollars at Starbucks for two lattes this morning using my credit card"
Expected output: spentAt=today's date with morning time, spentPlace="Starbucks", desc="Two lattes", value=25, paymentSource="credit card", spentType="coffee", confidence="high"

Return ONLY the JSON, no additional text.
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('audio/m4a', audioBytes)]),
      ];

      final response = await model.generateContent(content);
      final jsonStr = _cleanJsonResponse(response.text ?? '');

      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return ExpenseData.fromJson(data);
    } catch (e) {
      throw GeminiException('Failed to extract data from audio: $e');
    }
  }

  String _cleanJsonResponse(String response) {
    // Remove markdown code blocks if present
    String cleaned = response
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    // Find JSON object boundaries
    final startIndex = cleaned.indexOf('{');
    final endIndex = cleaned.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1) {
      cleaned = cleaned.substring(startIndex, endIndex + 1);
    }

    return cleaned;
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}
