# Campus Bobo

Campus Bobo is a Flutter mobile application for reporting incidents on the ALU campus and following their resolution. Students can submit and manage reports, while authorised staff review incidents and update their status. The application was developed for Formative Assignment 2 in Mobile Web Development.

The project uses Firebase Authentication for accounts, Cloud Firestore for profiles and incidents, and Provider with ChangeNotifier for application state. Optional photo attachments use the Firebase Storage SDK with the local Storage Emulator. Hosted Firebase Storage has not been activated because billing setup could not be completed.

## Implemented features

### Student workflow

- Register and sign in using an `@alustudent.com` email address and password.
- Verify the email address before accessing reports, resend the verification email, and restore an existing session when reopening the app.
- View a dashboard with personal report counts and recent campus incidents.
- Submit an incident with a title, description, location, and one of six categories: facilities, water, electricity, furniture, sanitation, or safety.
- In local emulator mode, attach one optional JPEG or PNG image of up to 5 MB, preview it, and remove or change it before submission.
- Browse reports, search by title, description, location, or report reference, and filter by category, status, or **My reports**.
- View report details, current status, submission date, last update, and attachment when available.
- Edit or delete an owned report while its status is **Submitted**. Deletion requires confirmation.

### Staff workflow

- Access a dedicated dashboard with campus-wide counts and reports awaiting review.
- Browse, search, and filter campus reports.
- Advance a report from **Submitted** to **In progress**, then to **Resolved**.
- Use **Dashboard**, **Reports**, and **Profile** navigation without student submission controls.

The interface uses a white background, yellow accents, dark text, Poppins typography, and consistent icons. Shared cards, status badges, form components, and feedback widgets keep the screens consistent. Forms validate input, and screens provide loading, empty, and error states where appropriate.

## CRUD and access control

| Operation | Implementation |
| --- | --- |
| Create | Submit an incident with its owner UID, details, initial status, and server timestamps. |
| Read | Receive report lists and individual report updates through Firestore snapshot streams. |
| Update | Students edit their own submitted reports; staff advance report statuses. |
| Delete | Students delete their own submitted reports after confirmation. |

Firestore rules enforce permissions independently of the interface. Access to incidents requires a verified campus account and an existing profile. Rules protect ownership and creation timestamps, restrict editable fields, and reject invalid status transitions. Users cannot promote themselves to staff through the app.

Storage rules restrict photo creation to the owner, validate size and content type, and allow verified campus members to read photos attached to reports. See [firestore.rules](firestore.rules) and [storage.rules](storage.rules).

## Architecture and state management

The code is organised by feature under `lib/features`, with four layers where needed:

| Layer | Responsibility |
| --- | --- |
| Presentation | Screens, reusable widgets, navigation, and user feedback. |
| Application | ChangeNotifier controllers coordinating authentication, submission, report lists, and dashboard state. |
| Domain | Models, validation, categories, statuses, and repository interfaces. |
| Data | Firebase implementations of the repository interfaces. |

Provider supplies repositories, the current user profile, and controllers to the widget tree:

- `AuthController` manages the session, verification feedback, and authentication loading and error states.
- `IncidentSubmissionController` manages validation and saving reports.
- `IncidentListController` manages report data, search, filters, loading, and errors.
- `DashboardController` calculates report summaries and review queues from the report stream.

Some presentation widgets access repository interfaces directly. `UserProfileGate` creates and watches the profile, while report details and photo widgets use repositories with StreamBuilder or FutureBuilder. Short-lived interface state, such as navigation selection and photo preview, uses local widget state.

```text
lib/
  main.dart                 Firebase initialisation and run mode
  app.dart                  Providers and application theme
  core/                     Shared theme, widgets, and emulator configuration
  features/
    auth/                   Authentication and session handling
    profile/                User profiles and roles
    incidents/              Submission, browsing, details, and management
    dashboard/              Summaries and role-based navigation
    welcome/                Welcome screen and reporting guide
```

The main Firebase classes are `FirebaseAuthRepository`, `FirestoreUserProfileRepository`, and `FirestoreIncidentRepository`. The diagrams show the implemented connections and data relationships:

- [Application architecture](diagrams/campus_bobo_architecture.png)
- [Firebase data model](diagrams/campus_bobo_firebase_data_model.png)

## Data model

The default Firestore database contains two collections:

| Document path | Fields |
| --- | --- |
| `users/{uid}` | `email`, `displayName`, `role` (strings); `createdAt` (timestamp). |
| `incidents/{incidentId}` | `reportedBy`, `title`, `description`, `location`, `category`, `status` (strings); `createdAt`, `updatedAt` (timestamps); optional `photoPath` (string). |

The profile document ID matches the Firebase Authentication UID. Each incident's `reportedBy` field stores that UID, linking the report to its owner. Passwords and email verification are handled by Firebase Authentication.

New profiles receive the role `student`; an administrator assigns `staff`. Statuses are stored as `submitted`, `in_progress`, and `resolved`. Creation and update dates use server timestamps. Only the current status is saved; the progress display is not a stored status history.

Photo files are stored by the local Storage Emulator at `incident_photos/{uid}/{incidentId}/photo`. Firestore stores this object path only when an attachment exists. The repository uploads the photo before saving the incident and attempts to remove it if saving fails. Text edits preserve the attachment.

Reports are streamed in descending `createdAt` order. Search, filters, dashboard counts, and recent-report selection run in Dart. The project uses automatic Firestore indexes; no custom composite indexes are defined.

## Setup and running

### Requirements

- Flutter with a Dart SDK compatible with `^3.13.2`, as specified in `pubspec.yaml`.
- Android Studio, the Android SDK, and an Android emulator.
- For local Firebase services and rule tests: Firebase CLI, Node.js, and Java 21 or newer.

### Live Firebase mode

The Android application is configured for Firebase project `campus-bobo`, using package `com.example.campus_bobo`. Email/Password authentication and the default Firestore database must be enabled, with the project rules deployed.

```sh
flutter pub get
flutter run
```

This mode uses hosted Authentication and Firestore. Photo selection is disabled because hosted Storage is not configured. Register with a valid ALU student email, open the verification link, and return to the app to check verification.

### Local mode with photo attachments

Start the Android emulator. In the first terminal, start the Firebase services:

```sh
firebase emulators:start --only auth,firestore,storage --project demo-campus-bobo --export-on-exit=.emulator-data
```

In a second terminal, run:

```sh
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

This mode connects **Authentication, Firestore, and Storage** to local services on the computer. Its accounts, roles, reports, and photos are separate from the live project. Register a local account and open the verification link printed in the Firebase terminal. Inspect local records and files at <http://127.0.0.1:4000>.

Keep the services running while using the app. Stop them with Ctrl+C and wait for export to finish. To restore an existing export, add `--import=.emulator-data` to the services command. The exported data is excluded from Git. The default connection address, `10.0.2.2`, is configured for the Android Studio emulator.

See [Firebase setup and verification](docs/firebase_setup.md) for Windows Java configuration, service setup, photo testing, and the complete manual checklist.

### Assigning a staff role

1. Register, verify the account, and open the dashboard once to create its profile.
2. In the live Firebase Console or local Emulator UI, open `users/{uid}` in Firestore.
3. Change `role` from `student` to `staff`.
4. Sign out and sign in again to check the staff workflow.

Use the console that matches the app's run mode. Staff demonstration accounts use the same verified `@alustudent.com` registration flow. A separate staff domain or public staff registration page is not configured.

## Testing

Run static analysis and the unit and widget tests with:

```sh
flutter analyze
flutter test test
```

The suite covers authentication and verification, profile creation, controller state, incident validation, CRUD, search and filters, student and staff navigation, and photo validation and interface behaviour using test repositories.

To test backend permissions with local Firebase services:

```sh
firebase emulators:exec --only auth,firestore,storage --project demo-campus-bobo "node integration_test/security_rules_test.mjs"
```

These tests check allowed and denied operations for owners, other students, staff, unverified accounts, and accounts outside the campus domain, including attachment permissions. Static analysis, unit and widget tests, backend rule checks, and an Android debug build have passed during development. The student reporting and staff review workflows have also been checked manually on Android. The native local-photo integration test is included in `integration_test/local_photos_test.dart`; its device execution remains unverified.

The demonstration should show authentication, submission, browsing and filters, owner editing and deletion, staff status updates, and the corresponding backend records. Attachments must be demonstrated in local mode and identified as emulator storage.

## Challenges

- **Storage billing:** Hosted Firebase Storage could not be activated. The official Storage Emulator provides a local implementation using the Firebase SDK and rules, with separate local Authentication and Firestore data.
- **Role permissions:** Student ownership and staff review required different actions and navigation. Role-aware screens are supported by backend rules that protect ownership and restrict status transitions.
- **Asynchronous updates:** Authentication changes, profile loading, and report streams required consistent loading and error handling. Controllers and stream-based widgets keep the interface updated.
- **Photo consistency:** A photo upload and a Firestore write are separate operations. The repository uploads the photo first, stores its path in the incident, and attempts file cleanup if saving fails or the incident is deleted.

## Limitations

- Hosted photo storage remains incomplete. The local implementation does not demonstrate deployed Firebase Storage, and local photos require the computer and services to remain available.
- Live and local data are independent. Changing a role in the live Firebase Console does not change a local account.
- Reports retain the current status and last update only, without a status-change audit history.
- Search and filtering load the report collection into memory. Pagination and server-side search are not implemented.
- Each report supports one photo at creation. Existing attachments cannot be replaced or removed through report editing. File cleanup is best effort if a storage operation fails.
- Android is the configured demonstration platform. Other platforms have not been verified.

## Font licence

Poppins is bundled under the SIL Open Font License. See [assets/fonts/OFL.txt](assets/fonts/OFL.txt).
