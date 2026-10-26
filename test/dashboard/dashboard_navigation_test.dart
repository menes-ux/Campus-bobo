import 'package:campus_bobo/app.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_incident_repository.dart';
import '../helpers/fake_user_profile_repository.dart';
import '../helpers/incident_fixtures.dart';

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
}

void main() {
  Future<void> openDashboard(WidgetTester tester) async {
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
    await tester.pumpWidget(
      CampusBoboApp(
        authRepository: auth,
        userProfileRepository: FakeUserProfileRepository(),
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
}
