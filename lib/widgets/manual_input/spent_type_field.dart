// lib/widgets/manual_input/spent_type_field.dart
import 'package:flutter/material.dart';
import '../../models/spent_type.dart';
import '../common/suggested_text_field.dart';

/// A suggested text field for selecting spent types (categories).
///
/// Displays color dots alongside category names in the suggestions dropdown.
class SpentTypeField extends StatelessWidget {
  final TextEditingController controller;
  final List<SpentType> spentTypes;
  final Function(bool)? onIsNewChanged;
  final String? Function(String?)? validator;
  final bool isLoading;
  final bool enabled;

  const SpentTypeField({
    super.key,
    required this.controller,
    required this.spentTypes,
    this.onIsNewChanged,
    this.validator,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Convert SpentType list to string list for suggestions
    final suggestions = spentTypes.map((s) => s.name).toList();

    // Create a map for quick color lookup
    final colorMap = {
      for (final type in spentTypes) type.name: type.color,
    };

    return SuggestedTextField(
      controller: controller,
      suggestions: suggestions,
      hintText: 'Category',
      prefixIcon: Icons.category_rounded,
      isLoading: isLoading,
      enabled: enabled,
      onNewItemDetected: onIsNewChanged,
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a category';
        }
        return null;
      },
      suggestionBuilder: (suggestion) {
        final colorHex = colorMap[suggestion] ?? '#6B7280';
        final color = Color(
          int.parse(colorHex.substring(1), radix: 16) + 0xFF000000,
        );

        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
