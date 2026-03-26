// Validation utilities
class Validator {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email requis';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Email invalide';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Mot de passe requis';
    }
    if (value!.length < 6) {
      return 'Minimum 6 caractères';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Téléphone requis';
    }
    if (value!.length < 9) {
      return 'Numéro invalide';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value?.isEmpty ?? true) {
      return '$fieldName requis';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Prix requis';
    }
    if (double.tryParse(value!) == null) {
      return 'Prix invalide';
    }
    return null;
  }
}
