import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentSource {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final int order;

  PaymentSource({
    required this.id,
    required this.name,
    this.isActive = true,
    required this.createdAt,
    this.order = 0,
  });

  factory PaymentSource.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentSource(
      id: doc.id,
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'order': order,
    };
  }
}
