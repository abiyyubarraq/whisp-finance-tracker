import 'package:cloud_firestore/cloud_firestore.dart';

class ItemName {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  ItemName({
    required this.id,
    required this.name,
    this.isActive = true,
    required this.createdAt,
  });

  factory ItemName.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemName(
      id: doc.id,
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
