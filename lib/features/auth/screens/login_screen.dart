import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/features/auth/providers/login_provider.dart';
import 'package:itasks/features/auth/widgets/login_form.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    LoggerService.info('LoginScreen: A renderizar tela de login');
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => LoginProvider(authService: authService),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.backgroundGradientDark
                : AppColors.backgroundGradientLight,
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > AppSizes.desktop;
                final isTablet = constraints.maxWidth > AppSizes.tablet &&
                    constraints.maxWidth <= AppSizes.desktop;

                if (isDesktop) {
                  return _buildDesktopLayout(isDark);
                } else if (isTablet) {
                  return _buildTabletLayout(isDark);
                } else {
                  return _buildMobileLayout(isDark);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // Desktop Layout - Split screen with illustration
  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        // Left side - Illustration/Branding
        Expanded(
          flex: 5,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBrandingSection(isDark),
          ),
        ),
        // Right side - Login Form
        Expanded(
          flex: 4,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.xl6),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: const LoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Tablet Layout - Centered with smaller branding
  Widget _buildTabletLayout(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xl3),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompactBranding(isDark),
                SizedBox(height: AppSpacing.xl4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: const LoginForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mobile Layout - Full screen form with minimal branding
  Widget _buildMobileLayout(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xl2),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMobileBranding(isDark),
                SizedBox(height: AppSpacing.xl3),
                const LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDark ? AppColors.primaryLight : AppColors.primary)
                .withValues(alpha: 0.1),
            (isDark ? AppColors.accentLight : AppColors.accent)
                .withValues(alpha: 0.1),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppBorderRadius.radiusXL,
              boxShadow: AppShadows.shadowPrimary,
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpacing.xl2),
          
          // App Name
          Text(
            'iTasks',
            style: AppTypography.display1.copyWith(
              foreground: Paint()
                ..shader = AppColors.primaryGradient.createShader(
                  const Rect.fromLTWH(0, 0, 200, 70),
                ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          
          Text(
            'Gestão de Tarefas Profissional',
            style: AppTypography.h4.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xl2),
          
          // Features List
          _buildFeature(
            Icons.task_alt_rounded,
            'Kanban Board Intuitivo',
            isDark,
          ),
          SizedBox(height: AppSpacing.md),
          _buildFeature(
            Icons.groups_rounded,
            'Gestão de Equipas',
            isDark,
          ),
          SizedBox(height: AppSpacing.md),
          _buildFeature(
            Icons.analytics_rounded,
            'Relatórios Detalhados',
            isDark,
          ),
          SizedBox(height: AppSpacing.md),
          _buildFeature(
            Icons.speed_rounded,
            'Performance em Tempo Real',
            isDark,
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildCompactBranding(bool isDark) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppBorderRadius.radiusLG,
            boxShadow: AppShadows.shadowPrimary,
          ),
          child: const Icon(
            Icons.dashboard_customize_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          'iTasks',
          style: AppTypography.h1.copyWith(
            foreground: Paint()
              ..shader = AppColors.primaryGradient.createShader(
                const Rect.fromLTWH(0, 0, 200, 70),
              ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Gestão de Tarefas Profissional',
          style: AppTypography.bodyLarge.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileBranding(bool isDark) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppBorderRadius.radiusMD,
            boxShadow: AppShadows.shadowPrimary,
          ),
          child: const Icon(
            Icons.dashboard_customize_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'iTasks',
          style: AppTypography.h2.copyWith(
            foreground: Paint()
              ..shader = AppColors.primaryGradient.createShader(
                const Rect.fromLTWH(0, 0, 200, 70),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.primaryLight : AppColors.primary)
                .withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.radiusSM,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}