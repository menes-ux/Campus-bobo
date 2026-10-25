# Student authentication

## Scope

This stage implements the assignment's registration, login, logout, session handling, and ALU email verification requirements. Student accounts use `@alustudent.com`. Staff roles and data access rules belong to the Firestore stage.

## How it works

- `AuthRepository` defines the operations needed by the app. `FirebaseAuthRepository` implements them using Firebase Authentication.
- `AuthController` listens for user changes and exposes loading, signed-out, unverified, verified, and unsupported-email states through Provider.
- `AuthGate` selects the welcome screen, sign-in form, verification screen, or verified account screen from that state.
- Form state, password visibility, and switching between login and registration stay local to the screens.

New accounts save a display name and request a verification email. Verification can be refreshed manually or when the app resumes. A successful refresh also refreshes the Firebase ID token. Failed email delivery leaves the account signed in on the verification screen, where sending can be retried. Successful email sends have a 60-second resend cooldown.

The form and controller both validate the student email domain. This is a user-interface restriction. Firestore and Storage rules must also enforce verified ALU access when those services are added.

## Manual demo checklist

1. Run `flutter run -d emulator-5554` with the Android emulator open.
2. Tap **Get started**, then **New here? Create an account**.
3. Enter your name, your own ALU student email, and matching passwords of at least eight characters.
4. Tap **Create account**. The app should open **Check your inbox**.
5. Open the verification email in your inbox or spam folder and click its verification link.
6. Return to the app and tap **I have verified my email**. The verified account screen should appear.
7. Tap **Sign out**, then sign in with the same email and password.
8. Restart the app while signed in to check session restoration.
9. In Firebase Console, open **Authentication > Users** to demonstrate the stored account.

Email/password sign-in must be enabled in Firebase Console as described in the [setup guide](firebase_setup.md). The account screen is the signed-in landing screen for this stage; incident screens will be added next.

## Automated checks

```powershell
flutter analyze
flutter test test
```

The tests use a small fake repository to check validation, duplicate-request prevention, failed requests, verification gating, and navigation. The normal app uses `FirebaseAuthRepository` and the configured Firebase project.

For the native authentication check, start the local Auth emulator in one terminal:

```powershell
firebase.cmd emulators:start --only auth --project campus-bobo
```

In a second terminal, run:

```powershell
flutter test integration_test/auth_flow_test.dart -d emulator-5554
```

This test connects the Android Firebase SDK to the local Auth emulator, registers a temporary student account, applies its local verification code, and checks login and logout. It does not send real emails. The emulator connection is configured only by the test. Cleartext access to the local emulator is enabled only in the debug Android manifest.

Stop the Auth emulator with **Ctrl+C** when finished, then run the normal app again for a live Firebase demo.

## References

- [Firebase Flutter email/password authentication](https://firebase.google.com/docs/auth/flutter/password-auth)
- [Firebase user management and verification](https://firebase.google.com/docs/auth/flutter/manage-users)
- [Firebase Authentication emulator](https://firebase.google.com/docs/emulator-suite/connect_auth)
