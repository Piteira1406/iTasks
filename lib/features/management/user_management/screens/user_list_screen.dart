import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/core/widgets/custom_snackbar.dart';
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';
import 'package:itasks/core/widgets/staggered_list_animation.dart';
import 'package:itasks/features/management/user_management/screens/user_edit_screen.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserManagementProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToEditScreen(BuildContext context, {AppUser? user}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserEditScreen(user: user),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final offsetAnimation = animation.drive(
            Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
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

  List<AppUser> _getFilteredUsers(List<AppUser> users) {
    return users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Ajustar comparação de tipo: "Programador" no filtro = "Developer" no banco
      bool matchesType = _filterType == 'Todos';
      if (_filterType == 'Manager') {
        matchesType = user.type == 'Manager';
      } else if (_filterType == 'Developer') {
        matchesType = user.type == 'Developer';
      }
      
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                      .withValues(alpha: 0.8),
                  boxShadow: AppShadows.shadowSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppBorderRadius.radiusSM,
                            boxShadow: AppShadows.shadowPrimary,
                          ),
                          child: const Icon(
                            Icons.people_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Gestão de Utilizadores',
                            style: AppTypography.h4.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CustomButton(
                          text: 'Novo',
                          onPressed: () => _navigateToEditScreen(context),
                          variant: ButtonVariant.primary,
                          size: ButtonSize.medium,
                          icon: Icons.add_rounded,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.lg),
                    
                    // Search Bar
                    CustomTextField(
                      controller: _searchController,
                      hintText: 'Pesquisar utilizadores...',
                      icon: Icons.search_rounded,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                    
                    SizedBox(height: AppSpacing.md),
                    
                    // Filter Chips
                    Row(
                      children: [
                        _buildFilterChip('Todos', isDark),
                        SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Manager', isDark),
                        SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Developer', isDark),
                      ],
                    ),
                  ],
                ),
              ),
              
              // User List
              Expanded(
                child: Consumer<UserManagementProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Text(
                              'A carregar utilizadores...',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredUsers = _getFilteredUsers(provider.users);

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 64,
                              color: (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary)
                                  .withValues(alpha: 0.3),
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Nenhum utilizador encontrado'
                                  : 'Sem resultados para "$_searchQuery"',
                              style: AppTypography.h5.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final isMobile = width < 640;
                        final crossAxisCount = isMobile ? 1 : (width < 1024 ? 2 : 3);

                        if (isMobile) {
                          return ListView.builder(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return StaggeredListItem(
                                index: index,
                                delay: const Duration(milliseconds: 60),
                                child: _buildUserCard(context, user, isDark),
                              );
                            },
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 3.0,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return StaggeredListItem(
                              index: index,
                              delay: const Duration(milliseconds: 60),
                              child: _buildUserCard(context, user, isDark),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _filterType == label;
    
    return InkWell(
      onTap: () => setState(() => _filterType = label),
      borderRadius: AppBorderRadius.radiusFull,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                  .withValues(alpha: 0.5),
          borderRadius: AppBorderRadius.radiusFull,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)
                    .withValues(alpha: 0.2),
          ),
          boxShadow: isSelected ? AppShadows.shadowPrimary : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? Colors.white
                : isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUser user, bool isDark) {
    final isManager = user.type == 'Manager';
    final typeColor = isManager ? AppColors.accent : AppColors.primary;
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        elevation: 2,
        isHoverable: true,
        onTap: () => _navigateToEditScreen(context, user: user),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isManager
                      ? AppColors.accentGradient
                      : AppColors.primaryGradient,
                  borderRadius: AppBorderRadius.radiusMD,
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isManager
                      ? Icons.manage_accounts_rounded
                      : Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              SizedBox(width: AppSpacing.md),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.email_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            user.email,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: AppBorderRadius.radiusSM,
                        border: Border.all(
                          color: typeColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isManager ? Icons.admin_panel_settings_rounded : Icons.code_rounded,
                            size: 12,
                            color: typeColor,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            user.type,
                            style: AppTypography.caption.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () => _navigateToEditScreen(context, user: user),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.radiusSM,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_rounded,
                      color: AppColors.errorColor,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteConfirmDialog(context, user),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.errorColor.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.radiusSM,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, AppUser user) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          elevation: 4,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(AppSpacing.xl2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withValues(alpha: 0.15),
                    borderRadius: AppBorderRadius.radiusXL,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: AppColors.errorColor,
                    size: 32,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                
                // Title
                Text(
                  'Confirmar Eliminação',
                  style: AppTypography.h4.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                
                // Content
                Text(
                  'Tem certeza que deseja eliminar o utilizador "${user.name}"?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Esta ação não pode ser desfeita.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSpacing.xl2),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancelar',
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        variant: ButtonVariant.outlined,
                        size: ButtonSize.medium,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CustomButton(
                        text: 'Eliminar',
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        variant: ButtonVariant.danger,
                        size: ButtonSize.medium,
                        icon: Icons.delete_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldDelete == true && context.mounted) {
      final provider = context.read<UserManagementProvider>();
      final error = await provider.deleteUser(
        uid: user.uid,
        appUser: user,
      );

      if (context.mounted) {
        if (error == null) {
          await provider.fetchUsers();
          CustomSnackBar.showSuccess(
            context,
            'Utilizador "${user.name}" eliminado com sucesso',
          );
        } else {
          CustomSnackBar.showError(context, error);
        }
      }
    }
  }
}
