import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentSource {
  final String id;
  final String name;
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;

  PaymentSource({
    required this.id,
    required this.name,
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
  });

  factory PaymentSource.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentSource(
      id: doc.id,
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? true,
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isActive': isActive,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
