# Module 08: Feature Walkthrough - AI Integration

**Duration:** 3-4 hours | **Difficulty:** Advanced | **Prerequisites:** Modules 01-07

## 🎯 Learning Objectives

- Integrate Google Gemini API in Flutter
- Implement receipt scanning with Vision AI
- Parse structured data from AI responses
- Handle AI errors gracefully
- Implement voice transcription

---

## Gemini Service Setup

See [lib/services/gemini_service.dart](../lib/services/gemini_service.dart):

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _visionModel;
  late final GenerativeModel _textModel;

  GeminiService() {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');

    _visionModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    _textModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  // Extract expense data from receipt image
  Future<ExpenseData> extractExpenseFromImage(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Create prompt
      final prompt = TextPart(_buildReceiptPrompt());
      final imagePart = DataPart('image/jpeg', imageBytes);

      // Generate content
      final response = await _visionModel.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      // Parse JSON response
      final text = response.text ?? '{}';
      final jsonData = _extractJson(text);
      return ExpenseData.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error extracting expense from image: $e');
      rethrow;
    }
  }

  // Build receipt scanning prompt
  String _buildReceiptPrompt() {
    return '''
Analyze this receipt image and extract the following information in JSON format:

{
  "storeName": "name of the store/merchant",
  "date": "date in ISO 8601 format (YYYY-MM-DD)",
  "time": "time in HH:MM format (24-hour)",
  "items": [
    {
      "name": "item name",
      "quantity": 1,
      "pricePerItem": 0.0,
      "totalPrice": 0.0,
      "category": "guess the category (food, transport, entertainment, etc.)"
    }
  ],
  "totalAmount": 0.0,
  "currency": "currency code (e.g., IDR, USD)",
  "paymentMethod": "payment method if visible (cash, card, etc.)"
}

Important:
- Extract ALL items from the receipt
- Calculate totalPrice = quantity × pricePerItem for each item
- Ensure totalAmount matches the receipt total
- Use best guess for categories
- Return ONLY valid JSON, no additional text
''';
  }

  // Extract JSON from AI response (handles markdown code blocks)
  Map<String, dynamic> _extractJson(String text) {
    // Remove markdown code block markers
    String cleanText = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      return jsonDecode(cleanText) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to parse JSON: $text');
      throw 'Failed to parse AI response';
    }
  }
}
```

## Expense Data Model

See [lib/models/expense_data.dart](../lib/models/expense_data.dart):

```dart
class ExpenseData {
  final String storeName;
  final DateTime? date;
  final List<ExpenseItemData> items;
  final double totalAmount;
  final String currency;
  final String? paymentMethod;

  const ExpenseData({
    required this.storeName,
    this.date,
    required this.items,
    required this.totalAmount,
    this.currency = 'IDR',
    this.paymentMethod,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    try {
      return ExpenseData(
        storeName: json['storeName'] ?? 'Unknown Store',
        date: _parseDate(json['date'], json['time']),
        items: (json['items'] as List? ?? [])
            .map((item) => ExpenseItemData.fromJson(item))
            .toList(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        currency: json['currency'] ?? 'IDR',
        paymentMethod: json['paymentMethod'],
      );
    } catch (e) {
      debugPrint('Error parsing ExpenseData: $e');
      rethrow;
    }
  }

  static DateTime? _parseDate(dynamic dateStr, dynamic timeStr) {
    try {
      if (dateStr == null) return null;

      DateTime date = DateTime.parse(dateStr);

      // Add time if available
      if (timeStr != null) {
        final timeParts = timeStr.toString().split(':');
        if (timeParts.length >= 2) {
          date = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      }

      return date;
    } catch (e) {
      return null;
    }
  }

  // Convert to Expense model for saving
  Expense toExpense({
    required String paymentSource,
    File? receiptImage,
    String? imageUrl,
  }) {
    return Expense(
      createdAt: DateTime.now(),
      spentAt: date ?? DateTime.now(),
      spentPlace: storeName,
      items: items.map((item) => item.toExpenseItem()).toList(),
      totalValue: totalAmount,
      paymentSource: paymentSource,
      currency: currency,
      inputMethod: 'image',
      receiptImages: imageUrl != null ? [imageUrl] : [],
    );
  }
}

class ExpenseItemData {
  final String name;
  final int quantity;
  final double pricePerItem;
  final double totalPrice;
  final String category;

  const ExpenseItemData({
    required this.name,
    this.quantity = 1,
    required this.pricePerItem,
    required this.totalPrice,
    this.category = 'Other',
  });

  factory ExpenseItemData.fromJson(Map<String, dynamic> json) {
    return ExpenseItemData(
      name: json['name'] ?? 'Unknown Item',
      quantity: json['quantity'] ?? 1,
      pricePerItem: (json['pricePerItem'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      category: json['category'] ?? 'Other',
    );
  }

  ExpenseItem toExpenseItem() {
    return ExpenseItem(
      name: name,
      spentType: category,
      quantity: quantity,
      pricePerItem: pricePerItem,
      totalPrice: totalPrice,
    );
  }
}
```

## Voice Transcription

See [lib/screens/input_tabs/voice_input_tab.dart](../lib/screens/input_tabs/voice_input_tab.dart):

```dart
class VoiceInputTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<VoiceInputTab> createState() => _VoiceInputTabState();
}

class _VoiceInputTabState extends ConsumerState<VoiceInputTab> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  bool _isProcessing = false;
  ExpenseData? _extractedData;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      // Process audio
      if (path != null) {
        await _processAudio(File(path));
      }
    } else {
      // Start recording
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        NotificationHelper.showError(
          context,
          'Microphone permission required',
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(),
        path: filePath,
      );

      setState(() => _isRecording = true);
    }
  }

  Future<void> _processAudio(File audioFile) async {
    setState(() => _isProcessing = true);

    try {
      // Use Gemini to transcribe and extract expense data
      final geminiService = ref.read(geminiServiceProvider);
      final extractedData = await geminiService.extractExpenseFromAudio(
        audioFile,
      );

      setState(() {
        _extractedData = extractedData;
      });
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(
          context,
          'Failed to process audio: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Recording animation
        if (_isRecording)
          Column(
            children: [
              Icon(
                Icons.mic,
                size: 100,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Recording...',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),

        // Processing indicator
        if (_isProcessing)
          Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing audio...'),
            ],
          ),

        // Extracted data form (editable)
        if (_extractedData != null && !_isProcessing)
          _buildEditableForm(_extractedData!),

        // Record button
        SizedBox(height: 32),
        FloatingActionButton.large(
          onPressed: _isProcessing ? null : _toggleRecording,
          backgroundColor: _isRecording ? Colors.red : Colors.blue,
          child: Icon(_isRecording ? Icons.stop : Icons.mic),
        ),

        // Instructions
        if (!_isRecording && !_isProcessing && _extractedData == null)
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tap the microphone and describe your expense.\nExample: "I spent 50000 rupiah on lunch at Warung Makan"',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
```

## Error Handling Best Practices

```dart
// 1. Wrap AI calls in try-catch
try {
  final result = await geminiService.extractExpenseFromImage(image);
} on GenerativeAIException catch (e) {
  // Handle API-specific errors
  debugPrint('Gemini API error: ${e.message}');
  throw 'AI service temporarily unavailable';
} catch (e) {
  // Handle general errors
  debugPrint('Unexpected error: $e');
  throw 'Failed to process image';
}

// 2. Validate AI responses
Map<String, dynamic> _validateResponse(Map<String, dynamic> json) {
  // Ensure required fields exist
  if (!json.containsKey('items') || json['items'].isEmpty) {
    throw 'No items found in receipt';
  }

  // Validate total amount
  if ((json['totalAmount'] ?? 0) <= 0) {
    throw 'Invalid total amount';
  }

  return json;
}

// 3. Provide fallback values
factory ExpenseData.fromJson(Map<String, dynamic> json) {
  return ExpenseData(
    storeName: json['storeName'] ?? 'Unknown Store', // Fallback
    date: _parseDate(json['date'], json['time']) ?? DateTime.now(), // Fallback
    items: _parseItems(json['items']) ?? [], // Fallback to empty list
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    currency: json['currency'] ?? 'IDR', // Fallback
  );
}
```

## Prompt Engineering Tips

1. **Be specific** - Clearly define expected output format
2. **Use examples** - Show desired JSON structure
3. **Set constraints** - "Return ONLY valid JSON, no additional text"
4. **Handle edge cases** - Specify behavior for missing data
5. **Request validation** - Ask AI to verify calculations

## React Comparison

**React with OpenAI:**
```typescript
const extractExpenseFromImage = async (imageFile: File) => {
  const formData = new FormData();
  formData.append('image', imageFile);

  const response = await fetch('/api/extract-expense', {
    method: 'POST',
    body: formData,
  });

  return await response.json();
};

// Server-side API route needed
```

**Flutter with Gemini is simpler:**
- Direct SDK integration
- No backend API needed
- Client-side processing

## Practice Exercises

### Exercise 1: Improve Receipt Prompt
Enhance the prompt to better handle multi-page receipts or specific store formats.

### Exercise 2: Add Confidence Scores
Modify the AI response to include confidence scores for each extracted field.

### Exercise 3: Implement Retry Logic
Add automatic retry with exponential backoff for failed AI requests.

---

**Next Module:** [09: UI, Material 3 & Theming →](09-ui-material3-theming.md)
