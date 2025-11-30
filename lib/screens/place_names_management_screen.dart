// lib/screens/place_names_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/modern_app_bar.dart';
import '../config/theme.dart';
import '../widgets/profile/place_name_item.dart';
import '../widgets/profile/place_name_dialog.dart';

class PlaceNamesManagementScreen extends ConsumerStatefulWidget {
  const PlaceNamesManagementScreen({super.key});

  @override
  ConsumerState<PlaceNamesManagementScreen> createState() =>
      _PlaceNamesManagementScreenState();
}

class _PlaceNamesManagementScreenState
    extends ConsumerState<PlaceNamesManagementScreen> {
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
          child: ModernAppBar(title: 'Place Names', showBackButton: true),
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
                _buildPlaceNamesList(context, userId),
                SizedBox(height: 24),
                _buildAddPlaceNameButton(context, userId),
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
            hintText: 'Search place names...',
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

  Widget _buildAddPlaceNameButton(BuildContext context, String userId) {
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
            onTap: () => showPlaceNameDialog(context, userId),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add Place Name',
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
              'Place Names',
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

  Widget _buildPlaceNamesList(BuildContext context, String userId) {
    final placeNamesAsync = ref.watch(placeNamesProvider(true));

    return placeNamesAsync.when(
      data: (placeNames) {
        if (placeNames.isEmpty) {
          return _buildEmptyState(context);
        }

        // Filter place names based on search query
        final filteredPlaceNames = _searchQuery.isEmpty
            ? placeNames
            : placeNames
                .where((placeName) =>
                    placeName.name.toLowerCase().contains(_searchQuery))
                .toList();

        if (filteredPlaceNames.isEmpty) {
          return _buildNoResultsState(context);
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GlassContainer(
            padding: EdgeInsets.all(8),
            child: Column(
              children: filteredPlaceNames.map((placeName) {
                return PlaceNameItem(userId: userId, placeName: placeName);
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
        debugPrint('Error loading place names: $error');
        return Center(child: Text('Error loading place names'));
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
            'No place names yet',
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
