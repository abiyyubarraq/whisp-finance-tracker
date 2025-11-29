import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update an existing expense
  Future<void> updateExpense(String userId, Expense expense) async {
    if (expense.id.isEmpty) {
      throw ArgumentError('Expense ID cannot be empty for update');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toFirestore());
    } on FirebaseException catch (e) {
      debugPrint('Firebase error updating expense: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error updating expense: $e');
      rethrow;
    }
  }

  /// Delete an expense by ID
  Future<void> deleteExpense(String userId, String expenseId) async {
    if (expenseId.isEmpty) {
      throw ArgumentError('Expense ID cannot be empty for delete');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
    } on FirebaseException catch (e) {
      debugPrint('Firebase error deleting expense: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error deleting expense: $e');
      rethrow;
    }
  }

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
