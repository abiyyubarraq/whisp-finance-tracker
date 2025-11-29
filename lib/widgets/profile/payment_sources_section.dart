// lib/widgets/profile/payment_sources_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_data_provider.dart';
import '../../config/theme.dart';
import '../glass_container.dart';
import 'payment_source_item.dart';
import 'payment_source_dialog.dart';

class PaymentSourcesSection extends ConsumerWidget {
  final String userId;

  const PaymentSourcesSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context), _buildSourcesList(context, ref)],
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

  Widget _buildSourcesList(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(paymentSourcesProvider(true));

    return sourcesAsync.when(
      data: (sources) {
        if (sources.isEmpty) {
          return _buildEmptyState(context);
        }

        return GlassContainer(
          padding: EdgeInsets.all(8),
          child: Column(
            children: sources.map((source) {
              return PaymentSourceItem(userId: userId, source: source);
            }).toList(),
          ),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        debugPrint('Error loading payment sources: $error');
        return Center(child: Text('Error loading payment sources'));
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
