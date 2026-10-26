import 'package:campus_bobo/app.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_incident_repository.dart';
import '../helpers/fake_user_profile_repository.dart';
import '../helpers/incident_fixtures.dart';

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
  late FakeAuthRepository auth;
  late FakeIncidentRepository incidents;

  setUp(() {
    auth = FakeAuthRepository(
      const AuthUser(
        uid: 'student-1',
        email: 'student@alustudent.com',
        displayName: 'Campus Student',
        emailVerified: true,
      ),
    );
    incidents = FakeIncidentRepository()..reports = incidentFixtures();
  });

  tearDown(() async {
    await auth.close();
    await incidents.close();
  });

  Future<void> openReports(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      CampusBoboApp(
        authRepository: auth,
        userProfileRepository: FakeUserProfileRepository(),
        incidentRepository: incidents,
      ),
    );
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('Browse reports'));
    await tester.tap(find.text('Browse reports'));
    await tester.pumpAndSettle();
  }

  testWidgets('Search and status filtering narrow the list and can be reset', (
    tester,
  ) async {
    await openReports(tester);
    expect(find.text('3 reports'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('report-search')),
      'washroom',
    );
    await tester.pumpAndSettle();
    expect(find.text('1 report'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('report-status-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resolved').last);
    await tester.pumpAndSettle();
    expect(find.text('1 report'), findsOneWidget);
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('3 reports'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A saved report opens its details and is hidden after sign out', (
    tester,
  ) async {
    await openReports(tester);
    await _reveal(tester, find.text('Leaking tap'));
    await tester.tap(find.text('Leaking tap'));
    await tester.pumpAndSettle();
    expect(find.text('Report details'), findsOneWidget);
    expect(
      find.text('The tap beside the entrance keeps leaking.'),
      findsOneWidget,
    );
    incidents.emitReports([]);
    await tester.pumpAndSettle();
    expect(find.text('Report unavailable'), findsOneWidget);
    auth.emitUser(null);
    await tester.pumpAndSettle();
    expect(find.text('Report unavailable'), findsNothing);
    expect(find.text('Please sign in again to view reports.'), findsOneWidget);
  });
}
