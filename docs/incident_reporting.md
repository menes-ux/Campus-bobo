# Incident submission

## Current workflow

1. Sign in with a verified ALU student account.
2. From the account screen, tap **Report an incident**.
3. Choose a category and enter a title, location, and description.
4. Tap **Submit report**. The button is disabled while the request is running.
5. A successful save shows **Report submitted**, **Status: Submitted**, and the Firestore document reference.
6. In Firebase Console, open **Firestore Database > Data > incidents** and select that reference to inspect the stored record.

A failed save displays a readable message and keeps the entered text available for retry. The screen checks that the signed-in account still matches the reporter. Firebase rules enforce ownership independently of the form.

## Record structure

Reports are stored at `incidents/{generatedId}`:

| Field | Type | Meaning |
| --- | --- | --- |
| `reportedBy` | String | Signed-in user's Firebase Authentication UID |
| `title` | String | Short report title, 3-100 characters |
| `description` | String | Report details, 10-2,000 characters |
| `location` | String | Campus location, 3-120 characters |
| `category` | String | facilities, water, electricity, furniture, sanitation, or safety |
| `status` | String | Always `submitted` when created |
| `createdAt` | Timestamp | Firestore server timestamp |
| `updatedAt` | Timestamp | Firestore server timestamp |

The app trims surrounding whitespace before saving. Reports store the reporter's UID rather than copying their email into every report.

## Access rules

A verified ALU account must have a stored student or staff profile to create a report. The owner must match the authenticated UID, all fields must match the allowed schema, and the initial status and timestamps are fixed by the rules. Individual report reads require the same verified campus membership.

Collection queries and individual reads are enabled for verified campus members. Report updates, deletion, and photo handling are upcoming stages. The [browsing guide](report_browsing.md) covers report search, filtering, and details.

## Code and checks

`IncidentDraft` holds validated form data. `IncidentSubmissionController` manages saving, feedback, and duplicate-tap prevention through Provider. `FirestoreIncidentRepository` writes the record and returns its reference.

```powershell
flutter analyze
flutter test test
```

The submission tests use a fake repository to check invalid content, repeated taps, error recovery, and the form's confirmation state. Live persistence can be checked through the manual workflow above.
