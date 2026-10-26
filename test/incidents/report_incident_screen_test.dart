import 'package:campus_bobo/app.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_incident_repository.dart';
import '../helpers/fake_user_profile_repository.dart';

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
  Future<void> openForm(
    WidgetTester tester,
    FakeIncidentRepository incidents,
  ) async {
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
    await tester.pumpWidget(
      CampusBoboApp(
        authRepository: auth,
        userProfileRepository: FakeUserProfileRepository(),
        incidentRepository: incidents,
      ),
    );
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('Report an incident'));
    await tester.tap(find.text('Report an incident'));
    await tester.pumpAndSettle();
  }

  testWidgets('Empty fields show validation and do not save a report', (
    tester,
  ) async {
    final incidents = FakeIncidentRepository();
    await openForm(tester, incidents);
    await _reveal(tester, find.byKey(const ValueKey('incident-submit')));
    await tester.tap(find.byKey(const ValueKey('incident-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Choose an incident category.'), findsOneWidget);
    expect(incidents.submitCalls, 0);
  });

  testWidgets(
    'A valid form saves under the current user and shows confirmation',
    (tester) async {
      final incidents = FakeIncidentRepository();
      await openForm(tester, incidents);
      await _reveal(tester, find.byKey(const ValueKey('incident-category')));
      await tester.tap(find.byKey(const ValueKey('incident-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Water').last);
      await tester.pumpAndSettle();
      for (final entry in {
        'incident-title': 'Broken tap',
        'incident-location': 'Block A, ground floor',
        'incident-description':
            'The tap near the entrance is leaking continuously.',
      }.entries) {
        final field = find.byKey(ValueKey(entry.key));
        await _reveal(tester, field);
        await tester.enterText(field, entry.value);
      }
      await _reveal(tester, find.byKey(const ValueKey('incident-submit')));
      await tester.tap(find.byKey(const ValueKey('incident-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Report submitted.'), findsOneWidget);
      expect(find.text('Status: Submitted'), findsOneWidget);
      expect(incidents.reportedBy, 'student-1');
      expect(incidents.submitCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
