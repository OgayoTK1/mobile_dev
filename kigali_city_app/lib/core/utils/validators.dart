class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    ).hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? latitude(String? value) {
    if (value == null || value.isEmpty) return null;
    final n = double.tryParse(value);
    if (n == null || n < -90 || n > 90)
      return 'Enter a valid latitude (-90 to 90)';
    return null;
  }

  static String? longitude(String? value) {
    if (value == null || value.isEmpty) return null;
    final n = double.tryParse(value);
    if (n == null || n < -180 || n > 180)
      return 'Enter a valid longitude (-180 to 180)';
    return null;
  }
}
