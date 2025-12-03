import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/features/reports/providers/report_provider.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';

class StatisticsCards extends StatelessWidget {
  const StatisticsCards({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final stats = reportProvider.statistics;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas',
          style: AppTypography.h5.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        
        // Modern Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.3,
              children: [
                _buildModernStatCard(
                  context,
                  'Total',
                  stats['total'].toString(),
                  Icons.assignment_rounded,
                  AppColors.primary,
                  isDark,
                ),
                _buildModernStatCard(
                  context,
                  'Concluídas',
                  stats['completed'].toString(),
                  Icons.check_circle_rounded,
                  AppColors.successColor,
                  isDark,
                ),
                _buildModernStatCard(
                  context,
                  'Em Progresso',
                  stats['ongoing'].toString(),
                  Icons.pending_rounded,
                  AppColors.warningColor,
                  isDark,
                ),
                _buildModernStatCard(
                  context,
                  'Pendentes',
                  stats['todo'].toString(),
                  Icons.pending_actions_rounded,
                  AppColors.infoColor,
                  isDark,
                ),
                _buildModernStatCard(
                  context,
                  'Story Points',
                  '${stats['completedStoryPoints']} / ${stats['totalStoryPoints']}',
                  Icons.stars_rounded,
                  AppColors.accent,
                  isDark,
                ),
                _buildModernStatCard(
                  context,
                  'Taxa Conclusão',
                  '${stats['completionRate']}%',
                  Icons.trending_up_rounded,
                  const Color(0xFF00BCD4),
                  isDark,
                ),
              ],
            );
          },
        ),
        
        // Average Time Card
        if (stats['averageCompletionTime'] != null) ...[
          SizedBox(height: AppSpacing.lg),
          GlassCard(
            elevation: 2,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF5C6BC0).withValues(alpha: 0.1),
                    const Color(0xFF7E57C2).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: AppBorderRadius.radiusMD,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)],
                      ),
                      borderRadius: AppBorderRadius.radiusMD,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5C6BC0).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.timer_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tempo Médio de Conclusão',
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          _formatDuration(stats['averageCompletionTime'] as Duration),
                          style: AppTypography.h4.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.radiusSM,
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: const Color(0xFF5C6BC0),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1400) return 6;
    if (width > 1024) return 4;
    if (width > 768) return 3;
    if (width > 640) return 2;
    return 1;
  }

  Widget _buildModernStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return GlassCard(
      elevation: 2,
      isHoverable: true,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: AppBorderRadius.radiusMD,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: AppBorderRadius.radiusMD,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTypography.h4.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}