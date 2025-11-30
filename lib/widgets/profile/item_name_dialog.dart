// lib/widgets/profile/item_name_dialog.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/item_name.dart';
import '../../config/theme.dart';
import '../glass_container.dart';
import '../../services/item_name_service.dart';

void showItemNameDialog(
  BuildContext context,
  String userId, {
  ItemName? itemName,
}) {
  final nameController = TextEditingController(text: itemName?.name ?? '');
  bool isActive = itemName?.isActive ?? true;
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
                    itemName == null ? 'Add Item Name' : 'Edit Item Name',
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
                    itemName,
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
        hintText: 'Item Name',
        prefixIcon: Icon(Icons.shopping_bag_rounded, size: 20),
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
  ItemName? itemName,
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
                        itemName,
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
                        itemName == null ? 'Add' : 'Save',
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
  ItemName? itemName,
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
    if (itemName == null) {
      await ItemNameService.add(context, userId, nameController.text.trim());
    } else {
      await ItemNameService.update(
        context,
        userId,
        itemName,
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
