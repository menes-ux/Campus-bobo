import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/auth_user.dart';
import '../../auth/domain/auth_validators.dart';
import '../domain/user_profile.dart';
import '../domain/user_profile_repository.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> ensureProfile(AuthUser user) async {
    if (!user.emailVerified || !AuthValidators.isStudentEmail(user.email)) {
      throw StateError('A verified ALU student account is required.');
    }
    final reference = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      if (existing.exists) return;

      var name = user.displayName?.trim() ?? '';
      if (name.length < 2) name = 'ALU student';
      if (name.length > 80) name = name.substring(0, 80);
      transaction.set(reference, {
        'email': user.email,
        'displayName': name,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return UserProfile(
        uid: snapshot.id,
        email: data['email'] as String,
        displayName: data['displayName'] as String,
        role: UserRole.parse(data['role']),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    });
  }
}
