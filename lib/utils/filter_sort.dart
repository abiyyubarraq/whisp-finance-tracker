import 'package:flutter/material.dart';

class ExpenseFilter {
  DateTimeRange? dateRange;
  List<String> selectedSpentTypes;
  List<String> selectedPaymentSources;
  String? currencyFilter; // IDR, USD, or null (all)
  bool showOnlyFlagged; // Show only low-confidence entries

  ExpenseFilter({
    this.dateRange,
    this.selectedSpentTypes = const [],
    this.selectedPaymentSources = const [],
    this.currencyFilter,
    this.showOnlyFlagged = false,
  });
}

enum SortField { spentAt, value, spentPlace, spentType, paymentSource }

enum SortDirection { ascending, descending }

class ExpenseSort {
  final SortField field;
  final SortDirection direction;

  ExpenseSort(this.field, this.direction);
}
