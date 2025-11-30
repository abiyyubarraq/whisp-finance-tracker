import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceName {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  PlaceName({
    required this.id,
    required this.name,
    this.isActive = true,
    required this.createdAt,
  });

  factory PlaceName.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlaceName(
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
