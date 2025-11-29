// lib/widgets/profile/payment_source_dialog.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/payment_source.dart';
import '../../config/theme.dart';
import '../glass_container.dart';
import '../../services/payment_source_service.dart';

void showPaymentSourceDialog(
  BuildContext context,
  String userId, {
  PaymentSource? source,
}) {
  final nameController = TextEditingController(text: source?.name ?? '');
  bool isActive = source?.isActive ?? true;
  bool isLoading = false;

  showDialog(
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
                    source == null ? 'Add Payment Source' : 'Edit Payment Source',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  _buildNameField(nameController, isLoading),
                  SizedBox(height: 16),
                  _buildActiveSwitch(isActive, isLoading, (value) {
                    setState(() => isActive = value);
                  }),
                  SizedBox(height: 24),
                  _buildActions(
                    context,
                    dialogContext,
                    userId,
                    source,
                    nameController,
                    isActive,
                    isLoading,
                    (loading) => setState(() => isLoading = loading),
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

Widget _buildNameField(TextEditingController controller, bool isLoading) {
  return GlassContainer(
    padding: EdgeInsets.zero,
    child: TextField(
      controller: controller,
      enabled: !isLoading,
      decoration: InputDecoration(
        hintText: 'Payment Source Name',
        prefixIcon: Icon(Icons.account_balance_wallet_rounded, size: 20),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
  );
}

Widget _buildActiveSwitch(bool isActive, bool isLoading, Function(bool) onChanged) {
  return Row(
    children: [
      Text('Active'),
      Spacer(),
      Switch(
        value: isActive,
        onChanged: isLoading ? null : onChanged,
      ),
    ],
  );
}

Widget _buildActions(
  BuildContext context,
  BuildContext dialogContext,
  String userId,
  PaymentSource? source,
  TextEditingController nameController,
  bool isActive,
  bool isLoading,
  Function(bool) setLoading,
) {
  return Row(
    children: [
      Expanded(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
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
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.gradientDark
                  : AppTheme.gradientLight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading
                  ? null
                  : () => _handleSave(
                        context,
                        dialogContext,
                        userId,
                        source,
                        nameController,
                        isActive,
                        setLoading,
                      ),
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
                        source == null ? 'Add' : 'Save',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

void _handleSave(
  BuildContext context,
  BuildContext dialogContext,
  String userId,
  PaymentSource? source,
  TextEditingController nameController,
  bool isActive,
  Function(bool) setLoading,
) async {
  if (nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Please enter a name')));
    return;
  }

  setLoading(true);

  try {
    if (source == null) {
      await PaymentSourceService.add(context, userId, nameController.text.trim());
    } else {
      await PaymentSourceService.update(
        context,
        userId,
        source,
        nameController.text.trim(),
        isActive,
      );
    }

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }
  } catch (e) {
    setLoading(false);
  }
}
