import 'dart:convert';
import 'dart:io';

import 'package:campus_bobo/app.dart';
import 'package:campus_bobo/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/fake_user_profile_repository.dart';
import '../test/helpers/fake_incident_repository.dart';

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

Future<void> _tap(
  WidgetTester tester,
  Finder finder, {
  double delta = 250,
}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
  await _reveal(tester, finder, delta: delta);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enter(
  WidgetTester tester,
  String key,
  String value, {
  double delta = 250,
}) async {
  final finder = find.byKey(ValueKey(key));
  await _reveal(tester, finder, delta: delta);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, value);
  await tester.pumpAndSettle();
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 150; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(
    finder,
    findsOneWidget,
    reason: tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .join(' | '),
  );
}

Future<String> _actionCode(String email, String requestType) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(
      Uri.parse(
        'http://10.0.2.2:9099/emulator/v1/projects/campus-bobo/oobCodes',
      ),
    );
    final response = await request.close();
    expect(response.statusCode, HttpStatus.ok);
    final body = jsonDecode(
      await utf8.decoder.bind(response).join(),
    ) as Map<String, dynamic>;
    final codes = (body['oobCodes'] as List).cast<Map<String, dynamic>>();
    return codes.lastWhere(
          (code) =>
              code['email'] == email && code['requestType'] == requestType,
        )['oobCode']
        as String;
  } finally {
    client.close();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Student registration, verification, login and logout', (
    tester,
  ) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final auth = FirebaseAuth.instance;
    await auth.useAuthEmulator('10.0.2.2', 9099);
    await auth.signOut();
    addTearDown(() async {
      await auth.currentUser?.delete();
      await auth.signOut();
    });
    final email =
        'flow.${DateTime.now().millisecondsSinceEpoch}@alustudent.com';
    const password = 'Campus-test-password-1';

    final incidents = FakeIncidentRepository();
    addTearDown(incidents.close);
    await tester.pumpWidget(
      CampusBoboApp(
        userProfileRepository: FakeUserProfileRepository(),
        incidentRepository: incidents,
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Get started'));
    await _tap(tester, find.text('New here? Create an account'));
    await _enter(tester, 'auth-name', 'Campus Student', delta: -250);
    await _enter(tester, 'auth-email', email);
    await _enter(tester, 'auth-password', password);
    await _enter(tester, 'auth-confirm-password', password);
    await _tap(tester, find.byKey(const ValueKey('auth-submit')));

    expect(find.text('Check your inbox.'), findsOneWidget);
    expect(find.text('Your campus account.'), findsNothing);
    expect(auth.currentUser!.emailVerified, isFalse);
    await _tap(tester, find.text('I have verified my email'));
    expect(find.text('Check your inbox.'), findsOneWidget);

    await auth.applyActionCode(await _actionCode(email, 'VERIFY_EMAIL'));
    await _tap(tester, find.text('I have verified my email'));
    expect(find.text('Hello, Campus.'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your campus account.'), findsOneWidget);
    expect(auth.currentUser!.emailVerified, isTrue);
    expect(find.text('Campus Student'), findsOneWidget);
    await _tap(tester, find.text('Sign out'));
    expect(auth.currentUser, isNull);

    await _enter(tester, 'auth-email', email, delta: -250);
    await _enter(tester, 'auth-password', password);
    await _tap(tester, find.byKey(const ValueKey('auth-submit')));
    await _waitFor(tester, find.text('Hello, Campus.'));
    expect(auth.currentUser!.email, email);
  });
}
