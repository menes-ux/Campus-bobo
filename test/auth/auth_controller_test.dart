import 'dart:async';

import 'package:campus_bobo/features/auth/application/auth_controller.dart';
import 'package:campus_bobo/features/auth/domain/auth_failure.dart';
import 'package:campus_bobo/features/auth/domain/auth_user.dart';
import 'package:campus_bobo/features/auth/domain/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';

void main() {
  group('Student email validation', () {
    test(
      'accepts the exact domain and normalizes case and surrounding spaces',
      () {
        expect(
          AuthValidators.studentEmail(' Student.Name@ALUSTUDENT.COM '),
          isNull,
        );
        expect(
          AuthValidators.normalizeEmail(' Student.Name@ALUSTUDENT.COM '),
          'student.name@alustudent.com',
        );
      },
    );

    test('rejects other domains and malformed email addresses', () {
      for (final email in [
        'student@gmail.com',
        'student@alustudent.com.other.com',
        'student@otheralustudent.com',
        'student@sub.alustudent.com',
        '@alustudent.com',
        '.student@alustudent.com',
        'student..name@alustudent.com',
        'a@@alustudent.com',
        '',
      ]) {
        expect(AuthValidators.studentEmail(email), isNotNull, reason: email);
      }
    });
  });

  group('Authentication state', () {
    late FakeAuthRepository repository;
    late AuthController auth;

    setUp(() async {
      repository = FakeAuthRepository();
      auth = AuthController(repository);
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() async {
      auth.dispose();
      await repository.close();
    });

    test('rejects a non-student email before calling Firebase', () async {
      expect(
        await auth.register('Student', 'student@gmail.com', 'password123'),
        isFalse,
      );
      expect(repository.registerCalls, 0);
      expect(auth.session, AuthSession.signedOut);
    });

    test(
      'registration sends verification and prevents immediate resends',
      () async {
        expect(
          await auth.register(
            ' Campus Student ',
            ' Student@ALUSTUDENT.COM ',
            'password123',
          ),
          isTrue,
        );
        expect(repository.submittedEmail, 'student@alustudent.com');
        expect(auth.user!.displayName, 'Campus Student');
        expect(auth.session, AuthSession.unverified);
        expect(repository.verificationCalls, 1);
        expect(await auth.resendVerification(), isFalse);
        expect(repository.verificationCalls, 1);
      },
    );

    test(
      'a successful login stays blocked until verification is refreshed',
      () async {
        await auth.signIn('student@alustudent.com', 'password123');
        expect(auth.session, AuthSession.unverified);
        await auth.refreshVerification();
        expect(auth.session, AuthSession.unverified);
        expect(auth.message, contains('not verified yet'));
        repository.verifyOnReload = true;
        await auth.refreshVerification();
        expect(auth.session, AuthSession.verified);
        await auth.signOut();
        expect(auth.session, AuthSession.signedOut);
        expect(auth.user, isNull);
      },
    );

    test(
      'a restored verified account from another domain is denied access',
      () async {
        repository.emitUser(
          const AuthUser(
            uid: 'outside',
            email: 'student@gmail.com',
            emailVerified: true,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(auth.session, AuthSession.unsupportedEmail);
      },
    );

    test('duplicate login requests are ignored while one is running', () async {
      repository.signInCompleter = Completer<void>();
      final request = auth.signIn('student@alustudent.com', 'password123');
      expect(auth.isBusy, isTrue);
      expect(
        await auth.signIn('student@alustudent.com', 'password123'),
        isFalse,
      );
      expect(repository.signInCalls, 1);
      repository.signInCompleter!.complete();
      await request;
      expect(auth.isBusy, isFalse);
    });

    test(
      'failed requests release loading state and show a readable error',
      () async {
        repository.nextFailure = AuthFailure.fromCode('network-request-failed');
        expect(
          await auth.signIn('student@alustudent.com', 'password123'),
          isFalse,
        );
        expect(auth.isBusy, isFalse);
        expect(auth.error, contains('internet connection'));
        expect(auth.session, AuthSession.signedOut);
      },
    );

    test('verification delivery failure keeps the created account available for retry', () async {
      repository.verificationFailure = AuthFailure.fromCode(
        'network-request-failed',
      );
      expect(
        await auth.register(
          'Campus Student',
          'student@alustudent.com',
          'password123',
        ),
        isFalse,
      );
      expect(auth.session, AuthSession.unverified);
      expect(auth.error, contains('internet connection'));
      repository.verificationFailure = null;
      expect(await auth.resendVerification(), isTrue);
      expect(repository.registerCalls, 1);
      expect(repository.verificationCalls, 2);
    });
  });
}
