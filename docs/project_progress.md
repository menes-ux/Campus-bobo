# Canvas project checklist

## Implemented

- [x] Flutter Android app with a consistent white, yellow, and black design and bundled Poppins fonts.
- [x] Registration, login, logout, session restoration, and ALU student email verification.
- [x] Provider session state and separation between screens, state, and Firebase repositories.
- [x] Firestore profiles with a default student role and protected role assignment.
- [x] Incident submission with title, category, description, location, validation, and a report reference.
- [x] Initial submitted status, server timestamps, and report ownership rules.

## Remaining app work

1. **Browse reports:** show Firestore reports, search by text, and filter by category and status.
2. **Report details and tracking:** display the report, its location, and progress through submitted, in progress, and resolved.
3. **Complete CRUD:** let owners edit or delete their submitted reports with appropriate access rules and confirmation.
4. **Staff workflow:** use an authorized staff account to review reports and update statuses; enforce permissions in Firestore rules.
5. **Incident photos:** set up Firebase Storage, select an optional photo, upload it, and display it with its report. Storage requires the Blaze billing setup discussed earlier.
6. **Final checks:** run the required student and staff workflows on Android and review validation, loading/error feedback, and access controls.

## Remaining submission work

- [ ] Capture screenshots of the main workflows.
- [ ] Write the technical report covering architecture, Firebase schema, state management, user roles, security, UI decisions, testing, challenges, and lessons learned.
- [ ] Include diagrams and APA or IEEE references.
- [ ] Record a 7-10 minute demonstration showing authentication, submission, browsing/filtering, and a staff status update.
- [ ] Include the GitHub repository and video links in the report.
- [ ] Export and submit the report as `StudentName_Assignment2.pdf` through Canvas.

## Next checkpoint

Try submitting a report with a verified account and confirm the document under Firestore's `incidents` collection. Then build report browsing and filtering.
