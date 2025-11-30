import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/modern_app_bar.dart';
import '../config/theme.dart';
import '../widgets/profile/payment_source_item.dart';
import '../widgets/profile/payment_source_dialog.dart';

class PaymentSourcesManagementScreen extends ConsumerStatefulWidget {
  const PaymentSourcesManagementScreen({super.key});

  @override
  ConsumerState<PaymentSourcesManagementScreen> createState() =>
      _PaymentSourcesManagementScreenState();
}

class _PaymentSourcesManagementScreenState
    extends ConsumerState<PaymentSourcesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _buildMainContent(context, user.uid, isDark),
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

  Widget _buildMainContent(BuildContext context, String userId, bool isDark) {
    return Column(
      children: [
        PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: ModernAppBar(title: 'Payment Sources', showBackButton: true),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                SizedBox(height: 16),
                _buildSearchField(),
                SizedBox(height: 16),
                _buildHeader(context),
                SizedBox(height: 16),
                _buildSourcesList(context, userId),
                SizedBox(height: 24),
                _buildAddPaymentSourceButton(context, userId),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search payment sources...',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPaymentSourceButton(BuildContext context, String userId) {
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
            onTap: () => showPaymentSourceDialog(context, userId),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add Payment Source',
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
        ],
      ),
    );
  }

  Widget _buildSourcesList(BuildContext context, String userId) {
    final sourcesAsync = ref.watch(paymentSourcesProvider(true));

    return sourcesAsync.when(
      data: (sources) {
        if (sources.isEmpty) {
          return _buildEmptyState(context);
        }

        // Filter sources based on search query
        final filteredSources = _searchQuery.isEmpty
            ? sources
            : sources
                .where((source) =>
                    source.name.toLowerCase().contains(_searchQuery))
                .toList();

        if (filteredSources.isEmpty) {
          return _buildNoResultsState(context);
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GlassContainer(
            padding: EdgeInsets.all(8),
            child: Column(
              children: filteredSources.map((source) {
                return PaymentSourceItem(userId: userId, source: source);
              }).toList(),
            ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
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
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
              SizedBox(height: 12),
              Text(
                'No results found for "$_searchQuery"',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
