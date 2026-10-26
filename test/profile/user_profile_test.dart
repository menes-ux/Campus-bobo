import 'package:campus_bobo/app.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:campus_bobo/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_incident_repository.dart';
import '../helpers/fake_user_profile_repository.dart';

void main() {
  const student = AuthUser(
    uid: 'student-1',
    email: 'student@alustudent.com',
    displayName: 'Campus Student',
    emailVerified: true,
  );

  test('Unknown role values are rejected', () {
    expect(() => UserRole.parse('admin'), throwsFormatException);
    expect(() => UserRole.parse(null), throwsFormatException);
  });

  Future<void> openApp(
    WidgetTester tester,
    FakeUserProfileRepository profiles,
  ) async {
    final auth = FakeAuthRepository(student);
    final incidents = FakeIncidentRepository();
    addTearDown(auth.close);
    addTearDown(incidents.close);
    await tester.pumpWidget(
      CampusBoboApp(
        authRepository: auth,
        userProfileRepository: profiles,
        incidentRepository: incidents,
      ),
    );
    await tester.pumpAndSettle();
    if (find.text('Profile').evaluate().isNotEmpty) {
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Verified users get one student profile', (tester) async {
    final profiles = FakeUserProfileRepository();
    await openApp(tester, profiles);
    expect(find.text('Role: Student'), findsOneWidget);
    expect(profiles.profiles[student.uid]!.email, student.email);
    expect(profiles.ensureCalls, 1);
    await tester.pump();
    expect(profiles.ensureCalls, 1);
  });

  testWidgets('An assigned staff role is preserved when the account opens', (
    tester,
  ) async {
    final profiles = FakeUserProfileRepository();
    profiles.profiles[student.uid] = UserProfile(
      uid: student.uid,
      email: student.email,
      displayName: 'Campus Staff',
      role: UserRole.staff,
    );
    await openApp(tester, profiles);
    expect(find.text('Role: Staff'), findsOneWidget);
    expect(profiles.profiles[student.uid]!.role, UserRole.staff);
  });

  testWidgets('Failed profile loads offer retry before opening the account', (
    tester,
  ) async {
    final profiles = FakeUserProfileRepository()..failLoading = true;
    await openApp(tester, profiles);
    expect(find.text('Let\'s reconnect.'), findsOneWidget);
    expect(find.text('Your campus account.'), findsNothing);
    profiles.failLoading = false;
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Role: Student'), findsOneWidget);
  });
}
