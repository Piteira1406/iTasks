import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/widgets/custom_snackbar.dart';
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/core/widgets/skeleton_loader.dart';
import 'package:itasks/features/reports/providers/report_provider.dart';
import 'package:itasks/features/reports/widgets/report_filters.dart';
import 'package:itasks/features/reports/widgets/statistics_cards.dart';
import 'package:itasks/features/reports/widgets/tasks_table.dart';
import 'package:itasks/features/reports/widgets/storypoints_estimation_card.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadInitialData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildModernHeader(context, isDark, reportProvider),
              
              // Content
              Expanded(
                child: reportProvider.isLoading
                    ? _buildLoadingState(isDark)
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildContent(context, isDark, reportProvider),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark, ReportProvider reportProvider) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
            .withValues(alpha: 0.8),
        boxShadow: AppShadows.shadowSM,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: AppSpacing.sm),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: AppBorderRadius.radiusSM,
                  boxShadow: AppShadows.shadowAccent,
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard de Relatórios',
                      style: AppTypography.h4.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Análise e estatísticas de tarefas',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (reportProvider.tasks.isNotEmpty) ...[
                CustomButton(
                  text: 'Limpar',
                  onPressed: () {
                    reportProvider.clearFilters();
                    CustomSnackBar.showInfo(
                      context,
                      'Filtros limpos',
                      duration: const Duration(seconds: 2),
                    );
                  },
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.small,
                  icon: Icons.clear_all_rounded,
                ),
                SizedBox(width: AppSpacing.sm),
                _buildExportMenu(context, reportProvider, isDark),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportMenu(BuildContext context, ReportProvider reportProvider, bool isDark) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppBorderRadius.radiusSM,
          boxShadow: AppShadows.shadowPrimary,
        ),
        child: const Icon(
          Icons.download_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
      tooltip: 'Exportar',
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.radiusMD,
      ),
      onSelected: (value) async {
        if (value == 'tasks') {
          await _exportTasks(context);
        } else if (value == 'statistics') {
          await _exportStatistics(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'tasks',
          child: Row(
            children: [
              Icon(Icons.table_chart_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Exportar Tarefas',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'statistics',
          child: Row(
            children: [
              Icon(Icons.analytics_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Exportar Estatísticas',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics cards skeleton
          LayoutBuilder(
            builder: (context, constraints) {
              int columns = 2;
              if (constraints.maxWidth > 1200) {
                columns = 6;
              } else if (constraints.maxWidth > 800) {
                columns = 3;
              } else if (constraints.maxWidth > 600) {
                columns = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return GlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonLoader(
                            width: 40,
                            height: 40,
                            borderRadius: AppBorderRadius.radiusMD,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLoader(
                                width: 60,
                                height: 24,
                                borderRadius: AppBorderRadius.radiusSM,
                              ),
                              SizedBox(height: AppSpacing.xs),
                              SkeletonLoader(
                                width: 100,
                                height: 14,
                                borderRadius: AppBorderRadius.radiusSM,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          
          SizedBox(height: AppSpacing.xl),
          
          // Table skeleton
          GlassCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    width: 150,
                    height: 20,
                    borderRadius: AppBorderRadius.radiusSM,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ...List.generate(5, (index) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SkeletonLoader(
                            width: double.infinity,
                            height: 16,
                            borderRadius: AppBorderRadius.radiusSM,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SkeletonLoader(
                            width: double.infinity,
                            height: 16,
                            borderRadius: AppBorderRadius.radiusSM,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        SkeletonLoader(
                          width: 60,
                          height: 16,
                          borderRadius: AppBorderRadius.radiusSM,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, ReportProvider reportProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success/Error Messages
          if (reportProvider.successMessage != null) ...[
            _buildModernSuccessCard(
              reportProvider.successMessage!,
              () => reportProvider.clearSuccess(),
              isDark,
            ),
            SizedBox(height: AppSpacing.md),
          ],
          if (reportProvider.errorMessage != null) ...[
            _buildModernErrorCard(
              reportProvider.errorMessage!,
              () => reportProvider.clearError(),
              isDark,
            ),
            SizedBox(height: AppSpacing.md),
          ],

          // Filters
          const ReportFilters(),
          SizedBox(height: AppSpacing.lg),

          // StoryPoints Estimation
          const StoryPointsEstimationCard(),
          SizedBox(height: AppSpacing.lg),

          // Generate Report Button
          CustomButton(
            text: 'Gerar Relatório',
            onPressed: () => reportProvider.generateReport(),
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
            isFullWidth: true,
            icon: Icons.assessment_rounded,
          ),
          
          SizedBox(height: AppSpacing.xl2),

          // Statistics & Content
          if (reportProvider.tasks.isNotEmpty) ...[
            const StatisticsCards(),
            SizedBox(height: AppSpacing.xl2),

            // Export Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Exportar Tarefas',
                    onPressed: () => _exportTasks(context),
                    variant: ButtonVariant.outlined,
                    size: ButtonSize.medium,
                    icon: Icons.table_chart_rounded,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomButton(
                    text: 'Exportar Stats',
                    onPressed: () => _exportStatistics(context),
                    variant: ButtonVariant.outlined,
                    size: ButtonSize.medium,
                    icon: Icons.analytics_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl2),

            // Tasks Table
            GlassCard(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tarefas',
                              style: AppTypography.h5.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${reportProvider.tasks.length} resultados',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.successGradient,
                            borderRadius: AppBorderRadius.radiusFull,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.successColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                '${reportProvider.statistics['completionRate']}% concluído',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    const TasksTable(),
                  ],
                ),
              ),
            ),
          ],

          // Empty State
          if (reportProvider.tasks.isEmpty &&
              reportProvider.errorMessage == null &&
              reportProvider.successMessage == null) ...[
            SizedBox(height: AppSpacing.xl6),
            _buildEmptyState(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildModernSuccessCard(String message, VoidCallback onDismiss, bool isDark) {
    return GlassCard(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.successColor.withValues(alpha: 0.1),
              AppColors.successColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: AppBorderRadius.radiusMD,
          border: Border.all(
            color: AppColors.successColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.successColor.withValues(alpha: 0.2),
                borderRadius: AppBorderRadius.radiusSM,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.successColor,
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sucesso!',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: AppColors.successColor),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernErrorCard(String message, VoidCallback onDismiss, bool isDark) {
    return GlassCard(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.errorColor.withValues(alpha: 0.1),
              AppColors.errorColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: AppBorderRadius.radiusMD,
          border: Border.all(
            color: AppColors.errorColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.2),
                borderRadius: AppBorderRadius.radiusSM,
              ),
              child: Icon(
                Icons.error_rounded,
                color: AppColors.errorColor,
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erro',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: AppColors.errorColor),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppBorderRadius.radiusFull,
            ),
            child: Icon(
              Icons.assessment_outlined,
              size: 60,
              color: (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)
                  .withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: AppSpacing.xl2),
          Text(
            'Nenhum relatório gerado',
            style: AppTypography.h4.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Selecione os filtros acima e clique em "Gerar Relatório"',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureChip(Icons.filter_list_rounded, 'Filtros', isDark),
              SizedBox(width: AppSpacing.md),
              _buildFeatureChip(Icons.calendar_today_rounded, 'Datas', isDark),
              SizedBox(width: AppSpacing.md),
              _buildFeatureChip(Icons.person_rounded, 'Utilizadores', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
            .withValues(alpha: 0.5),
        borderRadius: AppBorderRadius.radiusFull,
        border: Border.all(
          color: (isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary)
              .withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTasks(BuildContext context) async {
    final reportProvider = context.read<ReportProvider>();

    // Mostrar diálogo de loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Exportando tarefas...'),
            SizedBox(height: 8),
            Text(
              'O arquivo será salvo e compartilhado',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    final filePath = await reportProvider.exportToCSV();

    if (context.mounted) {
      Navigator.of(context).pop(); // Fechar loading

      if (filePath != null) {
        // Sucesso - a mensagem já foi definida no provider
        CustomSnackBar.showSuccess(
          context,
          '✅ Tarefas exportadas com sucesso!',
        );
      } else {
        // Erro - a mensagem já foi definida no provider
        CustomSnackBar.showError(
          context,
          '❌ Erro ao exportar tarefas',
        );
      }
    }
  }

  Future<void> _exportStatistics(BuildContext context) async {
    final reportProvider = context.read<ReportProvider>();

    // Mostrar diálogo de loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Exportando estatísticas...'),
            SizedBox(height: 8),
            Text(
              'O arquivo será salvo e compartilhado',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    final filePath = await reportProvider.exportStatistics();

    if (context.mounted) {
      Navigator.of(context).pop(); // Fechar loading

      if (filePath != null) {
        CustomSnackBar.showSuccess(
          context,
          '✅ Estatísticas exportadas com sucesso!',
        );
      } else {
        CustomSnackBar.showError(
          context,
          '❌ Erro ao exportar estatísticas',
        );
      }
    }
  }
}
