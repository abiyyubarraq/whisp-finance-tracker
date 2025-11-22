// lib/widgets/profile/spent_types_section.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/spent_type.dart';
import '../../config/theme.dart';
import '../glass_container.dart';
import 'spent_type_item.dart';
import 'spent_type_dialog.dart';

class SpentTypesSection extends StatelessWidget {
  final String userId;

  const SpentTypesSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context), _buildTypesList(context)],
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

  Widget _buildTypesList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('spentTypes')
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
          return Center(child: Text('Error loading spent types'));
        }

        final types = snapshot.data?.docs ?? [];

        if (types.isEmpty) {
          return _buildEmptyState(context);
        }

        return GlassContainer(
          padding: EdgeInsets.all(8),
          child: Column(
            children: types.map((doc) {
              final type = SpentType.fromFirestore(doc);
              return SpentTypeItem(userId: userId, spentType: type);
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
