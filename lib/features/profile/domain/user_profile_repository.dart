import '../../auth/domain/auth_user.dart';
import 'user_profile.dart';

abstract interface class UserProfileRepository {
  Future<void> ensureProfile(AuthUser user);
  Stream<UserProfile?> watchProfile(String uid);
}
