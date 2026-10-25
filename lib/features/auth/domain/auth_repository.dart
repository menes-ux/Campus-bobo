import 'auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> get userChanges;

  Future<void> register(String name, String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> sendVerification();
  Future<void> reloadUser();
  Future<void> signOut();
}
