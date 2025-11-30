// lib/widgets/manual_input/place_name_field.dart
import 'package:flutter/material.dart';
import '../../models/place_name.dart';
import '../common/suggested_text_field.dart';

/// A suggested text field for entering place names.
///
/// Provides autocomplete suggestions from previously used place names.
class PlaceNameField extends StatelessWidget {
  final TextEditingController controller;
  final List<PlaceName> placeNames;
  final Function(bool)? onIsNewChanged;
  final String? Function(String?)? validator;
  final bool isLoading;
  final bool enabled;

  const PlaceNameField({
    super.key,
    required this.controller,
    required this.placeNames,
    this.onIsNewChanged,
    this.validator,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Convert PlaceName list to string list for suggestions
    final suggestions = placeNames.map((p) => p.name).toList();

    return SuggestedTextField(
      controller: controller,
      suggestions: suggestions,
      hintText: 'Place / Store name',
      prefixIcon: Icons.store_rounded,
      isLoading: isLoading,
      enabled: enabled,
      onNewItemDetected: onIsNewChanged,
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a place name';
        }
        return null;
      },
    );
  }
}
