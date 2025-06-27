# SyncFreeBusy: Direct-Link Variant

This variant synchronizes events directly between two calendars, such as a personal and a work calendar. It creates "blocking events" in each calendar to reflect the commitments of the other.

### How It Works
- **What it does:** Reads events from Calendar A and creates corresponding blocking events in Calendar B, and vice-versa.
- **Use Case:** Ideal for users who want a simple, direct, two-way sync and prefer to see all blocking events integrated directly within their primary calendars.
- **Trade-off:** This method can add visual clutter to your primary calendars, as the blocking events are mixed in with your actual appointments.

## Setup
1.  **Permissions:** Ensure the primary calendar account has "Make changes to events" permissions on the remote calendar.
2.  **Configuration:** Open `src/Code.gs` and fill in the `primaryCalendarId` and `remoteCalendarId` in the `CONFIG` object.
3.  **Deployment:** Use `clasp push` to deploy the script to your Google Apps Script project.
4.  **Trigger:** In the Apps Script editor, set up a time-driven trigger to run the `runSync` function periodically (e.g., every 15 minutes).
