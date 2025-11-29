import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream all expenses for a user, ordered by spentAt descending
  Stream<List<Expense>> streamExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('spentAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  /// Stream expenses filtered by date range
  Stream<List<Expense>> streamExpensesByDateRange(
    String userId,
    DateTimeRange dateRange,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .where(
          'spentAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
        )
        .where(
          'spentAt',
          isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
        )
        .orderBy('spentAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }
}
