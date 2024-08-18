# SyncFreeBusy

### TL;DR

**SyncFreeBusy** is a JavaScript module I developed for synchronizing events between a primary and remote Google Calendar. It helps prevent double-booking by creating blocking events across calendars, ensuring each calendar accurately reflects your availability. The main goal is to synchronize free and busy times across multiple calendars, making your true availability clear. This module is particularly useful for managing multiple calendars and can be automated using Google Apps Script triggers.

**Setup Highlights**: Ensure that the primary calendar has write access to the remote calendar, deploy the script in Google Apps Script, and set up a time-driven trigger to automate synchronization.

---

### Introduction and Goal

**SyncFreeBusy** is a script I created to help synchronize events between a primary and remote Google Calendar. If you manage multiple calendars—whether personal, work, or project-specific—this tool ensures that your availability is consistently reflected across all of them. The primary objective is to make sure each participating calendar accurately displays your true availability, preventing scheduling conflicts and double-booking.

### How It Works

**SyncFreeBusy** operates by:

1. **Fetching Events:** The script retrieves events from both the primary and remote calendars over a defined time range.
2. **Creating Blocking Events:** For each event found in one calendar, a corresponding "blocking event" is created in the other calendar.
3. **Updating Free/Busy Status:** This ensures that all synchronized calendars accurately reflect your availability.
4. **Removing Obsolete or Expired Events:** The script periodically removes unnecessary blocking events to keep calendars clean.

### Use Cases

- **Multi-Calendar Management:** Useful for managing both personal and work calendars, ensuring that colleagues or friends can see when you're actually available.
- **Team Collaboration:** Helps maintain clarity around availability in team environments.
- **Event Coordination:** Assists in coordinating events across multiple calendars by providing a unified view of availability.

## Prerequisites

- Google Apps Script enabled.
- Access to Google Calendar for both the primary and remote calendars.

## Setup Instructions

### 1. Google Calendar Permissions

Ensure that the account associated with the primary calendar has **write access** to the remote calendar:

1. Go to Google Calendar.
2. Select **Settings and sharing** for the remote calendar.
3. Share it with the primary calendar’s email address, granting **edit permissions**.

### 2. Deploying the Script in Google Apps Script

- Open [Google Apps Script](https://script.google.com/).
- Create a new project and paste the `SyncFreeBusy` module code into the script editor.
- Save the project.

### 3. Setting Up a Time-Driven Trigger

- In the Apps Script project, go to `Triggers`.
- Set the function to `synchronizeCalendars`.
- Set the event source to `Time-driven` and choose a frequency.
- Save the trigger.

## Example Usage

```javascript
const sync = SyncFreeBusy({
    primaryCalendarId: 'primary@example.com',
    remoteCalendarId: 'remote@example.com',
    lookBackPeriod: 7 * 24 * 60 * 60 * 1000, // Optional: 1 week
    lookAheadPeriod: 60 * 24 * 60 * 60 * 1000 // Optional: 60 days
});

// Synchronize calendars
sync.synchronizeCalendars();

// Remove all blocking events
sync.removeBlockingEvents();
```

- `primaryCalendarId` and `remoteCalendarId` are required.
- `lookBackPeriod` and `lookAheadPeriod` are optional.

### Look-Back and Look-Ahead Periods

These parameters define the time range for synchronization:

- **Look-Back Period**: Defines how far back in time events are synchronized (default: 1 week).
- **Look-Ahead Period**: Defines how far into the future events are synchronized (default: 60 days).

## Error Handling

Basic error handling is included, logging any issues during synchronization. Check the `Logs` in Google Apps Script to monitor script performance.

## Disclaimer

**SyncFreeBusy** has been tested to the best of my ability, but like any software, it may contain bugs or unexpected behavior. I recommend testing the script with a shorter look-back and look-ahead period before applying it to your full calendar range. Users are responsible for ensuring the script works as intended in their environment.

## Support and Maintenance

If you encounter any issues, have questions, or would like to request new features, there are a couple of ways to get in touch:

- **File an Issue/Feature Request:** Open an issue or request a new feature on this GitHub repository.
- **Contact Me:** Reach out to me directly at [jasper@duizendstra.com](mailto:jasper@duizendstra.com).

## Contributing

If you'd like to contribute to this project, please fork the repository and submit a pull request. For major changes, open an issue to discuss what you'd like to change.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Credits

This module was inspired by best practices in JavaScript development, particularly the Module Pattern popularized by Douglas Crockford in *"JavaScript: The Good Parts"*.