// lib/widgets/profile/payment_source_item.dart
import 'package:flutter/material.dart';
import '../../models/payment_source.dart';
import '../../config/theme.dart';
import 'payment_source_dialog.dart';
import '../../services/payment_source_service.dart';

class PaymentSourceItem extends StatelessWidget {
  final String userId;
  final PaymentSource source;

  const PaymentSourceItem({
    super.key,
    required this.userId,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showPaymentSourceDialog(context, userId, source: source),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                _buildIcon(context),
                SizedBox(width: 16),
                _buildInfo(context),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.gradientDark
              : AppTheme.gradientLight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            source.name,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2),
          Text(
            source.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_rounded, size: 18),
          onPressed: () =>
              showPaymentSourceDialog(context, userId, source: source),
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        IconButton(
          icon: Icon(Icons.delete_rounded, size: 18),
          onPressed: () => PaymentSourceService.delete(context, userId, source),
          color: Colors.red,
        ),
      ],
    );
  }
}
