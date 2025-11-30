// lib/services/payment_source_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../models/payment_source.dart';
import '../widgets/glass_container.dart';
import '../utils/notification_helper.dart';

class PaymentSourceService {
  static Future<void> add(
    BuildContext context,
    String userId,
    String name,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('paymentSources')
          .add({
            'name': name,
            'isActive': true,
            'isDefault': false,
            'createdAt': DateTime.now(),
          });

      if (context.mounted) {
        NotificationHelper.showSuccess(
          context,
          'Payment source added successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        NotificationHelper.showError(
          context,
          'Error: ${e.toString()}',
        );
      }
    }
  }

  /// Adds a new payment source without notification (for auto-add during expense save)
  static Future<void> addSilent(String userId, String name) async {
    try {
      // Check if already exists (case-insensitive)
      final exists = await _existsCaseInsensitive(userId, name);
      if (exists) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('paymentSources')
          .add({
            'name': name,
            'isActive': true,
            'isDefault': false,
            'createdAt': DateTime.now(),
          });
    } catch (e) {
      debugPrint('Error adding payment source silently: $e');
    }
  }

  /// Check if payment source exists (case-insensitive)
  static Future<bool> _existsCaseInsensitive(String userId, String name) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('paymentSources')
        .get();

    return snapshot.docs.any(
      (doc) => (doc.data()['name'] as String).toLowerCase() == name.toLowerCase(),
    );
  }

  static Future<void> update(
    BuildContext context,
    String userId,
    PaymentSource source,
    String name,
    bool isActive,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('paymentSources')
          .doc(source.id)
          .update({'name': name, 'isActive': isActive});

      if (context.mounted) {
        NotificationHelper.showSuccess(
          context,
          'Payment source updated successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        NotificationHelper.showError(
          context,
          'Error: ${e.toString()}',
        );
      }
    }
  }

  /// Sets a payment source as default, unsetting all others
  static Future<void> setDefault(
    BuildContext context,
    String userId,
    PaymentSource source,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Get all payment sources
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('paymentSources')
          .get();

      // Unset all defaults
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set this one as default
      batch.update(
        firestore
            .collection('users')
            .doc(userId)
            .collection('paymentSources')
            .doc(source.id),
        {'isDefault': true},
      );

      await batch.commit();

      if (context.mounted) {
        NotificationHelper.showSuccess(
          context,
          'Default payment source updated',
        );
      }
    } catch (e) {
      if (context.mounted) {
        NotificationHelper.showError(
          context,
          'Error: ${e.toString()}',
        );
      }
    }
  }

  static Future<void> delete(
    BuildContext context,
    String userId,
    PaymentSource source,
  ) async {
    await _showDeleteConfirmation(context, userId, source);
  }

  static Future<void> _showDeleteConfirmation(
    BuildContext context,
    String userId,
    PaymentSource source,
  ) {
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => PopScope(
          canPop: !isLoading,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: GlassContainer(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delete Payment Source',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Are you sure you want to delete "${source.name}"?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCancelButton(dialogContext, isLoading),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildDeleteButton(
                            context,
                            dialogContext,
                            userId,
                            source,
                            isLoading,
                            (loading) => setState(() => isLoading = loading),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildCancelButton(BuildContext dialogContext, bool isLoading) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(
          dialogContext,
        ).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () => Navigator.pop(dialogContext),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isLoading
                    ? Theme.of(dialogContext).colorScheme.onSurface.withValues(alpha: 0.3)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDeleteButton(
    BuildContext context,
    BuildContext dialogContext,
    String userId,
    PaymentSource source,
    bool isLoading,
    Function(bool) setLoading,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red, Colors.redAccent]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () async {
                  setLoading(true);
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('paymentSources')
                        .doc(source.id)
                        .delete();

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      NotificationHelper.showSuccess(
                        context,
                        'Payment source deleted successfully',
                      );
                    }
                  } catch (e) {
                    setLoading(false);
                    if (context.mounted) {
                      NotificationHelper.showError(
                        context,
                        'Error: ${e.toString()}',
                      );
                    }
                  }
                },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
