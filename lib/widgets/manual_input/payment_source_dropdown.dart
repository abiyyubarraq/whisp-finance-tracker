// lib/widgets/manual_input/payment_source_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_container.dart';

class PaymentSourceDropdown extends ConsumerWidget {
  final String? selectedPaymentSource;
  final Function(String?) onChanged;

  const PaymentSourceDropdown({
    super.key,
    required this.selectedPaymentSource,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('paymentSources')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GlassContainer(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return GlassContainer(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  'Failed to load payment sources',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          );
        }

        final sources = snapshot.data!.docs;

        if (sources.isEmpty) {
          return GlassContainer(
            padding: EdgeInsets.all(16),
            child: Text(
              'No payment sources available',
              style: TextStyle(fontSize: 14),
            ),
          );
        }

        return GlassContainer(
          padding: EdgeInsets.zero,
          child: DropdownButtonFormField<String>(
            initialValue: selectedPaymentSource ?? sources.first['name'],
            decoration: InputDecoration(
              hintText: 'Payment Source',
              prefixIcon: Icon(Icons.payment_rounded, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            items: sources.map((doc) {
              return DropdownMenuItem<String>(
                value: doc['name'] as String,
                child: Text(doc['name'] as String),
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
      },
    );
  }
}
