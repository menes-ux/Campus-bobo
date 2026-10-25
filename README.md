# Campus Bobo

A Flutter mobile app for reporting campus issues and tracking their resolution within the ALU community.

## Current progress

- White, yellow, and black theme with bundled Poppins fonts.
- Welcome screen and reporting guide with mobile navigation.
- Guidance for facilities, water, electricity, furniture, sanitation, and safety reports.

Authentication, incident submission, report browsing, photo uploads, and staff workflows are not connected yet. Firebase will be configured in the next stage.

## Run locally

Start an Android emulator in Android Studio or connect an Android device, then run:

```sh
flutter pub get
flutter run
```

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Project structure

```text
lib/
  main.dart                  App entry point
  app.dart                   MaterialApp configuration
  core/theme/                Shared colors and theme
  core/widgets/              Reusable visual components
  features/welcome/          Welcome screen and reporting guide
assets/fonts/                Poppins fonts and license
test/                        Widget navigation test
```

## Planned Firebase integration

Firebase Authentication will handle sign-in and email verification. Cloud Firestore will store user profiles and incident records, and Firebase Storage will hold incident photos. Provider will manage shared authentication and incident state.

Staff permissions will be assigned explicitly and enforced by Firebase rules. An email domain alone will not grant staff access. The complete ALU student and staff email domains still need confirmation before domain validation is implemented.

## Font license

Poppins is bundled from the [Google Fonts repository](https://github.com/google/fonts/tree/main/ofl/poppins) under the SIL Open Font License. The license is included in `assets/fonts/OFL.txt`.
