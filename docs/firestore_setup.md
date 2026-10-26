# Firestore setup

## Create the database in Chrome

1. Open the [Campus Bobo Firestore console](https://console.firebase.google.com/project/campus-bobo/firestore).
2. Check that the selected project is **Campus Bobo** (`campus-bobo`).
3. Click **Create database**.
4. Select **Standard edition** if an edition choice is shown.
5. Keep the database ID as **(default)**.
6. Select **africa-south1 (Johannesburg)** as the location. If the console already has a location selected and does not allow changing it, keep that existing location.
7. Select **Start in production mode** if asked about security rules.
8. Click **Create** or **Enable** and wait until the database opens.

The console may show the location and security choices in a different order. The database location cannot be changed after creation. Creating the database through Firebase Console also enables the required Firestore service.

Stay on the project's current Spark plan for this step. No Storage billing setup is needed to create this Firestore database.

## Prepared repository configuration

- `cloud_firestore` is the Flutter package for database access.
- `firestore.rules` defines the initial user-profile access rules.
- `firestore.indexes.json` records composite indexes as report queries are added. No custom indexes are needed yet.
- `firebase.json` points the Firebase CLI to these files.

The rules and index configuration have been deployed to `campus-bobo`. After email verification, the app creates a missing profile and watches it for changes. The [incident submission guide](incident_reporting.md) describes the report collection and its creation rules.

## Initial data structure

Each user profile will be stored at `users/{firebaseAuthUid}`:

| Field | Type | Initial value |
| --- | --- | --- |
| `email` | String | The signed-in user's verified ALU student email |
| `displayName` | String | The user's name, 2–80 characters |
| `role` | String | `student` |
| `createdAt` | Timestamp | Firestore server timestamp |

The document ID is the Firebase Authentication UID. The app can read its own profile and create it once. Client updates, collection listing, and deletion are denied at this stage. A trusted project owner can assign `staff` later through Firebase Console; the app cannot grant that role to itself.

The `incidents` collection permits validated report creation, collection queries, and individual reads by verified campus members. Updates and deletion remain disabled until their corresponding workflows are added.

## Deploy after database creation

From the project root:

```powershell
firebase.cmd deploy --only firestore:rules,firestore:indexes --project campus-bobo
```

The Firebase CLI compiles and deploys the rules during this step. Deployment of these initial rules and indexes succeeded on October 26, 2026. Re-run the command after intentional rule changes.

## Check your saved profile

1. Open Campus Bobo and sign in with your verified student account.
2. Open **Profile** from the bottom navigation. The account screen should show **Role: Student**.
3. Open **Firestore Database > Data** in Firebase Console.
4. Click **users**, then the document matching your Firebase Authentication UID.
5. Check the stored email, display name, `student` role, and creation timestamp.

The app uses a transaction to create the document only if it is missing. Reopening the account does not overwrite its role. A snapshot listener keeps the displayed role in sync with the stored profile. A failed profile load shows retry and sign-out controls instead of assuming a role.

For a later staff demo, a trusted project owner can edit a designated account's `role` to the string `staff` in Firebase Console. That account will show **Role: Staff**. At this stage, login still uses the confirmed student domain; staff-specific incident actions are not implemented yet.

## References

- [Firestore Standard edition setup](https://firebase.google.com/docs/firestore/quickstart)
- [Firestore locations](https://firebase.google.com/docs/firestore/locations)
- [Firestore rule conditions](https://firebase.google.com/docs/firestore/security/rules-conditions)
