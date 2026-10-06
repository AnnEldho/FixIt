/// Reusable form validators. Each returns `null` when the value is valid.
class Validators {
  Validators._();

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required';
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != original()) return 'Passwords do not match';
      return null;
    };
  }

  static String? Function(String?) required(String field) {
    return (value) {
      if (value == null || value.trim().isEmpty) return '$field is required';
      return null;
    };
  }

  static String? Function(String?) minLength(int length, String field) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return '$field is required';
      if (text.length < length) {
        return '$field must be at least $length characters';
      }
      return null;
    };
  }
}
