import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense_item.dart';

class Expense {
  final String id;
  final DateTime createdAt;
  final DateTime spentAt;
  final String spentPlace;
  final String? desc; // Optional transaction description
  final List<ExpenseItem> items;
  final double totalValue;
  final String paymentSource;
  final String currency;
  final String inputMethod;
  final String? imageUrl;
  final String aiConfidence; // high, medium, low, manual
  final Map<String, dynamic>? rawAiResponse;
  final bool isReviewed;

  Expense({
    required this.id,
    required this.createdAt,
    required this.spentAt,
    required this.spentPlace,
    this.desc,
    required this.items,
    required this.totalValue,
    required this.paymentSource,
    required this.currency,
    required this.inputMethod,
    this.imageUrl,
    this.aiConfidence = 'manual',
    this.rawAiResponse,
    this.isReviewed = false,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse items array
    List<ExpenseItem> itemsList = [];
    if (data['items'] != null && data['items'] is List) {
      itemsList = (data['items'] as List)
          .map(
            (item) => ExpenseItem.fromFirestore(item as Map<String, dynamic>),
          )
          .toList();
    }

    return Expense(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      spentAt: (data['spentAt'] as Timestamp).toDate(),
      spentPlace: data['spentPlace'] ?? '',
      desc: data['desc'],
      items: itemsList,
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      paymentSource: data['paymentSource'] ?? '',
      currency: data['currency'] ?? 'IDR',
      inputMethod: data['inputMethod'] ?? 'manual',
      imageUrl: data['imageUrl'],
      aiConfidence: data['aiConfidence'] ?? 'manual',
      rawAiResponse: data['rawAiResponse'],
      isReviewed: data['isReviewed'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'spentAt': Timestamp.fromDate(spentAt),
      'spentPlace': spentPlace,
      if (desc != null && desc!.isNotEmpty) 'desc': desc,
      'items': items.map((item) => item.toFirestore()).toList(),
      'totalValue': totalValue,
      'paymentSource': paymentSource,
      'currency': currency,
      'inputMethod': inputMethod,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'aiConfidence': aiConfidence,
      if (rawAiResponse != null) 'rawAiResponse': rawAiResponse,
      'isReviewed': isReviewed,
    };
  }

  /// Calculate total value from a list of expense items
  static double calculateTotalValue(List<ExpenseItem> items) {
    return items.fold<double>(0, (sum, item) => sum + item.value);
  }

  /// Get all unique spent types from items
  List<String> getSpentTypes() {
    return items.map((item) => item.spentType).toSet().toList();
  }

  /// Create a copy of the expense with optional modified fields
  Expense copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? spentAt,
    String? spentPlace,
    String? desc,
    List<ExpenseItem>? items,
    double? totalValue,
    String? paymentSource,
    String? currency,
    String? inputMethod,
    String? imageUrl,
    String? aiConfidence,
    Map<String, dynamic>? rawAiResponse,
    bool? isReviewed,
  }) {
    return Expense(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      spentAt: spentAt ?? this.spentAt,
      spentPlace: spentPlace ?? this.spentPlace,
      desc: desc ?? this.desc,
      items: items ?? this.items,
      totalValue: totalValue ?? this.totalValue,
      paymentSource: paymentSource ?? this.paymentSource,
      currency: currency ?? this.currency,
      inputMethod: inputMethod ?? this.inputMethod,
      imageUrl: imageUrl ?? this.imageUrl,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      rawAiResponse: rawAiResponse ?? this.rawAiResponse,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }
}
