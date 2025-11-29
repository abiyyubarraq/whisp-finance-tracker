// lib/widgets/common/confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../glass_container.dart';

/// A reusable confirmation dialog with consistent styling.
///
/// Usage:
/// ```dart
/// final confirmed = await showConfirmationDialog(
///   context: context,
///   title: 'Delete Expense',
///   message: 'Are you sure you want to delete this expense?',
///   confirmText: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed == true) {
///   // Perform delete action
/// }
/// ```
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
  IconData? icon,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      icon: icon,
    ),
  );
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ??
        (isDestructive ? Icons.delete_rounded : Icons.help_outline_rounded);
    final iconColor =
        isDestructive ? Colors.red : Theme.of(context).colorScheme.primary;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(iconColor, effectiveIcon),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                message,
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
                  Expanded(child: _buildCancelButton(context)),
                  SizedBox(width: 12),
                  Expanded(child: _buildConfirmButton(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, IconData iconData) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 32),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context, false),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              cancelText,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final buttonColor =
        isDestructive ? Colors.red : Theme.of(context).colorScheme.primary;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDestructive
              ? [Colors.red, Colors.redAccent]
              : [buttonColor, buttonColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context, true),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              confirmText,
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
