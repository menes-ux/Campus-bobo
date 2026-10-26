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

The app does not write user profiles or incidents yet. The profile connection will be added after the database exists and the rules are deployed.

## Initial data structure

Each user profile will be stored at `users/{firebaseAuthUid}`:

| Field | Type | Initial value |
| --- | --- | --- |
| `email` | String | The signed-in user's verified ALU student email |
| `displayName` | String | The user's name, 2–80 characters |
| `role` | String | `student` |
| `createdAt` | Timestamp | Firestore server timestamp |

The document ID is the Firebase Authentication UID. The app can read its own profile and create it once. Client updates, collection listing, and deletion are denied at this stage. A trusted project owner can assign `staff` later through Firebase Console; the app cannot grant that role to itself.

Incident collections remain inaccessible until incident-specific rules and workflows are added.

## Deploy after database creation

From the project root:

```powershell
firebase.cmd deploy --only firestore:rules,firestore:indexes --project campus-bobo
```

The Firebase CLI compiles and deploys the rules during this step. The rules are prepared locally until deployment succeeds. Production mode initially denies app access, so authentication will continue to work while database setup is unfinished.

## References

- [Firestore Standard edition setup](https://firebase.google.com/docs/firestore/quickstart)
- [Firestore locations](https://firebase.google.com/docs/firestore/locations)
- [Firestore rule conditions](https://firebase.google.com/docs/firestore/security/rules-conditions)
