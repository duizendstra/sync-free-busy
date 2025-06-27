# SyncFreeBusy: Availability-Hub Variant

This variant uses a dedicated, secondary calendar to aggregate your availability from multiple source calendars. It keeps your primary calendars clean while creating a single, unified view of your true free/busy schedule.

### How It Works
- **What it does:** Reads events from a list of source calendars (e.g., Work, Personal, Team) and creates corresponding blocking events on a single, dedicated "hub" calendar.
- **Use Case:** Perfect for users who manage multiple calendars and want a single, shareable calendar that represents their total availability without cluttering their primary calendars.
- **Benefit:** Provides a clean, scalable, and private way to manage and share your availability.

## Setup
1.  **Create Hub Calendar:** Create a new, empty Google Calendar. This will be your "Availability Hub."
2.  **Permissions:** Ensure the script's account has "Make changes to events" permissions on this new hub calendar. The account only needs read access to the source calendars.
3.  **Configuration:** Open `src/Code.gs` and fill in the `sourceCalendarIds` array and the `destinationCalendarId` in the `CONFIG` object.
4.  **Deployment:** Use `clasp push` to deploy the script.
5.  **Trigger:** Set up a time-driven trigger to run the `runSync` function periodically.
