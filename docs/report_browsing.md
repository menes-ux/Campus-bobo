# Report browsing and details

## Try the workflow

1. Sign in and tap **Browse reports** on the account screen.
2. Check that submitted reports appear newest first.
3. Search by a word from a title, description, location, or report reference.
4. Choose a category or status. Filters combine with the search text.
5. Tap **My reports** to show only reports belonging to the current account.
6. Tap **Reset filters** to return to the full list.
7. Tap a report card to view its description, location, dates, reference, and status progress.
8. Use **New report** to submit from the browsing screen. Tap **Done** after submission to return to the list, which updates automatically.

An empty collection shows **No reports yet**. A search or filter with no results shows **No matching reports**. Failed reads offer retry, and a removed report shows **Report unavailable** in the details screen.

## Data and state

`FirestoreIncidentRepository.watchAll()` listens to the `incidents` collection ordered by `createdAt` descending. `watchById()` listens to one report for the details page. Firestore timestamps are converted to Dart dates by the repository.

`IncidentListController` manages the loaded reports, search text, filters, and loading/error feedback through Provider. Search and filtering happen in memory over the loaded collection. This keeps the coursework implementation straightforward and needs no custom composite indexes or external search service. A larger deployment would need pagination and a different search approach.

The details screen reads the current status from its live document. The progress view reflects submitted, in progress, and resolved. Staff status changes will be implemented in a later stage.

## Access

Report reads and queries require a verified ALU student email and an existing student or staff profile. Reports contain reporter UIDs, without duplicating their email addresses. The report routes hide their contents and dispose their subscriptions if the signed-in account changes or signs out.

Owner editing/deletion and staff status changes remain disabled in the deployed rules until their workflows are added.

## Checks

```powershell
flutter analyze
flutter test test
```

The tests cover combined filters, live list updates, stream errors and retry, search/reset controls, details navigation, missing reports, and hiding data after sign-out. Fixture records are used only in tests; normal browsing uses Firestore.
