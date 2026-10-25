import 'package:campus_bobo/app.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';

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
  Future<void> openApp(
    WidgetTester tester,
    FakeAuthRepository repository,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(repository.close);
    await tester.pumpWidget(CampusBoboApp(authRepository: repository));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Sign in rejects an outside email and supports password visibility',
    (tester) async {
      final repository = FakeAuthRepository();
      await openApp(tester, repository);
      await _reveal(tester, find.text('Get started'));
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      await _reveal(tester, find.byKey(const ValueKey('auth-email')));
      await tester.enterText(
        find.byKey(const ValueKey('auth-email')),
        'student@gmail.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password')),
        'password123',
      );
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(find.byTooltip('Hide password'), findsOneWidget);
      await _reveal(tester, find.byKey(const ValueKey('auth-submit')));
      await tester.tap(find.byKey(const ValueKey('auth-submit')));
      await tester.pumpAndSettle();

      expect(
        find.text('Use your @alustudent.com email address.'),
        findsOneWidget,
      );
      expect(repository.signInCalls, 0);
      expect(find.text('Your campus account.'), findsNothing);
    },
  );

  testWidgets(
    'Registration keeps the email and Android Back returns to sign in',
    (tester) async {
      final repository = FakeAuthRepository();
      await openApp(tester, repository);
      await _reveal(tester, find.text('Get started'));
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      final emailField = find.byKey(const ValueKey('auth-email'));
      await _reveal(tester, emailField);
      await tester.enterText(emailField, 'student@alustudent.com');
      await _reveal(tester, find.text('New here? Create an account'));
      await tester.tap(find.text('New here? Create an account'));
      await tester.pumpAndSettle();
      expect(find.text('A better campus\nstarts with you.'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(emailField).controller!.text,
        'student@alustudent.com',
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Welcome back.'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(emailField).controller!.text,
        'student@alustudent.com',
      );
    },
  );

  testWidgets('An unverified session cannot enter the account screen', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      const AuthUser(
        uid: 'student-1',
        email: 'student@alustudent.com',
        emailVerified: false,
      ),
    );
    await openApp(tester, repository);
    expect(find.text('Check your inbox.'), findsOneWidget);
    expect(find.text('Your campus account.'), findsNothing);
    repository.verifyOnReload = true;
    await _reveal(tester, find.text('I have verified my email'));
    await tester.tap(find.text('I have verified my email'));
    await tester.pumpAndSettle();
    expect(find.text('Your campus account.'), findsOneWidget);
    await _reveal(tester, find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Your campus account.'), findsNothing);
    expect(repository.currentUser, isNull);
  });

  testWidgets('A restored outside account is blocked even if verified', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      const AuthUser(
        uid: 'outside',
        email: 'student@gmail.com',
        emailVerified: true,
      ),
    );
    await openApp(tester, repository);
    expect(find.text('Use your student account.'), findsOneWidget);
    expect(find.text('Your campus account.'), findsNothing);
  });
}
