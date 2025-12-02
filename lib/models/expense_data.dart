import 'expense_item.dart';

class ExpenseData {
  final DateTime spentAt;
  final String spentPlace;
  final String? desc; // Optional transaction description
  final List<ExpenseItem> items;
  final double totalValue;
  final String paymentSource;
  final String confidence;

  ExpenseData({
    required this.spentAt,
    required this.spentPlace,
    this.desc,
    required this.items,
    required this.totalValue,
    required this.paymentSource,
    required this.confidence,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    // Parse items array
    List<ExpenseItem> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((item) => ExpenseItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ExpenseData(
      spentAt: _parseDateTime(json['spentAt']),
      spentPlace: json['spentPlace'] ?? '',
      desc: json['desc'],
      items: itemsList,
      totalValue: _parseDouble(json['totalValue']),
      paymentSource: json['paymentSource'] ?? '',
      confidence: json['confidence'] ?? 'low',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    DateTime dateTime;

    if (value is String) {
      try {
        dateTime = DateTime.parse(value);
      } catch (e) {
        dateTime = DateTime.now();
      }
    } else if (value is DateTime) {
      dateTime = value;
    } else {
      dateTime = DateTime.now();
    }

    // Normalize time to 12:00 PM
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 12, 0);
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }
    return 0.0;
  }
}
