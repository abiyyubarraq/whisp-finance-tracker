import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/theme_toggle.dart';
import '../config/theme.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/common/logout_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: Text('Please login'));
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackground(isDark),
          _buildDecorativeCircles(isDark),
          _buildMainContent(context, ref, user, isDark),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.backgroundDark, AppTheme.surfaceDark]
              : [AppTheme.backgroundLight, Color(0xFFE0E7FF)],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryLight.withValues(alpha: 0.3),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentLight.withValues(alpha: 0.3),
                  AppTheme.primaryLight.withValues(alpha: 0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentLight.withValues(alpha: 0.2),
                  blurRadius: 80,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    bool isDark,
  ) {
    return Column(
      children: [
        PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: ModernAppBar(title: 'Profile', showBackButton: true),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                SizedBox(height: 16),
                ProfileHeader(
                  email: user.email ?? 'No email',
                  creationTime: user.metadata.creationTime ?? DateTime.now(),
                ),
                SizedBox(height: 24),
                _buildPreferencesSection(context),
                SizedBox(height: 24),
                _buildPaymentSourcesSection(context, user.uid),
                SizedBox(height: 24),
                _buildSpentTypesSection(context, user.uid),
                SizedBox(height: 24),
                _buildPlaceNamesSection(context, user.uid),
                SizedBox(height: 24),
                _buildItemNamesSection(context, user.uid),
                SizedBox(height: 24),
                _buildLogoutButton(context, ref),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return _buildSection(context, 'Preferences', [
      _buildSettingItem(
        context,
        icon: Icons.palette_rounded,
        title: 'Theme',
        subtitle: 'Switch appearance',
        trailing: ThemeToggle(),
      ),
    ]);
  }

  Widget _buildPaymentSourcesSection(BuildContext context, String userId) {
    return _buildSection(context, 'Settings', [
      _buildSettingItem(
        context,
        icon: Icons.account_balance_wallet_rounded,
        title: 'Payment Sources',
        subtitle: 'Edit Payment Sources',
        onTap: () {
          Navigator.pushNamed(context, '/profile/payment-sources');
        },
      ),
    ]);
  }

  Widget _buildSpentTypesSection(BuildContext context, String userId) {
    return _buildSection(context, '', [
      _buildSettingItem(
        context,
        icon: Icons.category_rounded,
        title: 'Spent Types',
        subtitle: 'Edit Spent Types',
        onTap: () {
          Navigator.pushNamed(context, '/profile/spent-types');
        },
      ),
    ]);
  }

  Widget _buildPlaceNamesSection(BuildContext context, String userId) {
    return _buildSection(context, '', [
      _buildSettingItem(
        context,
        icon: Icons.store_rounded,
        title: 'Place Names',
        subtitle: 'Manage saved places',
        onTap: () {
          Navigator.pushNamed(context, '/profile/place-names');
        },
      ),
    ]);
  }

  Widget _buildItemNamesSection(BuildContext context, String userId) {
    return _buildSection(context, '', [
      _buildSettingItem(
        context,
        icon: Icons.shopping_bag_rounded,
        title: 'Item Names',
        subtitle: 'Manage saved items',
        onTap: () {
          Navigator.pushNamed(context, '/profile/item-names');
        },
      ),
    ]);
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                title,
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
          GlassContainer(
            padding: EdgeInsets.all(8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? AppTheme.gradientDark
                          : AppTheme.gradientLight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    (onTap != null
                        ? Icon(
                            Icons.chevron_right_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                          )
                        : SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red, Colors.redAccent]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showLogoutDialog(context, ref),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
