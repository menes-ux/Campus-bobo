# Firebase setup and verification

## Services

The Android app is registered with Firebase project `campus-bobo`, using package `com.example.campus_bobo`. Its configuration is in `android/app/google-services.json` and `lib/firebase_options.dart`.

In Firebase Console, enable **Authentication → Sign-in method → Email/Password** and create the **Cloud Firestore** default database. The app sends verification emails and requires a verified `@alustudent.com` account before opening the dashboard.

Deploy the Firestore rules from the project directory:

```sh
firebase deploy --only firestore --project campus-bobo
```

Firebase Storage is not configured. Photo uploads remain an unmet assignment requirement because billing has been excluded from the project scope.

## Data and permissions

`users/{uid}` stores `email`, `displayName`, `role`, and `createdAt`. Registration creates the `student` role. Clients cannot change roles.

`incidents/{id}` stores `reportedBy`, `title`, `description`, `location`, `category`, `status`, `createdAt`, and `updatedAt`. Dates are server timestamps. Verified campus members with a saved profile can browse reports. Owners can edit the text/category or delete their reports only while the status is `submitted`. Only staff can advance statuses from `submitted` to `in_progress`, then `resolved`. Ownership, original timestamps, and unrelated fields are protected by rules.

## Set up the staff demonstration account

1. Register a second ALU student email account in the app and verify its email. Open the dashboard once so its profile is created.
2. Open **Firebase Console → campus-bobo → Build → Authentication → Users**.
3. Find the demonstration account and copy its **User UID**.
4. Open **Build → Firestore Database → Data → users** and select the document with that UID.
5. Edit the `role` field from `student` to `staff` and save it.
6. Sign in to that account in the app. Open a report to see **Staff review**.

For this coursework demonstration, the staff role is assigned to a verified ALU student email account. Role assignment is an administrator action in the Console; users cannot select or promote their own role in the app. A separate staff email domain has not been configured.

## Manual Android checks

1. Register, verify the email, sign in, sign out, and sign in again. Confirm an unverified or non-ALU account cannot access reports.
2. Submit a report and check the matching Firestore record. Confirm empty or invalid fields show validation messages.
3. Open the dashboard and Reports. Search, filter by category/status, and select **My reports**.
4. Open your submitted report, edit its details, and confirm the changes appear in the app and Firestore. Delete another submitted report and confirm cancellation leaves it intact.
5. Sign in as the staff demonstration account. Open another student's report and select **Mark in progress**, then **Mark resolved**. Check the Firestore status and updated timestamp.
6. Return to the student account. Confirm the updated status appears and that staff controls are hidden. Reports under review cannot be edited or deleted by their owners.
7. Restart the app and confirm the session and stored reports are restored. Test a disconnected network and retry.

## Automated checks

```sh
flutter analyze
flutter test test
```

The backend rules test requires Node.js, Firebase CLI, and Java 21 or newer. Android Studio includes a suitable Java runtime; on Windows, select it for the current PowerShell session:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
firebase emulators:exec --only auth,firestore --project demo-campus-bobo "node integration_test/security_rules_test.mjs"
```

This test uses a local demo project and checks permitted and denied operations for owners, other students, staff, unverified users, and external email accounts. It does not use production accounts or data.

The Android startup check can be run with an emulator connected:

```sh
flutter test integration_test/firebase_startup_test.dart -d emulator-5554
```

The authentication flow test uses the Authentication emulator on port 9099. In a separate terminal run `firebase emulators:start --only auth --project campus-bobo`, then run `flutter test integration_test/auth_flow_test.dart -d emulator-5554`.
