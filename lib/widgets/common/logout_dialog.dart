// lib/widgets/common/logout_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../glass_container.dart';

void showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (dialogContext) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              SizedBox(height: 20),
              Text(
                'Logout',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildCancelButton(dialogContext)),
                  SizedBox(width: 12),
                  Expanded(child: _buildLogoutButton(dialogContext, ref)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildIcon() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.withValues(alpha: 0.2),
      shape: BoxShape.circle,
    ),
    child: Icon(Icons.logout_rounded, color: Colors.red, size: 32),
  );
}

Widget _buildCancelButton(BuildContext dialogContext) {
  return Container(
    height: 48,
    decoration: BoxDecoration(
      color: Theme.of(
        dialogContext,
      ).colorScheme.onSurface.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(dialogContext),
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ),
  );
}

Widget _buildLogoutButton(BuildContext dialogContext, WidgetRef ref) {
  return Container(
    height: 48,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.red, Colors.redAccent]),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Navigator.pop(dialogContext);
          await ref.read(authServiceProvider).signOut();
        },
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            'Logout',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
