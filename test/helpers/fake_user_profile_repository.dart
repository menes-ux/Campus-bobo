import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:campus_bobo/features/profile/domain/user_profile.dart';
import 'package:campus_bobo/features/profile/domain/user_profile_repository.dart';

class FakeUserProfileRepository implements UserProfileRepository {
  final profiles = <String, UserProfile>{};
  int ensureCalls = 0;
  bool failLoading = false;

  @override
  Future<void> ensureProfile(AuthUser user) async {
    ensureCalls++;
    if (failLoading) throw StateError('Profile unavailable.');
    profiles.putIfAbsent(
      user.uid,
      () => UserProfile(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName ?? 'ALU student',
        role: UserRole.student,
      ),
    );
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) => Stream.value(profiles[uid]);
}
