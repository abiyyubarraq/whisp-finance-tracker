import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
        );
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
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
        );
  }

  /// Upload receipt image to Firebase Storage (cross-platform compatible)
  /// Returns a map with 'url' (download URL) and 'path' (storage path)
  /// Works on both mobile and web platforms using XFile
  Future<Map<String, String>> uploadReceiptImage(
    String userId,
    XFile imageFile,
  ) async {
    try {
      // Verify file exists and has content
      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Image file is empty');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'receipts/$timestamp.jpg';
      final storagePath = 'users/$userId/$fileName';

      final ref = _storage.ref().child(storagePath);

      // Use putData instead of putFile for web compatibility
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': timestamp.toString(),
          },
        ),
      );

      await uploadTask;

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();

      return {'url': downloadUrl, 'path': storagePath};
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase Storage error: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Details: ${e.stackTrace}');

      // Provide more specific error messages
      switch (e.code) {
        case 'unauthorized':
        case 'permission-denied':
          throw Exception(
            'Permission denied. Please check Firebase Storage rules allow '
            'authenticated users to upload to users/{userId}/receipts/',
          );
        case 'retry-limit-exceeded':
          throw Exception(
            'Upload timeout. This may indicate:\n'
            '1. Storage rules are blocking the upload\n'
            '2. Network connectivity issues\n'
            '3. CORS configuration issues (if on web)\n'
            'Original error: ${e.message}',
          );
        case 'unauthenticated':
          throw Exception('User is not authenticated. Please sign in again.');
        default:
          rethrow;
      }
    } catch (e) {
      debugPrint('❌ Unexpected error uploading image: $e');
      rethrow;
    }
  }

  /// Delete receipt image from Firebase Storage
  /// Can accept either a download URL or a storage path
  Future<void> deleteReceiptImage(String path) async {
    try {
      Reference ref;

      // It's a storage path (e.g., users/{userId}/receipts/{timestamp}.jpg)
      ref = _storage.ref().child(path);

      await ref.delete();
    } on FirebaseException catch (e) {
      // If file doesn't exist, that's okay
      if (e.code == 'object-not-found') {
        debugPrint('⚠️ Image already deleted or not found: $path');
        return;
      }
      debugPrint('❌ Storage error deleting image: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error deleting image: $e');
      rethrow;
    }
  }

  /// Update expense image URL in Firestore
  Future<void> updateExpenseImageUrl(
    String userId,
    String expenseId,
    String? imageUrl,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expenseId)
          .update({'imageUrl': imageUrl});
      debugPrint('✅ Expense image URL updated');
    } on FirebaseException catch (e) {
      debugPrint(
        '❌ Firebase error updating image URL: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error updating image URL: $e');
      rethrow;
    }
  }
}
