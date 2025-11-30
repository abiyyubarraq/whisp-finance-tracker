import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spent_type.dart';
import '../models/payment_source.dart';
import '../models/place_name.dart';
import '../models/item_name.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'auth_provider.dart';

// ============================================================================
// Service Providers
// ============================================================================

/// Expense service provider (singleton)
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

// ============================================================================
// Spent Types Providers
// ============================================================================

/// Parameterized provider for spent types
/// - `includeInactive: false` → only active spent types (for dropdowns, forms)
/// - `includeInactive: true` → all spent types (for management screens)
final spentTypesProvider = StreamProvider.family<List<SpentType>, bool>((
  ref,
  includeInactive,
) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  Query query = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('spentTypes');

  if (!includeInactive) {
    query = query.where('isActive', isEqualTo: true);
  }

  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => SpentType.fromFirestore(doc)).toList();
  });
});

// ============================================================================
// Payment Sources Providers
// ============================================================================

/// Parameterized provider for payment sources
/// - `includeInactive: false` → only active payment sources (for dropdowns, forms)
/// - `includeInactive: true` → all payment sources (for management screens)
final paymentSourcesProvider = StreamProvider.family<List<PaymentSource>, bool>(
  (ref, includeInactive) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return Stream.value([]);
    }

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('paymentSources');

    if (!includeInactive) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentSource.fromFirestore(doc))
          .toList();
    });
  },
);

// ============================================================================
// Place Names Providers
// ============================================================================

/// Parameterized provider for place names
/// - `includeInactive: false` → only active place names (for forms)
/// - `includeInactive: true` → all place names (for management screens)
final placeNamesProvider = StreamProvider.family<List<PlaceName>, bool>((
  ref,
  includeInactive,
) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  Query query = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('placeNames');

  if (!includeInactive) {
    query = query.where('isActive', isEqualTo: true);
  }

  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => PlaceName.fromFirestore(doc)).toList();
  });
});

// ============================================================================
// Item Names Providers
// ============================================================================

/// Parameterized provider for item names
/// - `includeInactive: false` → only active item names (for forms)
/// - `includeInactive: true` → all item names (for management screens)
final itemNamesProvider = StreamProvider.family<List<ItemName>, bool>((
  ref,
  includeInactive,
) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  Query query = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('itemNames');

  if (!includeInactive) {
    query = query.where('isActive', isEqualTo: true);
  }

  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => ItemName.fromFirestore(doc)).toList();
  });
});

// ============================================================================
// Expense Providers
// ============================================================================

/// Parameterized provider for expenses by date range
final expensesByDateRangeProvider =
    StreamProvider.family<List<Expense>, DateTimeRange>((ref, dateRange) {
      final user = ref.watch(authStateProvider).value;

      if (user == null) {
        return Stream.value([]);
      }

      return ref
          .watch(expenseServiceProvider)
          .streamExpensesByDateRange(user.uid, dateRange);
    });
