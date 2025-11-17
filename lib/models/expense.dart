import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final DateTime createdAt;
  final DateTime spentAt;
  final String spentPlace;
  final String desc;
  final double value;
  final String paymentSource;
  final String spentType;
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
    required this.desc,
    required this.value,
    required this.paymentSource,
    required this.spentType,
    required this.currency,
    required this.inputMethod,
    this.imageUrl,
    this.aiConfidence = 'manual',
    this.rawAiResponse,
    this.isReviewed = false,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      spentAt: (data['spentAt'] as Timestamp).toDate(),
      spentPlace: data['spentPlace'] ?? '',
      desc: data['desc'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      paymentSource: data['paymentSource'] ?? '',
      spentType: data['spentType'] ?? '',
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
      'desc': desc,
      'value': value,
      'paymentSource': paymentSource,
      'spentType': spentType,
      'currency': currency,
      'inputMethod': inputMethod,
      'imageUrl': imageUrl,
      'aiConfidence': aiConfidence,
      'rawAiResponse': rawAiResponse,
      'isReviewed': isReviewed,
    };
  }
}
