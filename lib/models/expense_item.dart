/// Represents an individual item within an expense transaction
class ExpenseItem {
  final String itemName;
  final String spentType;
  final int quantity;
  final double cost; // Cost per unit
  final double value; // Total cost (quantity * cost + tax)
  final double? tax; // Optional tax amount
  final String? descItem; // Optional description for this specific item

  ExpenseItem({
    required this.itemName,
    required this.spentType,
    required this.quantity,
    required this.cost,
    required this.value,
    this.tax,
    this.descItem,
  });

  /// Factory constructor from Firestore document
  factory ExpenseItem.fromFirestore(Map<String, dynamic> data) {
    return ExpenseItem(
      itemName: data['itemName'] ?? '',
      spentType: data['spentType'] ?? '',
      quantity: data['quantity'] ?? 1,
      cost: (data['cost'] ?? 0).toDouble(),
      value: (data['value'] ?? 0).toDouble(),
      tax: data['tax'] != null ? (data['tax'] as num).toDouble() : null,
      descItem: data['descItem'],
    );
  }

  /// Factory constructor from JSON
  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      itemName: json['itemName'] ?? '',
      spentType: json['spentType'] ?? '',
      quantity: json['quantity'] ?? 1,
      cost: _parseDouble(json['cost']),
      value: _parseDouble(json['value']),
      tax: json['tax'] != null ? _parseDouble(json['tax']) : null,
      descItem: json['descItem'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'itemName': itemName,
      'spentType': spentType,
      'quantity': quantity,
      'cost': cost,
      'value': value,
      if (tax != null) 'tax': tax,
      if (descItem != null && descItem!.isNotEmpty) 'descItem': descItem,
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => toFirestore();

  /// Create a copy with updated fields
  ExpenseItem copyWith({
    String? itemName,
    String? spentType,
    int? quantity,
    double? cost,
    double? value,
    double? tax,
    String? descItem,
  }) {
    return ExpenseItem(
      itemName: itemName ?? this.itemName,
      spentType: spentType ?? this.spentType,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      value: value ?? this.value,
      tax: tax ?? this.tax,
      descItem: descItem ?? this.descItem,
    );
  }

  /// Calculate value from cost, quantity, and tax
  static double calculateValue({
    required double cost,
    required int quantity,
    double? tax,
  }) {
    final subtotal = cost * quantity;
    return subtotal + (tax ?? 0);
  }

  /// Helper method to parse double values
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }
    return 0.0;
  }

  @override
  String toString() {
    return 'ExpenseItem(itemName: $itemName, spentType: $spentType, '
        'quantity: $quantity, cost: $cost, value: $value, '
        'tax: $tax, descItem: $descItem)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpenseItem &&
        other.itemName == itemName &&
        other.spentType == spentType &&
        other.quantity == quantity &&
        other.cost == cost &&
        other.value == value &&
        other.tax == tax &&
        other.descItem == descItem;
  }

  @override
  int get hashCode {
    return itemName.hashCode ^
        spentType.hashCode ^
        quantity.hashCode ^
        cost.hashCode ^
        value.hashCode ^
        tax.hashCode ^
        descItem.hashCode;
  }
}
