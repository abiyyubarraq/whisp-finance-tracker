import 'package:flutter_test/flutter_test.dart';
import 'package:whisper_finance_tracker/models/expense_item.dart';

void main() {
  group('ExpenseItem.fromJson', () {
    test('reads number values', () {
      final item = ExpenseItem.fromJson({
        'itemName': 'Latte',
        'spentType': 'Coffee',
        'quantity': 2,
        'cost': 25000,
        'value': 50000.5,
      });

      expect(item.itemName, 'Latte');
      expect(item.spentType, 'Coffee');
      expect(item.quantity, 2);
      expect(item.cost, 25000.0);
      expect(item.value, 50000.5);
      expect(item.tax, isNull);
      expect(item.descItem, isNull);
    });

    test('parses string amounts and drops non-numeric characters', () {
      final item = ExpenseItem.fromJson({
        'itemName': 'Nasi Goreng',
        'spentType': 'Food',
        'quantity': 1,
        'cost': '30000',
        'value': 'Rp 33000',
        'tax': '3000',
      });

      expect(item.cost, 30000.0);
      expect(item.value, 33000.0);
      expect(item.tax, 3000.0);
    });

    test('falls back to 0 for an amount string with no digits', () {
      final item = ExpenseItem.fromJson({'cost': 'free', 'value': ''});

      expect(item.cost, 0.0);
      expect(item.value, 0.0);
    });

    test('uses defaults when fields are missing', () {
      final item = ExpenseItem.fromJson(<String, dynamic>{});

      expect(item.itemName, '');
      expect(item.spentType, '');
      expect(item.quantity, 1);
      expect(item.cost, 0.0);
      expect(item.value, 0.0);
      expect(item.tax, isNull);
      expect(item.descItem, isNull);
    });

    test('reads optional tax and description', () {
      final item = ExpenseItem.fromJson({
        'itemName': 'Parking',
        'spentType': 'Transportation',
        'quantity': 1,
        'cost': 5000,
        'value': 5500,
        'tax': 500,
        'descItem': 'Mall basement',
      });

      expect(item.tax, 500.0);
      expect(item.descItem, 'Mall basement');
    });
  });

  group('ExpenseItem.toFirestore', () {
    ExpenseItem buildItem({double? tax, String? descItem}) => ExpenseItem(
      itemName: 'Tea',
      spentType: 'Coffee',
      quantity: 3,
      cost: 8000,
      value: 24000,
      tax: tax,
      descItem: descItem,
    );

    test('writes the required fields', () {
      expect(buildItem().toFirestore(), {
        'itemName': 'Tea',
        'spentType': 'Coffee',
        'quantity': 3,
        'cost': 8000.0,
        'value': 24000.0,
      });
    });

    test('omits tax when it is null', () {
      expect(buildItem().toFirestore().containsKey('tax'), isFalse);
    });

    test('omits descItem when it is null or empty', () {
      expect(buildItem().toFirestore().containsKey('descItem'), isFalse);
      expect(
        buildItem(descItem: '').toFirestore().containsKey('descItem'),
        isFalse,
      );
    });

    test('includes tax and descItem when set', () {
      final map = buildItem(tax: 2400, descItem: 'Less sugar').toFirestore();

      expect(map['tax'], 2400.0);
      expect(map['descItem'], 'Less sugar');
    });

    test('survives a round trip through fromJson', () {
      final original = buildItem(tax: 2400, descItem: 'Less sugar');

      expect(ExpenseItem.fromJson(original.toJson()), original);
    });
  });

  test('calculateValue multiplies cost by quantity and adds tax', () {
    expect(ExpenseItem.calculateValue(cost: 8000, quantity: 3), 24000.0);
    expect(
      ExpenseItem.calculateValue(cost: 8000, quantity: 3, tax: 2400),
      26400.0,
    );
  });
}
