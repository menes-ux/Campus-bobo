import 'dart:async';

import 'package:campus_bobo/features/auth/domain/auth_failure.dart';
import 'package:campus_bobo/features/auth/domain/auth_repository.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository([this._user]);

  AuthUser? _user;
  final _changes = StreamController<AuthUser?>.broadcast(sync: true);
  AuthFailure? nextFailure;
  AuthFailure? verificationFailure;
  Completer<void>? signInCompleter;
  bool verifyOnReload = false;
  int signInCalls = 0;
  int registerCalls = 0;
  int verificationCalls = 0;
  String? submittedEmail;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get userChanges async* {
    yield _user;
    yield* _changes.stream;
  }

  void emitUser(AuthUser? user) {
    _user = user;
    _changes.add(user);
  }

  void _checkFailure() {
    final failure = nextFailure;
    nextFailure = null;
    if (failure != null) throw failure;
  }

  @override
  Future<void> register(String name, String email, String password) async {
    registerCalls++;
    _checkFailure();
    submittedEmail = email;
    emitUser(
      AuthUser(
        uid: 'student-1',
        email: email,
        displayName: name,
        emailVerified: false,
      ),
    );
  }

  @override
  Future<void> signIn(String email, String password) async {
    signInCalls++;
    await signInCompleter?.future;
    _checkFailure();
    submittedEmail = email;
    emitUser(
      AuthUser(
        uid: 'student-1',
        email: email,
        displayName: 'Campus Student',
        emailVerified: false,
      ),
    );
  }

  @override
  Future<void> sendVerification() async {
    verificationCalls++;
    _checkFailure();
    if (verificationFailure != null) throw verificationFailure!;
  }

  @override
  Future<void> reloadUser() async {
    _checkFailure();
    if (verifyOnReload && _user != null) {
      emitUser(
        AuthUser(
          uid: _user!.uid,
          email: _user!.email,
          displayName: _user!.displayName,
          emailVerified: true,
        ),
      );
    }
  }

  @override
  Future<void> signOut() async {
    _checkFailure();
    emitUser(null);
  }

  Future<void> close() => _changes.close();
}
