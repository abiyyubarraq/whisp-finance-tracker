// lib/widgets/profile/payment_sources_section.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/payment_source.dart';
import '../../config/theme.dart';
import '../glass_container.dart';
import 'payment_source_item.dart';
import 'payment_source_dialog.dart';

class PaymentSourcesSection extends StatelessWidget {
  final String userId;

  const PaymentSourcesSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context), _buildSourcesList(context)],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Payment Sources',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => showPaymentSourceDialog(context, userId),
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.gradientDark
                    : AppTheme.gradientLight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSourcesList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('paymentSources')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading payment sources'));
        }

        final sources = snapshot.data?.docs ?? [];

        if (sources.isEmpty) {
          return _buildEmptyState(context);
        }

        return GlassContainer(
          padding: EdgeInsets.all(8),
          child: Column(
            children: sources.map((doc) {
              final source = PaymentSource.fromFirestore(doc);
              return PaymentSourceItem(userId: userId, source: source);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No payment sources yet',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
