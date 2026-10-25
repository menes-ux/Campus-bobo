# Campus Bobo

A Flutter mobile app for reporting campus issues and tracking their resolution within the ALU community.

## Current progress

- White, yellow, and black theme with bundled Poppins fonts.
- Welcome screen and reporting guide with mobile navigation.
- Guidance for facilities, water, electricity, furniture, sanitation, and safety reports.
- Firebase Core, Firebase Authentication, and Provider dependencies installed.
- Android registered with Firebase project `campus-bobo`, with Firebase initialized before the app starts.

Sign-up, login, incident submission, report browsing, photo uploads, and staff workflows are not implemented yet. Firebase startup is configured for Android only.

The [Firebase setup guide](docs/firebase_setup.md) covers project creation, email/password sign-in, and Android configuration.

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

The integration test requires a running Android emulator. Use `flutter devices` to find its ID if it differs from `emulator-5554`. This check runs native Firebase initialization and verifies that the welcome screen opens; authentication and database workflows will have separate checks as they are implemented.

## Project structure

```text
lib/
  main.dart                  App entry point
  app.dart                   MaterialApp configuration
  firebase_options.dart      Generated Firebase platform configuration
  core/theme/                Shared colors and theme
  core/widgets/              Reusable visual components
  features/welcome/          Welcome screen and reporting guide
assets/fonts/                Poppins fonts and license
test/                        Widget navigation test
integration_test/            Firebase startup check on Android
```

## Firebase services

Firebase Authentication will handle sign-in and email verification. Cloud Firestore will store user profiles and incident records, and Firebase Storage will hold incident photos. Provider will manage shared authentication and incident state.

Firebase Core is initialized in `main.dart`. The generated Android configuration is checked into the repository; it identifies the Firebase app and does not grant administrative access. Firestore and Storage provisioning and access rules remain part of later stages.

Student registration will use `@alustudent.com` with email verification. The complete staff email domain still needs confirmation. Staff permissions will be assigned explicitly and enforced by Firebase rules; an email domain alone will not grant staff access.

## Development workflow

Work in small, meaningful checkpoints, with a target of more than 50 commits across setup, features, security rules, testing, and documentation. Describe each stage before changing code. Commit completed work after checking it, and push after each milestone or work session.

Firebase Console tasks are documented as numbered steps. Console configuration is separate from repository changes and does not create a Git commit by itself.

## Font license

Poppins is bundled from the [Google Fonts repository](https://github.com/google/fonts/tree/main/ofl/poppins) under the SIL Open Font License. The license is included in `assets/fonts/OFL.txt`.
