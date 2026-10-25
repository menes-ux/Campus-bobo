import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  AuthUser? _mapUser(User? user) => user == null
      ? null
      : AuthUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          emailVerified: user.emailVerified,
        );

  @override
  AuthUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Stream<AuthUser?> get userChanges => _auth.userChanges().map(_mapUser);

  Future<void> _request(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromCode(error.code);
    }
  }

  @override
  Future<void> register(String name, String email, String password) =>
      _request(() async {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user!.updateDisplayName(name);
      });

  @override
  Future<void> signIn(String email, String password) => _request(() async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  });

  @override
  Future<void> sendVerification() => _request(() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure('Please sign in again.');
    await user.sendEmailVerification();
  });

  @override
  Future<void> reloadUser() => _request(() async {
    await _auth.currentUser?.reload();
    if (_auth.currentUser?.emailVerified ?? false) {
      await _auth.currentUser!.getIdToken(true);
    }
  });

  @override
  Future<void> signOut() => _request(_auth.signOut);
}
