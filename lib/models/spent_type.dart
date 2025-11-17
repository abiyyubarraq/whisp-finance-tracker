import 'package:cloud_firestore/cloud_firestore.dart';

class SpentType {
  final String id;
  final String name;
  final String color;
  final String icon;
  final bool isActive;
  final DateTime createdAt;
  final int order;

  SpentType({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.isActive = true,
    required this.createdAt,
    this.order = 0,
  });

  factory SpentType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SpentType(
      id: doc.id,
      name: data['name'] ?? '',
      color: data['color'] ?? '#6B7280',
      icon: data['icon'] ?? 'more_horiz',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'order': order,
    };
  }
}
