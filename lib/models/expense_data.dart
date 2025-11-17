class ExpenseData {
  final DateTime spentAt;
  final String spentPlace;
  final String desc;
  final double value;
  final String paymentSource;
  final String spentType;
  final String confidence;

  ExpenseData({
    required this.spentAt,
    required this.spentPlace,
    required this.desc,
    required this.value,
    required this.paymentSource,
    required this.spentType,
    required this.confidence,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      spentAt: _parseDateTime(json['spentAt']),
      spentPlace: json['spentPlace'] ?? '',
      desc: json['desc'] ?? '',
      value: _parseDouble(json['value']),
      paymentSource: json['paymentSource'] ?? '',
      spentType: json['spentType'] ?? 'other',
      confidence: json['confidence'] ?? 'low',
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }
    return 0.0;
  }
}
