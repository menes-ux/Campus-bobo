class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  factory AuthFailure.fromCode(String code) {
    return AuthFailure(switch (code) {
      'invalid-credential' ||
      'invalid-login-credentials' ||
      'wrong-password' ||
      'user-not-found' => 'The email or password is incorrect.',
      'invalid-email' => 'Check your email address and try again.',
      'email-already-in-use' =>
        'An account already uses this email. Try signing in.',
      'weak-password' || 'password-does-not-meet-requirements' =>
        'Choose a stronger password with at least 8 characters.',
      'user-disabled' => 'This account is disabled. Contact campus support.',
      'too-many-requests' =>
        'Too many attempts. Please wait before trying again.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'operation-not-allowed' =>
        'Email/password sign-in is not enabled yet. Contact campus support.',
      'user-token-expired' || 'requires-recent-login' =>
        'Your session has expired. Please sign in again.',
      _ => 'We could not complete that request. Please try again.',
    });
  }
}
