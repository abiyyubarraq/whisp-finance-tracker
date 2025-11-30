// lib/widgets/manual_input/item_name_field.dart
import 'package:flutter/material.dart';
import '../../models/item_name.dart';
import '../common/suggested_text_field.dart';

/// A suggested text field for entering item names.
///
/// Provides autocomplete suggestions from previously used item names.
class ItemNameField extends StatelessWidget {
  final TextEditingController controller;
  final List<ItemName> itemNames;
  final Function(bool)? onIsNewChanged;
  final String? Function(String?)? validator;
  final bool isLoading;
  final bool enabled;

  const ItemNameField({
    super.key,
    required this.controller,
    required this.itemNames,
    this.onIsNewChanged,
    this.validator,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Convert ItemName list to string list for suggestions
    final suggestions = itemNames.map((i) => i.name).toList();

    return SuggestedTextField(
      controller: controller,
      suggestions: suggestions,
      hintText: 'Item name',
      prefixIcon: Icons.shopping_bag_rounded,
      isLoading: isLoading,
      enabled: enabled,
      onNewItemDetected: onIsNewChanged,
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an item name';
        }
        return null;
      },
    );
  }
}
