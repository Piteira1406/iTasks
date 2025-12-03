// lib/core/widgets/responsive_scaffold.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_dimensions.dart';

/// Breakpoints for responsive design
class ResponsiveBreakpoints {
  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double large = 1280;
}

/// Responsive scaffold that adapts navigation based on screen size
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<NavigationDestination>? bottomNavDestinations;
  final List<NavigationRailDestination>? railDestinations;
  final Widget? drawer;
  final int? currentIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<Widget>? appBarActions;
  final FloatingActionButton? floatingActionButton;
  final bool showAppBar;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.bottomNavDestinations,
    this.railDestinations,
    this.drawer,
    this.currentIndex,
    this.onDestinationSelected,
    this.appBarActions,
    this.floatingActionButton,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= ResponsiveBreakpoints.desktop;
        final isTablet = width >= ResponsiveBreakpoints.tablet && width < ResponsiveBreakpoints.desktop;
        final isMobile = width < ResponsiveBreakpoints.mobile;

        // Desktop: NavigationRail + Drawer
        if (isDesktop && railDestinations != null) {
          return _buildDesktopLayout(context);
        }

        // Tablet/Mobile: Standard Scaffold with optional bottom nav
        return _buildMobileLayout(context, isMobile);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: currentIndex ?? 0,
            onDestinationSelected: onDestinationSelected,
            extended: true,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            selectedIconTheme: IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            unselectedIconTheme: IconThemeData(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            unselectedLabelTextStyle: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            leading: drawer != null
                ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : null,
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.lg),
                  child: IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    tooltip: 'Definições',
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            destinations: railDestinations ?? [],
          ),
          
          const VerticalDivider(thickness: 1, width: 1),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                if (showAppBar)
                  AppBar(
                    title: Text(title),
                    actions: appBarActions,
                    automaticallyImplyLeading: false,
                  ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      drawer: drawer,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isMobile) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: appBarActions,
            )
          : null,
      body: body,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: isMobile && bottomNavDestinations != null
          ? NavigationBar(
              selectedIndex: currentIndex ?? 0,
              onDestinationSelected: onDestinationSelected,
              destinations: bottomNavDestinations!,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
            )
          : null,
    );
  }
}

/// Helper to determine device type
class DeviceType {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tablet && width < ResponsiveBreakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;

  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.large;
}

/// Responsive padding helper
class ResponsivePadding {
  static EdgeInsets all(BuildContext context) {
    if (DeviceType.isMobile(context)) return EdgeInsets.all(AppSpacing.md);
    if (DeviceType.isTablet(context)) return EdgeInsets.all(AppSpacing.lg);
    return EdgeInsets.all(AppSpacing.xl2);
  }

  static EdgeInsets horizontal(BuildContext context) {
    if (DeviceType.isMobile(context)) return EdgeInsets.symmetric(horizontal: AppSpacing.md);
    if (DeviceType.isTablet(context)) return EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    return EdgeInsets.symmetric(horizontal: AppSpacing.xl3);
  }

  static EdgeInsets vertical(BuildContext context) {
    if (DeviceType.isMobile(context)) return EdgeInsets.symmetric(vertical: AppSpacing.md);
    if (DeviceType.isTablet(context)) return EdgeInsets.symmetric(vertical: AppSpacing.lg);
    return EdgeInsets.symmetric(vertical: AppSpacing.xl2);
  }
}

/// Responsive column count for grids
class ResponsiveGrid {
  static int getColumnCount(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3, int large = 4}) {
    if (DeviceType.isLarge(context)) return large;
    if (DeviceType.isDesktop(context)) return desktop;
    if (DeviceType.isTablet(context)) return tablet;
    return mobile;
  }

  static double getChildAspectRatio(BuildContext context, {double mobile = 1.0, double tablet = 1.2, double desktop = 1.5}) {
    if (DeviceType.isDesktop(context)) return desktop;
    if (DeviceType.isTablet(context)) return tablet;
    return mobile;
  }
}
