// lib/utils/filter_sort.dart (Updated)
import 'package:flutter/material.dart';

class ExpenseFilter {
  DateTimeRange? dateRange;
  String? currencyFilter;
  Set<String> selectedSpentTypes = {};
  Set<String> selectedPaymentSources = {};
  bool showOnlyFlagged = false;
  double? minAmount;
  double? maxAmount;

  ExpenseFilter({
    this.dateRange,
    this.currencyFilter,
    Set<String>? selectedSpentTypes,
    Set<String>? selectedPaymentSources,
    this.showOnlyFlagged = false,
    this.minAmount,
    this.maxAmount,
  }) {
    this.selectedSpentTypes = selectedSpentTypes ?? {};
    this.selectedPaymentSources = selectedPaymentSources ?? {};
  }

  bool hasActiveFilters() {
    return dateRange != null ||
        currencyFilter != null ||
        selectedSpentTypes.isNotEmpty ||
        selectedPaymentSources.isNotEmpty ||
        showOnlyFlagged ||
        minAmount != null ||
        maxAmount != null;
  }
}

enum SortField { spentAt, value, spentPlace, spentType, paymentSource }

enum SortDirection { ascending, descending }

class ExpenseSort {
  final SortField field;
  final SortDirection direction;

  ExpenseSort(this.field, this.direction);
}
