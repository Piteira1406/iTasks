// lib/features/kanban/widgets/kanban_card_widget.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';

class KanbanCardWidget extends StatefulWidget {
  final Task task;
  final bool isReadOnly;

  const KanbanCardWidget({
    super.key,
    required this.task,
    required this.isReadOnly,
  });

  @override
  State<KanbanCardWidget> createState() => _KanbanCardWidgetState();
}

class _KanbanCardWidgetState extends State<KanbanCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TaskDetailsScreen(task: widget.task, isReadOnly: widget.isReadOnly),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(
            tween.chain(CurveTween(curve: Curves.easeOutCubic)),
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.task.taskStatus) {
      case 'ToDo':
        return AppColors.todoColor;
      case 'Doing':
        return AppColors.doingColor;
      case 'Done':
        return AppColors.doneColor;
      default:
        return AppColors.todoColor;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.task.taskStatus) {
      case 'ToDo':
        return Icons.radio_button_unchecked_rounded;
      case 'Doing':
        return Icons.pending_rounded;
      case 'Done':
        return Icons.check_circle_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  Color _getPriorityColor() {
    if (widget.task.storyPoints >= 13) {
      return AppColors.priorityCritical;
    } else if (widget.task.storyPoints >= 8) {
      return AppColors.priorityHigh;
    } else if (widget.task.storyPoints >= 5) {
      return AppColors.priorityMedium;
    } else {
      return AppColors.priorityLow;
    }
  }

  String _getPriorityLabel() {
    if (widget.task.storyPoints >= 13) {
      return 'Crítica';
    } else if (widget.task.storyPoints >= 8) {
      return 'Alta';
    } else if (widget.task.storyPoints >= 5) {
      return 'Média';
    } else {
      return 'Baixa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: GlassCard(
            elevation: _isHovered ? 4 : 2,
            isHoverable: false,
            child: InkWell(
              onTap: () => _navigateToDetails(context),
              borderRadius: AppBorderRadius.radiusMD,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: statusColor,
                      width: 4,
                    ),
                  ),
                  borderRadius: AppBorderRadius.radiusMD,
                ),
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row - Status Icon & Priority Badge
                    Row(
                      children: [
                        // Status Icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: AppBorderRadius.radiusSM,
                          ),
                          child: Icon(
                            _getStatusIcon(),
                            size: 18,
                            color: statusColor,
                          ),
                        ),
                        const Spacer(),
                        // Priority Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor().withValues(alpha: 0.15),
                            borderRadius: AppBorderRadius.radiusSM,
                            border: Border.all(
                              color: _getPriorityColor().withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                size: 12,
                                color: _getPriorityColor(),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                _getPriorityLabel(),
                                style: AppTypography.caption.copyWith(
                                  color: _getPriorityColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Task Description
                    Text(
                      widget.task.description,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Task Type Chip
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.2),
                            AppColors.accentLight.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: AppBorderRadius.radiusSM,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Tipo: ${widget.task.idTaskType}',
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.accentLight
                                  : AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Bottom Row - Developer & Story Points
                    Row(
                      children: [
                        // Developer Avatar
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppBorderRadius.radiusFull,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'D',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Dev: ${widget.task.idDeveloper}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                        // Story Points Badge
                        if (widget.task.storyPoints > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary)
                                  .withValues(alpha: 0.15),
                              borderRadius: AppBorderRadius.radiusSM,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  '${widget.task.storyPoints}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Date Info (if hovered)
                    if (_isHovered) ...[
                      SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface)
                              .withValues(alpha: 0.5),
                          borderRadius: AppBorderRadius.radiusSM,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Previsão: ${widget.task.previsionEndDate.day}/${widget.task.previsionEndDate.month}',
                                style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
