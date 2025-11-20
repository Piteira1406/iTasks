// lib/core/utils/validators.dart

/// Validation utility functions for forms
class Validators {
  /// Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  /// Password validation (min 6 chars, letters + numbers)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password é obrigatória';
    }
    if (value.length < 6) {
      return 'Password deve ter pelo menos 6 caracteres';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Password deve conter letras e números';
    }
    return null;
  }

  /// Required field validation
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  /// Positive number validation
  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    final number = int.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName deve ser maior que 0';
    }
    return null;
  }

  /// Dropdown required validation
  static String? dropdown(dynamic value, String fieldName) {
    if (value == null) {
      return 'Selecione $fieldName';
    }
    return null;
  }
}
