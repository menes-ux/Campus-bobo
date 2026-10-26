# Campus Bobo

Campus Bobo is a Flutter Android application for reporting campus incidents and tracking their resolution. It uses Firebase Authentication, Cloud Firestore, and Provider.

## Features

- Registration and login with verified `@alustudent.com` email addresses.
- Incident submission with a category, title, description, and location.
- Live dashboard, search, category and status filters, and personal report summaries.
- Report details and progress from Submitted to In progress to Resolved.
- Owners can edit or delete their reports while they are Submitted.
- Authorized staff can update report statuses. Firestore rules protect ownership and staff permissions.

Incident photo uploads are not implemented because Firebase Storage requires billing, which has not been enabled. This is an outstanding assignment requirement.

## Run

Install Flutter, start an Android emulator or connect an Android phone, then run:

```sh
flutter pub get
flutter run
```

The Android app is configured for Firebase project `campus-bobo`. See [Firebase setup](docs/firebase_setup.md) for service configuration, role assignment, and the manual verification checklist.

## Checks

```sh
flutter analyze
flutter test test
```

Backend access-control tests use the Firebase Authentication and Firestore emulators; instructions are in the setup guide. The `integration_test` directory also contains Android Firebase startup and authentication tests.

## Structure

`lib/features` groups authentication, profiles, incidents, the dashboard, and welcome screens. Each feature separates presentation, state, and Firebase data access where needed. Shared styling and widgets are in `lib/core`.

## Fonts

Poppins is bundled under the SIL Open Font License. The licence is included in [assets/fonts/OFL.txt](assets/fonts/OFL.txt).
