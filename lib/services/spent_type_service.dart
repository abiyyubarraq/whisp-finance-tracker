// lib/services/spent_type_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../models/spent_type.dart';
import '../widgets/glass_container.dart';

class SpentTypeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a new spent type for the user
  static Future<void> add(
    BuildContext context,
    String userId,
    String name,
    String color,
    String icon,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spentTypes')
          .orderBy('order', descending: true)
          .limit(1)
          .get();

      final nextOrder = snapshot.docs.isEmpty
          ? 0
          : (snapshot.docs.first.data()['order'] as int) + 1;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('spentTypes')
          .add({
            'name': name,
            'color': color,
            'icon': icon,
            'isActive': true,
            'createdAt': DateTime.now(),
            'order': nextOrder,
          });

      if (context.mounted) {
        _showSuccessMessage(context, 'Spent type added successfully');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, e.toString());
      }
    }
  }

  /// Updates an existing spent type
  static Future<void> update(
    BuildContext context,
    String userId,
    SpentType spentType,
    String name,
    String color,
    String icon,
    bool isActive,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('spentTypes')
          .doc(spentType.id)
          .update({
            'name': name,
            'color': color,
            'icon': icon,
            'isActive': isActive,
          });

      if (context.mounted) {
        _showSuccessMessage(context, 'Spent type updated successfully');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, e.toString());
      }
    }
  }

  /// Deletes a spent type after user confirmation
  static Future<void> delete(
    BuildContext context,
    String userId,
    SpentType spentType,
  ) async {
    final confirm = await _showDeleteConfirmation(context, spentType.name);

    if (confirm == true) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('spentTypes')
            .doc(spentType.id)
            .delete();

        if (context.mounted) {
          _showSuccessMessage(context, 'Spent type deleted successfully');
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, e.toString());
        }
      }
    }
  }

  /// Shows a confirmation dialog before deleting
  static Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    String name,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogIcon(),
                SizedBox(height: 16),
                Text(
                  'Delete Spent Type',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "$name"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildCancelButton(dialogContext)),
                    SizedBox(width: 12),
                    Expanded(child: _buildDeleteButton(dialogContext)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDialogIcon() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32),
    );
  }

  static Widget _buildCancelButton(BuildContext dialogContext) {
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
          onTap: () => Navigator.pop(dialogContext, false),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDeleteButton(BuildContext dialogContext) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red, Colors.redAccent]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(dialogContext, true),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
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

  static void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
