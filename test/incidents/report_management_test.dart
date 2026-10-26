import 'package:campus_bobo/app.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:campus_bobo/features/incidents/domain/incident_repository.dart';
import 'package:campus_bobo/features/incidents/domain/incident_status.dart';
import 'package:campus_bobo/features/profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_incident_repository.dart';
import '../helpers/fake_user_profile_repository.dart';
import '../helpers/incident_fixtures.dart';

void main() {
  late FakeIncidentRepository incidents;

  setUp(() => incidents = FakeIncidentRepository()..reports = incidentFixtures());
  tearDown(() => incidents.close());

  Future<void> openDetails(
    WidgetTester tester, {
    bool staff = false,
    String title = 'Leaking tap',
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
    addTearDown(auth.close);
    final profiles = FakeUserProfileRepository();
    if (staff) {
      profiles.profiles['student-1'] = const UserProfile(
        uid: 'student-1',
        email: 'student@alustudent.com',
        displayName: 'Campus Staff',
        role: UserRole.staff,
      );
    }
    await tester.pumpWidget(
      CampusBoboApp(
        authRepository: auth,
        userProfileRepository: profiles,
        incidentRepository: incidents,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(title),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text(title)),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
    expect(find.text('Report details'), findsOneWidget);
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
    await tester.pumpAndSettle();
  }

  testWidgets('Owner edits a submitted report and the details update', (
    tester,
  ) async {
    await openDetails(tester);
    await reveal(tester, find.text('Edit report'));
    await tester.tap(find.text('Edit report'));
    await tester.pumpAndSettle();
    expect(find.text('Leaking tap'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('incident-title')),
      'Leaking tap near stairs',
    );
    await reveal(tester, find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(incidents.updateCalls, 1);
    expect(find.text('Report details'), findsOneWidget);
    expect(find.text('Leaking tap near stairs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Deletion requires confirmation and updates the dashboard', (
    tester,
  ) async {
    await openDetails(tester);
    await reveal(tester, find.text('Delete report'));
    await tester.tap(find.text('Delete report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(incidents.deleteCalls, 0);
    await tester.tap(find.text('Delete report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(incidents.deleteCalls, 1);
    expect(find.text('Report details'), findsNothing);
    expect(incidents.reports.any((report) => report.id == 'water-1'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Student cannot see staff actions or edit another report', (
    tester,
  ) async {
    await openDetails(tester, title: 'Broken chair');
    expect(find.text('Edit report'), findsNothing);
    expect(find.text('Delete report'), findsNothing);
    expect(find.text('Staff review'), findsNothing);
  });

  testWidgets('Staff advances status and sees the persisted result', (
    tester,
  ) async {
    await openDetails(tester, staff: true);
    await reveal(tester, find.text('Mark in progress'));
    await tester.tap(find.text('Mark in progress'));
    await tester.pumpAndSettle();
    expect(incidents.reports.first.status, IncidentStatus.inProgress);
    expect(find.text('Edit report'), findsNothing);
    await reveal(tester, find.text('Mark resolved'));
    await tester.tap(find.text('Mark resolved'));
    await tester.pumpAndSettle();
    expect(incidents.reports.first.status, IncidentStatus.resolved);
    expect(incidents.statusCalls, 2);
    expect(find.text('This report has been resolved.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A denied staff update leaves the current status intact', (
    tester,
  ) async {
    incidents.failure = const IncidentFailure(
      'You do not have permission for this action.',
    );
    await openDetails(tester, staff: true);
    await reveal(tester, find.text('Mark in progress'));
    await tester.tap(find.text('Mark in progress'));
    await tester.pumpAndSettle();
    expect(incidents.reports.first.status, IncidentStatus.submitted);
    expect(
      find.text('You do not have permission for this action.'),
      findsOneWidget,
    );
  });
}
