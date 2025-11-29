// lib/widgets/profile/spent_type_dialog.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/spent_type.dart';
import '../../config/theme.dart';
import '../glass_container.dart';
import '../../services/spent_type_service.dart';
import '../../utils/icon_helper.dart';
import '../../utils/color_helper.dart';

void showSpentTypeDialog(
  BuildContext context,
  String userId, {
  SpentType? spentType,
}) {
  final nameController = TextEditingController(text: spentType?.name ?? '');
  String selectedColor = spentType?.color ?? '#6B7280';
  String selectedIcon = spentType?.icon ?? 'more_horiz';
  bool isActive = spentType?.isActive ?? true;
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      spentType == null ? 'Add Spent Type' : 'Edit Spent Type',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24),
                    _buildNameField(nameController, isLoading),
                    SizedBox(height: 16),
                    _buildColorPicker(
                      context,
                      selectedColor,
                      isLoading,
                      (color) => setState(() => selectedColor = color),
                    ),
                    SizedBox(height: 16),
                    _buildIconPicker(
                      context,
                      selectedIcon,
                      isLoading,
                      (icon) => setState(() => selectedIcon = icon),
                    ),
                    SizedBox(height: 16),
                    _buildActiveSwitch(isActive, isLoading, (value) {
                      setState(() => isActive = value);
                    }),
                    SizedBox(height: 24),
                    _buildActions(
                      context,
                      dialogContext,
                      userId,
                      spentType,
                      nameController,
                      selectedColor,
                      selectedIcon,
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
        hintText: 'Spent Type Name',
        prefixIcon: Icon(Icons.category_rounded, size: 20),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
  );
}

Widget _buildColorPicker(
  BuildContext context,
  String selectedColor,
  bool isLoading,
  Function(String) onColorSelected,
) {
  final colors = ColorHelper.predefinedColors;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          'Color',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
      GlassContainer(
        padding: EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((colorHex) {
            final color = Color(
              int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
            );
            final isSelected = colorHex == selectedColor;

            return GestureDetector(
              onTap: isLoading ? null : () => onColorSelected(colorHex),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildIconPicker(
  BuildContext context,
  String selectedIcon,
  bool isLoading,
  Function(String) onIconSelected,
) {
  final icons = IconHelper.availableIcons;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          'Icon',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
      GlassContainer(
        padding: EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: icons.entries.map((entry) {
            final isSelected = entry.key == selectedIcon;

            return GestureDetector(
              onTap: isLoading ? null : () => onIconSelected(entry.key),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  entry.value,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
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
  SpentType? spentType,
  TextEditingController nameController,
  String selectedColor,
  String selectedIcon,
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
                        spentType,
                        nameController,
                        selectedColor,
                        selectedIcon,
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
                        spentType == null ? 'Add' : 'Save',
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
  SpentType? spentType,
  TextEditingController nameController,
  String selectedColor,
  String selectedIcon,
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
    if (spentType == null) {
      await SpentTypeService.add(
        context,
        userId,
        nameController.text.trim(),
        selectedColor,
        selectedIcon,
      );
    } else {
      await SpentTypeService.update(
        context,
        userId,
        spentType,
        nameController.text.trim(),
        selectedColor,
        selectedIcon,
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
