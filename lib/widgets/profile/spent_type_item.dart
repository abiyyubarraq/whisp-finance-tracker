// lib/widgets/profile/spent_type_item.dart
import 'package:flutter/material.dart';
import '../../models/spent_type.dart';
import 'spent_type_dialog.dart';
import '../../services/spent_type_service.dart';
import '../../utils/icon_helper.dart';

class SpentTypeItem extends StatelessWidget {
  final String userId;
  final SpentType spentType;

  const SpentTypeItem({
    super.key,
    required this.userId,
    required this.spentType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              showSpentTypeDialog(context, userId, spentType: spentType),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                _buildIcon(context),
                SizedBox(width: 16),
                _buildInfo(context),
                _buildDefaultButton(context),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final iconData = IconHelper.getIconFromString(spentType.icon);
    final color = _parseColor(spentType.color);

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spentType.name,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2),
          Text(
            spentType.isActive ? 'Active' : 'Inactive',
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

  Widget _buildDefaultButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        spentType.isDefault ? Icons.star_rounded : Icons.star_border_rounded,
        size: 20,
      ),
      onPressed: spentType.isDefault
          ? null
          : () => SpentTypeService.setDefault(context, userId, spentType),
      color: spentType.isDefault
          ? Colors.amber
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      tooltip: spentType.isDefault ? 'Default' : 'Set as default',
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_rounded, size: 18),
          onPressed: () =>
              showSpentTypeDialog(context, userId, spentType: spentType),
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        IconButton(
          icon: Icon(Icons.delete_rounded, size: 18),
          onPressed: () => SpentTypeService.delete(context, userId, spentType),
          color: Colors.red,
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}
