# Campus Bobo

A Flutter mobile app for reporting campus issues and tracking their resolution within the ALU community.

## Current progress

- White, yellow, and black theme with bundled Poppins fonts.
- Welcome screen and reporting guide with mobile navigation.
- Guidance for facilities, water, electricity, furniture, sanitation, and safety reports.
- Firebase Core, Firebase Authentication, and Provider dependencies installed.
- Android registered with Firebase project `campus-bobo`, with Firebase initialized before the app starts.
- Student registration, login, logout, and email verification using Provider for session state.
- Firestore dependency and initial profile rules prepared. Database creation and rule deployment are pending.

Incident submission, report browsing, photo uploads, and staff workflows are the next stages. Firebase is configured for Android only.

The [Firebase setup guide](docs/firebase_setup.md) covers project creation, email/password sign-in, and Android configuration.

The [Firestore setup guide](docs/firestore_setup.md) covers database creation and the initial user-profile schema.

## Run locally

Start an Android emulator in Android Studio or connect an Android device, then run:

```sh
flutter pub get
flutter run -d emulator-5554
```

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test test
flutter test integration_test/firebase_startup_test.dart -d emulator-5554
```

The integration test requires a running Android emulator. Use `flutter devices` to find its ID if it differs from `emulator-5554`. The [authentication guide](docs/authentication.md) includes a manual demo checklist and the local Auth emulator test.

## Project structure

```text
lib/
  main.dart                  App entry point
  app.dart                   MaterialApp configuration
  firebase_options.dart      Generated Firebase platform configuration
  core/theme/                Shared colors and theme
  core/widgets/              Reusable visual components
  features/auth/             Firebase repository, session state, and auth screens
  features/welcome/          Welcome screen and reporting guide
assets/fonts/                Poppins fonts and license
test/                        Authentication state, validation, and screen checks
integration_test/            Android Firebase startup and authentication checks
```

## Firebase services

Firebase Authentication handles registration, login, email verification, and logout. Provider manages the shared authentication state. Cloud Firestore will store user profiles and incident records, and Firebase Storage will hold incident photos.

Firebase Core is initialized in `main.dart`. The generated Android configuration is checked into the repository; it identifies the Firebase app and does not grant administrative access. Firestore and Storage provisioning and access rules remain part of later stages.

Student registration uses `@alustudent.com`. Unverified users remain on the verification screen, and restored accounts from other domains are blocked. The complete staff email domain still needs confirmation. Staff permissions will be assigned explicitly and enforced by Firebase rules; an email domain alone will not grant staff access.

## Development workflow

Work in small, meaningful checkpoints, with a target of more than 50 commits across setup, features, security rules, testing, and documentation. Describe each stage before changing code. Commit completed work after checking it, and push after each milestone or work session.

Keep the implementation focused on the Canvas requirements. Prioritize the required workflows and keep optional features for later.

Firebase Console tasks are documented as numbered steps. Console configuration is separate from repository changes and does not create a Git commit by itself.

## Font license

Poppins is bundled from the [Google Fonts repository](https://github.com/google/fonts/tree/main/ofl/poppins) under the SIL Open Font License. The license is included in `assets/fonts/OFL.txt`.
