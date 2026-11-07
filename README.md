# Campus Bobo

Campus Bobo is a Flutter mobile application for reporting incidents on the ALU campus and following their resolution. Students can submit and manage reports, while authorised staff review incidents and update their status.

The project uses Firebase Authentication for accounts, Cloud Firestore for profiles and incidents, Cloudinary for optional photo attachments, and Provider with ChangeNotifier for application state.

## Implemented features

### Student workflow

- Register and sign in using an `@alustudent.com` email address and password.
- Verify the email address before accessing reports, resend the verification email, and restore an existing session when reopening the app.
- View a dashboard with personal report counts and recent campus incidents.
- Submit an incident with a title, description, location, and one of six categories: facilities, water, electricity, furniture, sanitation, or safety.
- Attach one optional JPEG or PNG image of up to 5 MB, preview it, and remove or change it before submission.
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

Firestore validates attachment metadata and prevents it from being replaced during report editing. The app validates JPEG/PNG images and the 5 MB limit before upload. Cloudinary uses an unsigned upload preset; matching server-side restrictions should also be configured in that preset. Images are accessible through their delivery URLs; Firebase permissions do not control Cloudinary uploads or image delivery. See [firestore.rules](firestore.rules).

## Architecture and state management

The code is organised by feature under `lib/features`, with four layers where needed:

| Layer | Responsibility |
| --- | --- |
| Presentation | Screens, reusable widgets, navigation, and user feedback. |
| Application | ChangeNotifier controllers coordinating authentication, submission, report lists, and dashboard state. |
| Domain | Models, validation, categories, statuses, and repository interfaces. |
| Data | Firebase repository implementations and the Cloudinary upload and download service. |

Provider supplies repositories, the current user profile, and controllers to the widget tree:

- `AuthController` manages the session, verification feedback, and authentication loading and error states.
- `IncidentSubmissionController` manages validation and saving reports.
- `IncidentListController` manages report data, search, filters, loading, and errors.
- `DashboardController` calculates report summaries and review queues from the report stream.

Some presentation widgets access repository interfaces directly. `UserProfileGate` creates and watches the profile, while report details and photo widgets use repositories with StreamBuilder or FutureBuilder. Short-lived interface state, such as navigation selection and photo preview, uses local widget state.

```text
lib/
  main.dart                 Firebase initialisation
  app.dart                  Providers and application theme
  core/                     Shared theme and widgets
  features/
    auth/                   Authentication and session handling
    profile/                User profiles and roles
    incidents/              Submission, browsing, details, and management
    dashboard/              Summaries and role-based navigation
    welcome/                Welcome screen and reporting guide
```

The main data classes are `FirebaseAuthRepository`, `FirestoreUserProfileRepository`, `FirestoreIncidentRepository`, and `CloudinaryPhotoStorage`. The incident repository coordinates photo uploads and report writes; the Cloudinary service handles HTTPS requests without an API secret in the app.

The diagrams describe the current implementation:

- [Application architecture](docs/diagrams/application_architecture.png)
- [Firebase and Cloudinary data model](docs/diagrams/data_model.png)

## Data model

The default Firestore database contains two collections:

| Document path | Fields |
| --- | --- |
| `users/{uid}` | `email`, `displayName`, `role` (strings); `createdAt` (timestamp). |
| `incidents/{incidentId}` | `reportedBy`, `title`, `description`, `location`, `category`, `status` (strings); `createdAt`, `updatedAt` (timestamps); optional `photoUrl`, `photoPublicId` (strings, stored together). |

The profile document ID matches the Firebase Authentication UID. Each incident's `reportedBy` field stores that UID, linking the report to its owner. Passwords and email verification are handled by Firebase Authentication.

New profiles receive the role `student`; an administrator assigns `staff`. Statuses are stored as `submitted`, `in_progress`, and `resolved`. Creation and update dates use server timestamps. Only the current status is saved; the progress display is not a stored status history.

Photo files are hosted by Cloudinary. Firestore stores the HTTPS delivery URL in `photoUrl` and the asset identifier in `photoPublicId` only when an attachment exists. The repository uploads the photo before saving the incident. Text edits preserve the attachment. Deleting a report removes its Firestore record; unused images must be removed through the Cloudinary Media Library.

Reports are streamed in descending `createdAt` order. Search, filters, dashboard counts, and recent-report selection run in Dart. The project uses automatic Firestore indexes; no custom composite indexes are defined.

## Setup and running

### Requirements

- Flutter with a Dart SDK compatible with `^3.13.2`, as specified in `pubspec.yaml`.
- Android Studio, the Android SDK, and an Android emulator.
- A free Cloudinary Image and Video API account with an unsigned upload preset.
- For backend rule tests: Firebase CLI, Node.js, and Java 21 or newer.

### Run the application

The Android application is configured for Firebase project `campus-bobo`, using package `com.example.campus_bobo`. Email/Password authentication and the default Firestore database must be enabled, with the project rules deployed.

```sh
flutter pub get
flutter run
```

The default Cloudinary configuration uses cloud `zsjjkx8z` and unsigned upload preset `campus_bobo`. These are public configuration values; an API secret is not used. Configure matching JPEG/PNG and 5 MB restrictions in the preset. For another Cloudinary account, override `CLOUDINARY_CLOUD_NAME` and `CLOUDINARY_UPLOAD_PRESET` with Flutter `--dart-define` arguments and update the allowed cloud in `firestore.rules`.

The application uses hosted Firebase Authentication, hosted Firestore, and Cloudinary together. No local Firebase services are needed to run it. Register with a valid ALU student email, open the verification link, and return to the app to check verification.

See [Firebase and photo setup](docs/firebase_setup.md) for service configuration, Cloudinary setup, and the manual checklist.

### Assigning a staff role

1. Register, verify the account, and open the dashboard once to create its profile.
2. In the Firebase Console, open `users/{uid}` in Firestore.
3. Change `role` from `student` to `staff`.
4. Sign out and sign in again to check the staff workflow.

Staff demonstration accounts use the same verified `@alustudent.com` registration flow. A separate staff domain or public staff registration page is not configured.

## Testing

Run static analysis and the unit and widget tests with:

```sh
flutter analyze
flutter test test
```

The suite covers authentication and verification, profile creation, controller state, incident validation, CRUD, search and filters, student and staff navigation, and photo validation and interface behaviour using test repositories.

To test backend permissions with local Firebase services:

```sh
firebase emulators:exec --only auth,firestore --project demo-campus-bobo "node integration_test/security_rules_test.mjs"
```

These tests check allowed and denied operations for owners, other students, staff, unverified accounts, and accounts outside the campus domain, including validation and immutability of attachment metadata. Cloudinary HTTP requests are tested separately with a mock client. Static analysis, all 50 unit and widget tests, all 43 backend permission checks, and the Android debug build passed after the Cloudinary integration.

Student report management, staff status updates, and photo submission and display have been checked manually on Android. The [setup guide](docs/firebase_setup.md) contains the verification checklist.

## Challenges

- **Role permissions:** Student ownership and staff review required different actions and navigation. Role-aware screens are supported by backend rules that protect ownership and restrict status transitions.
- **Asynchronous updates:** Authentication changes, profile loading, and report streams required consistent loading and error handling. Controllers and stream-based widgets keep the interface updated.
- **Photo consistency:** A Cloudinary upload and a Firestore write are separate operations. The repository waits for the upload to succeed before saving the image URL and identifier with the incident. A failed database write can leave an unused image requiring manual cleanup.

## Limitations

- Cloudinary delivery URLs are public. Unsigned uploads are restricted by the preset, but they do not verify Firebase identity. This setup is intended for non-sensitive coursework images.
- Deleting an incident does not automatically delete its Cloudinary image. Unused images, including uploads followed by a failed Firestore write, require manual cleanup in the Media Library.
- Reports retain the current status and last update only, without a status-change audit history.
- Search and filtering load the report collection into memory. Pagination and server-side search are not implemented.
- Each report supports one photo at creation. Existing attachments cannot be replaced or removed through report editing.
- Android is the configured demonstration platform. Other platforms have not been verified.

## Font licence

Poppins is bundled under the SIL Open Font License. See [assets/fonts/OFL.txt](assets/fonts/OFL.txt).
