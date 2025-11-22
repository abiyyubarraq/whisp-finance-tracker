// lib/widgets/profile/profile_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../glass_container.dart';

class ProfileHeader extends StatelessWidget {
  final String email;
  final DateTime creationTime;

  const ProfileHeader({
    super.key,
    required this.email,
    required this.creationTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GradientGlassContainer(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatar(email),
            SizedBox(height: 16),
            Text(
              email,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Member since ${DateFormat('MMM yyyy').format(creationTime)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String email) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        child: Text(
          email.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
