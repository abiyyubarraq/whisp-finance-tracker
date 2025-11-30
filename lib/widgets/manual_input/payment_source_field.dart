// lib/widgets/manual_input/payment_source_field.dart
import 'package:flutter/material.dart';
import '../../models/payment_source.dart';
import '../common/suggested_text_field.dart';

/// A suggested text field for selecting payment sources.
///
/// Replaces the old PaymentSourceDropdown with an autocomplete-style input
/// that allows users to type custom values or select from existing sources.
class PaymentSourceField extends StatelessWidget {
  final TextEditingController controller;
  final List<PaymentSource> sources;
  final Function(bool)? onIsNewChanged;
  final String? Function(String?)? validator;
  final bool isLoading;
  final bool enabled;

  const PaymentSourceField({
    super.key,
    required this.controller,
    required this.sources,
    this.onIsNewChanged,
    this.validator,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Convert PaymentSource list to string list for suggestions
    final suggestions = sources.map((s) => s.name).toList();

    return SuggestedTextField(
      controller: controller,
      suggestions: suggestions,
      hintText: 'Payment Source',
      prefixIcon: Icons.payment_rounded,
      isLoading: isLoading,
      enabled: enabled,
      onNewItemDetected: onIsNewChanged,
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a payment source';
        }
        return null;
      },
    );
  }
}
