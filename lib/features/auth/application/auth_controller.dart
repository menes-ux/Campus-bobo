import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/auth_validators.dart';

enum AuthSession { loading, signedOut, unverified, verified, unsupportedEmail }

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _subscription = _repository.userChanges.listen(
      _onUserChanged,
      onError: (Object error) {
        _initializing = false;
        _error = 'We could not restore your session. Please sign in again.';
        _notify();
      },
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthUser?> _subscription;
  Timer? _cooldownTimer;
  DateTime? _verificationSentAt;
  AuthUser? _user;
  bool _initializing = true;
  bool _busy = false;
  bool _disposed = false;
  String? _error;
  String? _message;

  AuthUser? get user => _user;
  bool get isBusy => _busy;
  String? get error => _error;
  String? get message => _message;

  AuthSession get session {
    if (_initializing) return AuthSession.loading;
    if (_user == null) return AuthSession.signedOut;
    if (!AuthValidators.isStudentEmail(_user!.email)) {
      return AuthSession.unsupportedEmail;
    }
    return _user!.emailVerified ? AuthSession.verified : AuthSession.unverified;
  }

  int get resendSeconds {
    final sentAt = _verificationSentAt;
    if (sentAt == null) return 0;
    return (60 - DateTime.now().difference(sentAt).inSeconds).clamp(0, 60);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _onUserChanged(AuthUser? user) {
    if (_user?.uid != user?.uid) {
      _cooldownTimer?.cancel();
      _verificationSentAt = null;
      _message = null;
    }
    _user = user;
    _initializing = false;
    _notify();
  }

  void clearFeedback() {
    _error = null;
    _message = null;
    _notify();
  }

  Future<bool> _perform(Future<void> Function() action) async {
    if (_busy || _disposed) return false;
    _busy = true;
    _error = null;
    _message = null;
    _notify();
    try {
      await action();
      return true;
    } on AuthFailure catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      _notify();
    }
  }

  void _requireStudentEmail(String email) {
    final validation = AuthValidators.studentEmail(email);
    if (validation != null) throw AuthFailure(validation);
  }

  Future<bool> register(String name, String email, String password) =>
      _perform(() async {
        _requireStudentEmail(email);
        final validation =
            AuthValidators.displayName(name) ??
            AuthValidators.newPassword(password);
        if (validation != null) throw AuthFailure(validation);
        await _repository.register(
          name.trim(),
          AuthValidators.normalizeEmail(email),
          password,
        );
        _onUserChanged(_repository.currentUser);
        await _sendVerification();
      });

  Future<bool> signIn(String email, String password) => _perform(() async {
    _requireStudentEmail(email);
    final validation = AuthValidators.loginPassword(password);
    if (validation != null) throw AuthFailure(validation);
    await _repository.signIn(AuthValidators.normalizeEmail(email), password);
    _onUserChanged(_repository.currentUser);
  });

  Future<void> _sendVerification() async {
    await _repository.sendVerification();
    if (_disposed) return;
    _verificationSentAt = DateTime.now();
    _message = 'Verification email sent. Check your inbox and spam folder.';
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) timer.cancel();
      _notify();
    });
  }

  Future<bool> resendVerification() async {
    if (session != AuthSession.unverified || resendSeconds > 0) return false;
    return _perform(_sendVerification);
  }

  Future<bool> refreshVerification() => _perform(() async {
    await _repository.reloadUser();
    _onUserChanged(_repository.currentUser);
    if (session == AuthSession.unverified) {
      _message = 'Your email is not verified yet. Open the link in your inbox, then check again.';
    }
  });

  Future<bool> signOut() => _perform(() async {
    await _repository.signOut();
    _onUserChanged(null);
  });

  @override
  void dispose() {
    _disposed = true;
    _cooldownTimer?.cancel();
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
