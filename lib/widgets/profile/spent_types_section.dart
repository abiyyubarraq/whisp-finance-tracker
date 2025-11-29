// lib/widgets/profile/spent_types_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_data_provider.dart';
import '../../config/theme.dart';
import '../glass_container.dart';
import 'spent_type_item.dart';
import 'spent_type_dialog.dart';

class SpentTypesSection extends ConsumerWidget {
  final String userId;

  const SpentTypesSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context), _buildTypesList(context, ref)],
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
            'Spent Types',
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
          onTap: () => showSpentTypeDialog(context, userId),
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

  Widget _buildTypesList(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(spentTypesProvider(true));

    return typesAsync.when(
      data: (types) {
        if (types.isEmpty) {
          return _buildEmptyState(context);
        }

        return GlassContainer(
          padding: EdgeInsets.all(8),
          child: Column(
            children: types.map((type) {
              return SpentTypeItem(userId: userId, spentType: type);
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
        debugPrint('Error loading spent types: $error');
        return Center(child: Text('Error loading spent types'));
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No spent types yet',
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
