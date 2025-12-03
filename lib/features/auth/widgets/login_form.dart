// features/auth/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';
import 'package:itasks/core/widgets/custom_snackbar.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/features/auth/providers/login_provider.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/theme/app_colors.dart';
import 'package:itasks/core/theme/app_typography.dart';
import 'package:itasks/core/theme/app_dimensions.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loginProvider = context.read<LoginProvider>();
    await loginProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    await showDialog(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: AppBorderRadius.radiusSM,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      'Recuperar Password',
                      style: AppTypography.h4.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'Introduza o email da conta para receber um link de recuperação de password.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                CustomTextField(
                  controller: emailController,
                  label: 'Email',
                  hintText: 'exemplo@email.com',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: AppSpacing.xl2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      variant: ButtonVariant.text,
                      size: ButtonSize.medium,
                    ),
                    SizedBox(width: AppSpacing.md),
                    CustomButton(
                      text: 'Enviar',
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          CustomSnackBar.showError(
                            dialogContext,
                            'Por favor, insira um email válido',
                          );
                          return;
                        }
                        
                        Navigator.of(dialogContext).pop();
                        
                        final authService = context.read<AuthService>();
                        final error = await authService.sendPasswordResetEmail(
                          email: email,
                        );
                        
                        if (mounted) {
                          if (error == null) {
                            CustomSnackBar.showSuccess(
                              context,
                              'Email de recuperação enviado! Verifique a sua caixa de entrada.',
                            );
                          } else {
                            CustomSnackBar.showError(context, error);
                          }
                        }
                      },
                      variant: ButtonVariant.primary,
                      size: ButtonSize.medium,
                      icon: Icons.send_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      elevation: 2,
      isHoverable: false,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl3),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo de volta',
                    style: AppTypography.h2.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Inicie sessão para continuar',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.xl3),

              // Email Field
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'exemplo@email.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o seu email';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: AppSpacing.xl),

              // Password Field
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: '••••••••',
                icon: Icons.lock_rounded,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a sua password';
                  }
                  if (value.length < 6) {
                    return 'A password deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppSpacing.md),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: _showForgotPasswordDialog,
                  borderRadius: AppBorderRadius.radiusSM,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      'Esqueceu a password?',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.xl3),

              // Login Button
              CustomButton(
                text: 'Iniciar Sessão',
                onPressed: _submitLogin,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                isFullWidth: true,
                isLoading: loginProvider.state == LoginState.loading,
                icon: Icons.login_rounded,
              ),

              // Error Message
              if (loginProvider.state == LoginState.error &&
                  loginProvider.errorMessage != null) ...[
                SizedBox(height: AppSpacing.xl),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.radiusSM,
                    border: Border.all(
                      color: AppColors.errorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.errorColor,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          loginProvider.errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.xl2),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'iTasks',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)
                          .withValues(alpha: 0.3),
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
}
