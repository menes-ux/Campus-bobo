# Home dashboard

The dashboard is the signed-in landing screen after email verification and profile loading. It uses the app's white background, yellow brand color, Poppins typography, and black text/actions. Soft orange, blue, and green communicate submitted, in-progress, and resolved states consistently across summary cards and report badges.

## What appears on Home

- A greeting using the saved profile name.
- A prominent **Report an incident** action.
- Personal counts for My reports, Submitted, In progress, and Resolved.
- The three most recent campus reports, with links to their details.
- Profile access and a **See all** link to campus reports.

Counts come from Firestore's incident stream and include only records whose `reportedBy` matches the signed-in UID. Recent activity includes campus reports from all permitted users. Loading or failed reads display placeholders rather than claiming a known count.

Tapping a summary card opens the Reports tab with **My reports** selected. Status cards also apply their status filter. **See all** opens the full campus list.

## Navigation

The bottom navigation contains **Home**, **Reports**, **Report**, and **Profile**. Home, Reports, and Profile preserve their state when switching tabs. Report opens the submission form and returns to the previous tab when finished. Android Back from Reports or Profile returns to Home.

Profile contains the saved account information, reporting guide, and sign-out control. The dashboard has no notification button or notification service.

## Check the design

1. Sign in with a verified account. Home should open automatically.
2. Compare the summary against your own records in Firestore.
3. Tap a status card and check the selected report filters.
4. Open a recent report, then return Home.
5. Try the Reports, Report, and Profile navigation items.
6. Submit a report and return Home to check the updated count and recent activity.

The dashboard is a dedicated UI stage in the project checklist. Owner editing/deletion, staff status updates, photos, and final submission work follow it.
