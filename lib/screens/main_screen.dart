import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_list_screen.dart';
import 'analytics_screen.dart';
import 'add_expense_modal.dart';
import '../widgets/glass_container.dart';
import '../config/theme.dart';
import '../utils/test_keys.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [ExpenseListScreen(), AnalyticsScreen()];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppTheme.backgroundDark, AppTheme.surfaceDark]
                    : [AppTheme.backgroundLight, Color(0xFFE0E7FF)],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? AppTheme.gradientDark
                      : AppTheme.gradientLight,
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
          // Main content
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, isDark),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.all(20),
      child: GlassContainer(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              itemKey: TestKeys.homeExpensesTab,
              semanticLabel: 'Expenses tab',
              icon: Icons.receipt_long_rounded,
              index: 0,
              isDark: isDark,
            ),
            _buildAddButton(context, isDark),
            _buildNavItem(
              context,
              itemKey: TestKeys.homeAnalyticsTab,
              semanticLabel: 'Analytics tab',
              icon: Icons.analytics_rounded,
              index: 1,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required Key itemKey,
    required String semanticLabel,
    required IconData icon,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        key: itemKey,
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: isDark
                        ? AppTheme.gradientDark
                        : AppTheme.gradientLight,
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight)
                              .withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return Semantics(
      label: 'Add expense',
      button: true,
      child: GestureDetector(
        key: TestKeys.homeAddButton,
        onTap: () => _showAddExpenseModal(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF512F), // Bright red
                Color(0xFFDD2476), // Deep rose
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF512F).withValues(alpha: 0.6),
                blurRadius: 24,
                spreadRadius: 2,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0xFFDD2476).withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExpenseModal(),
    );
  }
}
