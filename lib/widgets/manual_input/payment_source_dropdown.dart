// lib/widgets/manual_input/payment_source_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/glass_container.dart';
import '../../models/payment_source.dart';

class PaymentSourceDropdown extends ConsumerWidget {
  final String? selectedPaymentSource;
  final List<PaymentSource> sources;
  final Function(String?) onChanged;

  const PaymentSourceDropdown({
    super.key,
    required this.selectedPaymentSource,
    required this.onChanged,
    required this.sources,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: DropdownButtonFormField<String>(
        initialValue: selectedPaymentSource,
        decoration: InputDecoration(
          hintText: 'Payment Source',
          prefixIcon: Icon(Icons.payment_rounded, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: sources.map((source) {
          return DropdownMenuItem<String>(
            value: source.name,
            child: Text(source.name),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Please select a payment source';
          }
          return null;
        },
      ),
    );
  }
}
