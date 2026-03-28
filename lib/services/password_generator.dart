// lib/services/password_generator.dart
import 'dart:math';

class PasswordGenerator {
  static const String _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const String _digits = '0123456789';
  static const String _special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool useUpper = true,
    bool useLower = true,
    bool useDigits = true,
    bool useSpecial = true,
  }) {
    String chars = '';
    if (useUpper) chars += _upper;
    if (useLower) chars += _lower;
    if (useDigits) chars += _digits;
    if (useSpecial) chars += _special;
    if (chars.isEmpty) chars = _lower + _digits;

    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  static double strength(String password) {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 8) score += 0.2;
    if (password.length >= 12) score += 0.2;
    if (password.length >= 16) score += 0.1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.15;
    if (password.contains(RegExp(r'[a-z]'))) score += 0.1;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.1;
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]'))) score += 0.15;
    return score.clamp(0, 1);
  }

  static String strengthLabel(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Fair';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }
}
