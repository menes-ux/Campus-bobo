abstract final class AuthValidators {
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static bool isStudentEmail(String email) {
    final normalized = normalizeEmail(email);
    final parts = normalized.split('@');
    if (parts.length != 2 || parts.last != 'alustudent.com') return false;
    final local = parts.first;
    return RegExp(r'^[a-z0-9._%+\-]+$').hasMatch(local) &&
        !local.startsWith('.') &&
        !local.endsWith('.') &&
        !local.contains('..');
  }

  static String? studentEmail(String? value) => isStudentEmail(value ?? '')
      ? null
      : 'Use your @alustudent.com email address.';

  static String? displayName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2) return 'Enter your name (at least 2 characters).';
    if (name.length > 80) return 'Keep your name under 80 characters.';
    return null;
  }

  static String? loginPassword(String? value) =>
      (value ?? '').isEmpty ? 'Enter your password.' : null;

  static String? newPassword(String? value) =>
      (value ?? '').length < 8 ? 'Use at least 8 characters.' : null;

  static String? confirmPassword(String? value, String password) =>
      value == password ? null : 'Your passwords do not match.';
}
