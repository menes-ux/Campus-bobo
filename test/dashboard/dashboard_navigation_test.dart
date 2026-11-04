import 'dart:async';

import 'package:campus_bobo/app.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:campus_bobo/features/profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_incident_repository.dart';
import '../helpers/fake_user_profile_repository.dart';
import '../helpers/incident_fixtures.dart';

class _LiveProfiles extends FakeUserProfileRepository {
  final changes = StreamController<UserProfile>.broadcast(sync: true);

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    yield profiles[uid];
    yield* changes.stream;
  }
}

Future<void> _reveal(
  WidgetTester tester,
  Finder finder, {
  double delta = 250,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}

void main() {
  Future<void> openDashboard(
    WidgetTester tester, {
    bool staff = false,
    FakeUserProfileRepository? profiles,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = FakeAuthRepository(
      const AuthUser(
        uid: 'student-1',
        email: 'student@alustudent.com',
        displayName: 'Campus Student',
        emailVerified: true,
      ),
    );
    final incidents = FakeIncidentRepository()..reports = incidentFixtures();
    addTearDown(auth.close);
    addTearDown(incidents.close);
    final profileRepository = profiles ?? FakeUserProfileRepository();
    if (staff) {
      profileRepository.profiles['student-1'] = const UserProfile(
        uid: 'student-1',
        email: 'student@alustudent.com',
        displayName: 'Campus Staff',
        role: UserRole.staff,
      );
    }
    await tester.pumpWidget(
      CampusBoboApp(
        authRepository: auth,
        userProfileRepository: profileRepository,
        incidentRepository: incidents,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Dashboard summary cards open the matching personal report filter',
    (tester) async {
      await openDashboard(tester);
      expect(find.text('Hello, Campus.'), findsOneWidget);
      final total = find.byKey(const ValueKey('dashboard-total'));
      await _reveal(tester, total);
      expect(
        find.descendant(of: total, matching: find.text('2')),
        findsOneWidget,
      );
      final resolved = find.byKey(const ValueKey('dashboard-resolved'));
      await _reveal(tester, resolved);
      await tester.tap(resolved);
      await tester.pumpAndSettle();
      expect(find.text('Campus reports'), findsOneWidget);
      expect(find.text('1 report'), findsOneWidget);
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'My reports'))
            .selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Report action returns home and Profile opens the saved account',
    (tester) async {
      await openDashboard(tester);
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      expect(find.text('Report an incident'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Hello, Campus.'), findsOneWidget);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Role: Student'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Staff dashboard opens campus status filters without submission actions',
    (tester) async {
      await openDashboard(tester, staff: true);
      expect(find.text('Staff dashboard'), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(find.text('Report'), findsNothing);
      expect(find.text('Report an incident'), findsNothing);
      expect(find.text('Your report summary'), findsNothing);

      final total = find.byKey(const ValueKey('dashboard-total'));
      await _reveal(tester, total);
      expect(
        find.descendant(of: total, matching: find.text('3')),
        findsOneWidget,
      );
      final progress = find.byKey(const ValueKey('dashboard-progress'));
      await _reveal(tester, progress);
      await tester.tap(progress);
      await tester.pumpAndSettle();
      expect(find.text('Review reports'), findsOneWidget);
      expect(find.text('1 report'), findsOneWidget);
      expect(find.text('My reports'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      await _reveal(tester, find.text('Broken chair'));
      expect(find.text('Broken chair'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Role: Staff'), findsOneWidget);
      expect(find.text('Report an incident'), findsNothing);
      expect(find.text('Reporting guide'), findsNothing);
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      await _reveal(tester, find.text('Staff dashboard'), delta: -250);
      expect(find.text('Staff dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Staff review queue opens the report without owner editing actions',
    (tester) async {
      await openDashboard(tester, staff: true);
      await _reveal(tester, find.text('Reports to review'));
      expect(find.text('Water shortage'), findsNothing);
      await _reveal(tester, find.text('Leaking tap'));
      await tester.tap(find.text('Leaking tap'));
      await tester.pumpAndSettle();
      expect(find.text('Report details'), findsOneWidget);
      expect(find.text('Edit report'), findsNothing);
      expect(find.text('Delete report'), findsNothing);
      await _reveal(tester, find.text('Mark in progress'));
      expect(find.text('Staff review'), findsOneWidget);
      await tester.tap(find.text('Mark in progress'));
      await tester.pumpAndSettle();
      expect(find.text('Mark resolved'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Changing the saved role resets staff navigation and restores student reporting',
    (tester) async {
      final profiles = _LiveProfiles();
      addTearDown(profiles.changes.close);
      await openDashboard(tester, staff: true, profiles: profiles);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      profiles.changes.add(
        const UserProfile(
          uid: 'student-1',
          email: 'student@alustudent.com',
          displayName: 'Campus Student',
          role: UserRole.student,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello, Campus.'), findsOneWidget);
      expect(find.text('Staff dashboard'), findsNothing);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      expect(find.text('Report an incident'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
