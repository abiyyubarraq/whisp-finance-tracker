// lib/utils/currency_formatter.dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Format currency with full precision
  static String format(double amount, String currency) {
    return NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    ).format(amount);
  }

  /// Format currency in compact form (K, M, B)
  static String formatCompact(double amount, String currency) {
    if (amount >= 1000000000) {
      return '$currency ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '$currency ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$currency ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$currency ${amount.toStringAsFixed(0)}';
  }

  /// Format without currency symbol
  static String formatNumber(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Format as integer (no decimals)
  static String formatInteger(double amount, String currency) {
    return NumberFormat.currency(
      symbol: currency,
      decimalDigits: 0,
    ).format(amount);
  }

  /// Get currency symbol
  static String getSymbol(String currency) {
    switch (currency) {
      case 'IDR':
        return 'Rp';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return currency;
    }
  }
}
