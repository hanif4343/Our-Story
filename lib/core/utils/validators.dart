import '../constants/app_constants.dart';

/// Shared form-field validators used by Creator Mode editors.
class Validators {
  Validators._();

  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters.';
    }
    return null;
  }

  static String? sceneOrder(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) return 'Order must be a positive number.';
    return null;
  }
}
