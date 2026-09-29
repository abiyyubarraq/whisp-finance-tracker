import 'package:flutter_test/flutter_test.dart';
import 'package:whisper_finance_tracker/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.formatCompact', () {
    test('keeps small amounts as whole numbers', () {
      expect(CurrencyFormatter.formatCompact(999, 'IDR'), 'IDR 999');
      expect(CurrencyFormatter.formatCompact(0, 'IDR'), 'IDR 0');
    });

    test('uses K, M and B suffixes at each threshold', () {
      expect(CurrencyFormatter.formatCompact(1000, 'IDR'), 'IDR 1.0K');
      expect(CurrencyFormatter.formatCompact(15500, 'IDR'), 'IDR 15.5K');
      expect(CurrencyFormatter.formatCompact(2500000, 'IDR'), 'IDR 2.5M');
      expect(CurrencyFormatter.formatCompact(3000000000, 'USD'), 'USD 3.0B');
    });
  });

  test('formatNumber adds thousands separators and two decimals', () {
    expect(CurrencyFormatter.formatNumber(1234567.5), '1,234,567.50');
  });

  group('CurrencyFormatter.getSymbol', () {
    test('maps known currency codes to their symbols', () {
      expect(CurrencyFormatter.getSymbol('IDR'), 'Rp');
      expect(CurrencyFormatter.getSymbol('USD'), r'$');
      expect(CurrencyFormatter.getSymbol('EUR'), '€');
      expect(CurrencyFormatter.getSymbol('GBP'), '£');
      expect(CurrencyFormatter.getSymbol('JPY'), '¥');
    });

    test('returns the code itself for unknown currencies', () {
      expect(CurrencyFormatter.getSymbol('SGD'), 'SGD');
    });
  });
}
