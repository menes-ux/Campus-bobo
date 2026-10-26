# Canvas project checklist

## Implemented

- [x] Flutter Android app with a consistent white, yellow, and black design and bundled Poppins fonts.
- [x] Registration, login, logout, session restoration, and ALU student email verification.
- [x] Provider session state and separation between screens, state, and Firebase repositories.
- [x] Firestore profiles with a default student role and protected role assignment.
- [x] Incident submission with title, category, description, location, validation, and a report reference.
- [x] Initial submitted status, server timestamps, and report ownership rules.
- [x] Live report browsing, text search, category/status filters, and My reports.
- [x] Report details with live status progress, location, dates, and reference.

## Remaining app work

1. **Complete CRUD:** let owners edit or delete their submitted reports with appropriate access rules and confirmation.
2. **Staff workflow:** use an authorized staff account to review reports and update statuses; enforce permissions in Firestore rules.
3. **Incident photos:** set up Firebase Storage, select an optional photo, upload it, and display it with its report. Storage requires the Blaze billing setup discussed earlier.
4. **Final checks:** run the required student and staff workflows on Android and review validation, loading/error feedback, and access controls.

## Remaining submission work

- [ ] Capture screenshots of the main workflows.
- [ ] Write the technical report covering architecture, Firebase schema, state management, user roles, security, UI decisions, testing, challenges, and lessons learned.
- [ ] Include diagrams and APA or IEEE references.
- [ ] Record a 7-10 minute demonstration showing authentication, submission, browsing/filtering, and a staff status update.
- [ ] Include the GitHub repository and video links in the report.
- [ ] Export and submit the report as `StudentName_Assignment2.pdf` through Canvas.

## Next checkpoint

Try browsing, searching, and opening a saved report. Then add owner editing/deletion and the staff status workflow.
