// lib/widgets/profile/item_name_item.dart
import 'package:flutter/material.dart';
import '../../models/item_name.dart';
import '../../config/theme.dart';
import 'item_name_dialog.dart';
import '../../services/item_name_service.dart';

class ItemNameItem extends StatelessWidget {
  final String userId;
  final ItemName itemName;

  const ItemNameItem({
    super.key,
    required this.userId,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showItemNameDialog(context, userId, itemName: itemName),
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
        Icons.shopping_bag_rounded,
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
            itemName.name,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2),
          Text(
            itemName.isActive ? 'Active' : 'Inactive',
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
              showItemNameDialog(context, userId, itemName: itemName),
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        IconButton(
          icon: Icon(Icons.delete_rounded, size: 18),
          onPressed: () => ItemNameService.delete(context, userId, itemName),
          color: Colors.red,
        ),
      ],
    );
  }
}
