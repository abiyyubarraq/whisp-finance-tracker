// lib/services/place_name_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../models/place_name.dart';
import '../widgets/glass_container.dart';
import '../utils/notification_helper.dart';

class PlaceNameService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _maxItems = 300;

  /// Adds a new place name with notification (for profile settings)
  static Future<void> add(
    BuildContext context,
    String userId,
    String name,
  ) async {
    try {
      await _addToCollection(userId, name);
      await _enforceLimit(userId);

      if (context.mounted) {
        NotificationHelper.showSuccess(
          context,
          'Place name added successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        NotificationHelper.showError(context, 'Error: ${e.toString()}');
      }
    }
  }

  /// Adds a new place name without notification (for auto-add during expense save)
  static Future<void> addSilent(String userId, String name) async {
    try {
      // Check if already exists (case-insensitive)
      final exists = await _existsCaseInsensitive(userId, name);
      if (exists) return;

      await _addToCollection(userId, name);
      await _enforceLimit(userId);
    } catch (e) {
      debugPrint('Error adding place name silently: $e');
    }
  }

  /// Internal method to add to collection
  static Future<void> _addToCollection(String userId, String name) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('placeNames')
        .add({'name': name, 'isActive': true, 'createdAt': DateTime.now()});
  }

  /// Enforces the 100 item limit by deleting oldest items
  static Future<void> _enforceLimit(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('placeNames')
        .orderBy('createdAt', descending: false)
        .get();

    if (snapshot.docs.length > _maxItems) {
      final itemsToDelete = snapshot.docs.length - _maxItems;
      final batch = _firestore.batch();

      for (int i = 0; i < itemsToDelete; i++) {
        batch.delete(snapshot.docs[i].reference);
      }

      await batch.commit();
    }
  }

  /// Check if place name exists (case-insensitive)
  static Future<bool> _existsCaseInsensitive(String userId, String name) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('placeNames')
        .get();

    return snapshot.docs.any(
      (doc) =>
          (doc.data()['name'] as String).toLowerCase() == name.toLowerCase(),
    );
  }

  /// Updates an existing place name
  static Future<void> update(
    BuildContext context,
    String userId,
    PlaceName placeName,
    String name,
    bool isActive,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('placeNames')
          .doc(placeName.id)
          .update({'name': name, 'isActive': isActive});

      if (context.mounted) {
        NotificationHelper.showSuccess(
          context,
          'Place name updated successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        NotificationHelper.showError(context, 'Error: ${e.toString()}');
      }
    }
  }

  /// Deletes a place name after user confirmation
  static Future<void> delete(
    BuildContext context,
    String userId,
    PlaceName placeName,
  ) async {
    await _showDeleteConfirmation(context, userId, placeName);
  }

  static Future<void> _showDeleteConfirmation(
    BuildContext context,
    String userId,
    PlaceName placeName,
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
                      'Delete Place Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Are you sure you want to delete "${placeName.name}"?',
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
                            placeName,
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
                    ? Theme.of(
                        dialogContext,
                      ).colorScheme.onSurface.withValues(alpha: 0.3)
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
    PlaceName placeName,
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
                    await _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('placeNames')
                        .doc(placeName.id)
                        .delete();

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      NotificationHelper.showSuccess(
                        context,
                        'Place name deleted successfully',
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
