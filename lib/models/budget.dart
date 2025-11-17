import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String period; // weekly, monthly
  final List<String> spentTypes;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double notificationThreshold;

  Budget({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.period,
    required this.spentTypes,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.notificationThreshold = 80.0,
  });

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'IDR',
      period: data['period'] ?? 'monthly',
      spentTypes: List<String>.from(data['spentTypes'] ?? []),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      notificationThreshold: (data['notificationThreshold'] ?? 80).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'period': period,
      'spentTypes': spentTypes,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'notificationThreshold': notificationThreshold,
    };
  }
}
