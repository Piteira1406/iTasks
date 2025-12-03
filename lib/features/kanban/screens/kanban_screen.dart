import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/features/kanban/providers/kanban_provider.dart';
import 'package:itasks/features/kanban/widgets/kanban_card_widget.dart';
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';
import 'package:itasks/core/providers/theme_provider.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';
import 'package:itasks/core/widgets/custom_button.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KanbanProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppBorderRadius.radiusSM,
                boxShadow: AppShadows.shadowPrimary,
              ),
              child: const Icon(
                Icons.dashboard_customize_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              'Kanban Board',
              style: AppTypography.h4.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
            .withValues(alpha: 0.8),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppBorderRadius.radiusSM,
                  boxShadow: AppShadows.shadowPrimary,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const TaskDetailsScreen(task: null, isReadOnly: false),
                    transitionDuration: const Duration(milliseconds: 400),
                    reverseTransitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      );
                      return ScaleTransition(
                        scale: scaleAnimation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: _buildGlassDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(child: _buildKanbanBody()),
      ),
    );
  }

  Widget _buildKanbanBody() {
    return Consumer<KanbanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use implementação nativa para Web, drag_and_drop_lists para mobile
        if (kIsWeb) {
          return _buildWebKanban(context, provider);
        } else {
          return _buildMobileKanban(context, provider);
        }
      },
    );
  }

  /// Implementação Web usando Draggable/DragTarget nativo
  Widget _buildWebKanban(BuildContext context, KanbanProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isReadOnly = (authProvider.appUser?.type == 'Programador');

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 640;
        final isTablet = width >= 640 && width < 1024;

        return Column(
          children: [
            if (provider.errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.red.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(10),
                child: Text(
                  provider.errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Expanded(
              child: isMobile
                  ? _buildMobileColumnsLayout(context, provider, isReadOnly)
                  : _buildDesktopColumnsLayout(context, provider, isReadOnly, isTablet),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileColumnsLayout(BuildContext context, KanbanProvider provider, bool isReadOnly) {
    return PageView(
      children: [
        _buildWebColumn(context, "A Fazer", provider.todoTasks, 0, isReadOnly, provider),
        _buildWebColumn(context, "Em Execução", provider.doingTasks, 1, isReadOnly, provider),
        _buildWebColumn(context, "Concluído", provider.doneTasks, 2, isReadOnly, provider),
      ],
    );
  }

  Widget _buildDesktopColumnsLayout(BuildContext context, KanbanProvider provider, bool isReadOnly, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildWebColumn(
            context,
            "A Fazer",
            provider.todoTasks,
            0,
            isReadOnly,
            provider,
          ),
        ),
        Expanded(
          child: _buildWebColumn(
            context,
            "Em Execução",
            provider.doingTasks,
            1,
            isReadOnly,
            provider,
          ),
        ),
        Expanded(
          child: _buildWebColumn(
            context,
            "Concluído",
            provider.doneTasks,
            2,
            isReadOnly,
            provider,
          ),
        ),
      ],
    );
  }

  Widget _buildWebColumn(
    BuildContext context,
    String title,
    List<Task> tasks,
    int columnIndex,
    bool isReadOnly,
    KanbanProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color getColumnColor() {
      switch (columnIndex) {
        case 0:
          return AppColors.todoColor;
        case 1:
          return AppColors.doingColor;
        case 2:
          return AppColors.doneColor;
        default:
          return AppColors.primary;
      }
    }

    IconData getColumnIcon() {
      switch (columnIndex) {
        case 0:
          return Icons.list_alt_rounded;
        case 1:
          return Icons.autorenew_rounded;
        case 2:
          return Icons.check_circle_rounded;
        default:
          return Icons.list_alt_rounded;
      }
    }

    final columnColor = getColumnColor();

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => !isReadOnly,
      onAcceptWithDetails: (details) {
        final data = details.data;
        final oldColumnIndex = data['columnIndex'] as int;
        final oldItemIndex = data['itemIndex'] as int;
        final newItemIndex = tasks.length;
        
        provider.handleTaskMove(
          oldItemIndex,
          oldColumnIndex,
          newItemIndex,
          columnIndex,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final bool isOver = candidateData.isNotEmpty;
        
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: isOver
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      columnColor.withValues(alpha: 0.15),
                      columnColor.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            borderRadius: AppBorderRadius.radiusLG,
            border: Border.all(
              color: isOver
                  ? columnColor
                  : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)
                      .withValues(alpha: 0.1),
              width: isOver ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Modern Header
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      columnColor.withValues(alpha: 0.2),
                      columnColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: AppBorderRadius.radiusLG.topLeft,
                    topRight: AppBorderRadius.radiusLG.topRight,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: columnColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: columnColor.withValues(alpha: 0.2),
                        borderRadius: AppBorderRadius.radiusSM,
                      ),
                      child: Icon(
                        getColumnIcon(),
                        size: 20,
                        color: columnColor,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.h5.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: columnColor.withValues(alpha: 0.2),
                        borderRadius: AppBorderRadius.radiusFull,
                        border: Border.all(
                          color: columnColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: AppTypography.labelMedium.copyWith(
                          color: columnColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tasks
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 48,
                              color: (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary)
                                  .withValues(alpha: 0.3),
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Sem tarefas',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final canDrag =
                              task.taskStatus != 'Done' && !isReadOnly;
                          
                          if (canDrag) {
                            return Draggable<Map<String, dynamic>>(
                              data: {
                                'task': task,
                                'columnIndex': columnIndex,
                                'itemIndex': index,
                              },
                              feedback: Material(
                                elevation: 8,
                                color: Colors.transparent,
                                borderRadius: AppBorderRadius.radiusMD,
                                child: Container(
                                  width: 300,
                                  child: Opacity(
                                    opacity: 0.9,
                                    child: KanbanCardWidget(
                                      task: task,
                                      isReadOnly: isReadOnly,
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: KanbanCardWidget(
                                  key: ValueKey(task.id),
                                  task: task,
                                  isReadOnly: isReadOnly,
                                ),
                              ),
                              child: KanbanCardWidget(
                                key: ValueKey(task.id),
                                task: task,
                                isReadOnly: isReadOnly,
                              ),
                            );
                          } else {
                            return KanbanCardWidget(
                              key: ValueKey(task.id),
                              task: task,
                              isReadOnly: isReadOnly,
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Implementação Mobile usando drag_and_drop_lists
  Widget _buildMobileKanban(BuildContext context, KanbanProvider provider) {
    final List<DragAndDropList> kanbanLists = [
      _buildDragList(context, "A Fazer", provider.todoTasks),
      _buildDragList(context, "Em Execução", provider.doingTasks),
      _buildDragList(context, "Concluído", provider.doneTasks),
    ];

    return Column(
      children: [
        if (provider.errorMessage.isNotEmpty)
          Container(
            width: double.infinity,
            color: Colors.red.withValues(alpha: 0.8),
            padding: const EdgeInsets.all(10),
            child: Text(
              provider.errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        Expanded(
          child: DragAndDropLists(
            children: kanbanLists,
            axis: Axis.horizontal,
            listWidth: 340, // Colunas ligeiramente mais largas
            listDraggingWidth: 340,
            listPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),

            // Removemos decorações globais para personalizar cada lista
            onItemReorder: (oldItem, oldList, newItem, newList) {
              provider.handleTaskMove(oldItem, oldList, newItem, newList);
            },
            onListReorder: (_, __) {},
          ),
        ),
      ],
    );
  }

  /// Reconstrói o cabeçalho com efeito Glass manual
  DragAndDropList _buildDragList(
    BuildContext context,
    String title,
    List<Task> tasks,
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isReadOnly = (authProvider.appUser?.type == 'Programador');

    return DragAndDropList(
      // AQUI ESTÁ O TRUQUE: O Header é um Container com estilo Glass
      header: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(
          bottom: 8,
        ), // Espaço entre titulo e cartões
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).cardColor.withValues(alpha: 0.6), // Vidro fosco
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${tasks.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),

      children: tasks.map((task) {
        return DragAndDropItem(
          child: KanbanCardWidget(
            key: ValueKey(task.id),
            task: task,
            isReadOnly: isReadOnly,
          ),
          canDrag: task.taskStatus != 'Done',
        );
      }).toList(),
    );
  }

  /// Modern Navigation Drawer
  Widget _buildGlassDrawer(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.appUser;
    final isManager = user?.type == 'Manager';

    return Drawer(
      width: 300,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                  .withValues(alpha: 0.9),
              border: Border(
                right: BorderSide(
                  color: (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)
                      .withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Modern Gradient Header
                Container(
                  padding: EdgeInsets.all(AppSpacing.xl2),
                  decoration: BoxDecoration(
                    gradient: isManager
                        ? AppColors.accentGradient
                        : AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (isManager
                                ? AppColors.accent
                                : AppColors.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with gradient border
                        Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppBorderRadius.radiusFull,
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: AppTypography.h3.copyWith(
                                color: isManager
                                    ? AppColors.accent
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        
                        // User Info
                        Text(
                          user?.name ?? "Utilizador",
                          style: AppTypography.h5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppBorderRadius.radiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isManager
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.code_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                user?.type ?? "Convidado",
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    children: [
                      // Theme Toggle
                      _buildModernTile(
                        context: context,
                        icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        title: 'Tema',
                        subtitle: isDark ? 'Modo Escuro' : 'Modo Claro',
                        trailing: Switch(
                          value: isDark,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => themeProvider.toggleTheme(val),
                        ),
                        isDark: isDark,
                      ),
                      
                      SizedBox(height: AppSpacing.sm),
                      
                      // Manager Menu
                      if (isManager) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            'GESTÃO',
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        _buildModernNavTile(
                          context: context,
                          icon: Icons.category_rounded,
                          title: 'Tipos de Tarefa',
                          route: '/task_types',
                          color: const Color(0xFFFF6B6B),
                          isDark: isDark,
                        ),
                        _buildModernNavTile(
                          context: context,
                          icon: Icons.people_rounded,
                          title: 'Utilizadores',
                          route: '/user_management',
                          color: const Color(0xFF4ECDC4),
                          isDark: isDark,
                        ),
                        _buildModernNavTile(
                          context: context,
                          icon: Icons.analytics_rounded,
                          title: 'Relatórios',
                          route: '/reports',
                          color: AppColors.accent,
                          isDark: isDark,
                        ),
                        SizedBox(height: AppSpacing.sm),
                      ],
                      
                      // Kanban Link
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          'NAVEGAÇÃO',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      _buildModernNavTile(
                        context: context,
                        icon: Icons.dashboard_customize_rounded,
                        title: 'Kanban Board',
                        route: '/kanban',
                        color: AppColors.primary,
                        isDark: isDark,
                        isActive: true,
                      ),
                    ],
                  ),
                ),

                // Logout Button
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary)
                            .withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: CustomButton(
                    text: 'Sair',
                    onPressed: () {
                      Navigator.pop(context);
                      authProvider.signOut();
                    },
                    variant: ButtonVariant.danger,
                    size: ButtonSize.medium,
                    isFullWidth: true,
                    icon: Icons.logout_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
            .withValues(alpha: 0.5),
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppBorderRadius.radiusSM,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }

  Widget _buildModernNavTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required Color color,
    required bool isDark,
    bool isActive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              )
            : null,
        borderRadius: AppBorderRadius.radiusMD,
        border: isActive
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isActive ? 0.2 : 0.1),
            borderRadius: AppBorderRadius.radiusSM,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            color: isActive
                ? color
                : isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: isActive
            ? Icon(Icons.chevron_right_rounded, color: color, size: 20)
            : null,
        onTap: () {
          Navigator.pop(context);
          if (!isActive) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
