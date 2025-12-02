import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense_item.dart';
import 'receipt_image.dart';

class Expense {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt; // Timestamp of last update
  final DateTime spentAt;
  final String spentPlace;
  final String? desc; // Optional transaction description
  final List<ExpenseItem> items;
  final double totalValue;
  final String paymentSource;
  final String currency;
  final String inputMethod;
  final List<ReceiptImage>
  receiptImages; // Multiple receipt images with path and URL
  final String aiConfidence; // high, medium, low, manual
  final Map<String, dynamic>? rawAiResponse;
  final bool isReviewed;

  Expense({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.spentAt,
    required this.spentPlace,
    this.desc,
    required this.items,
    required this.totalValue,
    required this.paymentSource,
    required this.currency,
    required this.inputMethod,
    this.receiptImages = const [],
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

    // Parse receiptImages - handle new structure and backward compatibility
    List<ReceiptImage> receiptImagesList = [];
    if (data['receiptImages'] != null && data['receiptImages'] is List) {
      // New structure: array of objects with path and url
      receiptImagesList = (data['receiptImages'] as List)
          .map((item) => ReceiptImage.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return Expense(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      spentAt: (data['spentAt'] as Timestamp).toDate(),
      spentPlace: data['spentPlace'] ?? '',
      desc: data['desc'],
      items: itemsList,
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      paymentSource: data['paymentSource'] ?? '',
      currency: data['currency'] ?? 'IDR',
      inputMethod: data['inputMethod'] ?? 'manual',
      receiptImages: receiptImagesList,
      aiConfidence: data['aiConfidence'] ?? 'manual',
      rawAiResponse: data['rawAiResponse'],
      isReviewed: data['isReviewed'] ?? false,
    );
  }

  /// Convert to Firestore map for adding a new expense
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
      if (receiptImages.isNotEmpty)
        'receiptImages': receiptImages.map((img) => img.toMap()).toList(),
      'aiConfidence': aiConfidence,
      if (rawAiResponse != null) 'rawAiResponse': rawAiResponse,
      'isReviewed': isReviewed,
    };
  }

  /// Convert to Firestore map for updating an existing expense
  /// Does NOT include createdAt, but includes updatedAt and all editable fields
  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'spentAt': Timestamp.fromDate(spentAt),
      'spentPlace': spentPlace,
      if (desc != null && desc!.isNotEmpty) 'desc': desc,
      'items': items.map((item) => item.toFirestore()).toList(),
      'totalValue': totalValue,
      'paymentSource': paymentSource,
      'currency': currency,
      'inputMethod': inputMethod,
      if (receiptImages.isNotEmpty)
        'receiptImages': receiptImages.map((img) => img.toMap()).toList(),
      'aiConfidence': aiConfidence,
      if (rawAiResponse != null) 'rawAiResponse': rawAiResponse,
      'isReviewed': isReviewed,
    };
  }

  /// Calculate total value from a list of expense items
  static double calculateTotalValue(List<ExpenseItem> items) {
    return items.fold<double>(0, (total, item) => total + item.value);
  }

  /// Get all unique spent types from items
  List<String> getSpentTypes() {
    return items.map((item) => item.spentType).toSet().toList();
  }

  /// Create a copy of the expense with optional modified fields
  Expense copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? spentAt,
    String? spentPlace,
    String? desc,
    List<ExpenseItem>? items,
    double? totalValue,
    String? paymentSource,
    String? currency,
    String? inputMethod,
    List<ReceiptImage>? receiptImages,
    String? aiConfidence,
    Map<String, dynamic>? rawAiResponse,
    bool? isReviewed,
  }) {
    return Expense(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      spentAt: spentAt ?? this.spentAt,
      spentPlace: spentPlace ?? this.spentPlace,
      desc: desc ?? this.desc,
      items: items ?? this.items,
      totalValue: totalValue ?? this.totalValue,
      paymentSource: paymentSource ?? this.paymentSource,
      currency: currency ?? this.currency,
      inputMethod: inputMethod ?? this.inputMethod,
      receiptImages: receiptImages ?? this.receiptImages,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      rawAiResponse: rawAiResponse ?? this.rawAiResponse,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }
}
