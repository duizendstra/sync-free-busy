/**
 * Configuration for the Availability-Hub sync.
 *
 * @typedef {Object} Config
 * @property {string[]} sourceCalendarIds - An array of Google Calendar IDs to read events from.
 * @property {string} destinationCalendarId - The ID of the dedicated calendar where blocking events will be created.
 * @property {number} lookBackDays - How many days in the past to sync.
 * @property {number} lookAheadDays - How many days in the future to sync.
 * @property {string} blockingEventTitle - The title for the created blocking events.
 */
const CONFIG = {
  sourceCalendarIds: [
    'work@example.com',       // <-- Add your source calendar IDs here
    'personal@example.com'
  ],
  destinationCalendarId: 'hub-calendar@example.com', // <-- Set your destination hub calendar ID
  lookBackDays: 7,
  lookAheadDays: 60,
  blockingEventTitle: 'Busy'
};

/**
 * Main function to be called by the trigger.
 */
function runSync() {
  console.log('Starting Availability-Hub sync...');
  const now = new Date();
  const lookBackDate = new Date(now.getTime() - (CONFIG.lookBackDays * 24 * 60 * 60 * 1000));
  const lookAheadDate = new Date(now.getTime() + (CONFIG.lookAheadDays * 24 * 60 * 60 * 1000));

  const destinationCal = CalendarApp.getCalendarById(CONFIG.destinationCalendarId);
  if (!destinationCal) {
    console.error('Destination calendar not found. Please check the ID.');
    return;
  }

  // Get all existing blocking events from the hub calendar
  const existingBlockingEvents = destinationCal.getEvents(lookBackDate, lookAheadDate, { search: 'sync-event' });
  const existingEventMap = new Map(existingBlockingEvents.map(event => [event.getTag('sourceEventId'), event]));

  // Process each source calendar
  CONFIG.sourceCalendarIds.forEach(sourceId => {
    const sourceCal = CalendarApp.getCalendarById(sourceId);
    if (!sourceCal) {
      console.warn(`Could not find source calendar: ${sourceId}. Skipping.`);
      return;
    }
    _processSourceCalendar(sourceCal, destinationCal, lookBackDate, lookAheadDate, existingEventMap);
  });

  // After processing all sources, what's left in the map is obsolete.
  existingEventMap.forEach(obsoleteEvent => {
    try {
      obsoleteEvent.deleteEvent();
    } catch (e) {
      console.error(`Failed to delete obsolete event: ${e.toString()}`);
    }
  });

  console.log('Availability-Hub sync finished.');
}

/**
 * Reads events from a source calendar and syncs them to the destination calendar.
 * @param {GoogleAppsScript.Calendar.Calendar} sourceCal
 * @param {GoogleAppsScript.Calendar.Calendar} destinationCal
 * @param {Date} startTime
 * @param {Date} endTime
 * @param {Map<string, GoogleAppsScript.Calendar.CalendarEvent>} existingEventMap
 */
function _processSourceCalendar(sourceCal, destinationCal, startTime, endTime, existingEventMap) {
  const sourceEvents = sourceCal.getEvents(startTime, endTime);

  sourceEvents.forEach(sourceEvent => {
    if (sourceEvent.isAllDayEvent() || sourceEvent.getMyStatus() === CalendarApp.GuestStatus.NO) {
      return; // Skip
    }

    const sourceEventId = sourceEvent.getId();
    if (existingEventMap.has(sourceEventId)) {
      // This event is still valid, so remove it from the deletion map.
      existingEventMap.delete(sourceEventId);
    } else {
      // This is a new event, create a blocking event for it.
      const newBlockingEvent = destinationCal.createEvent(CONFIG.blockingEventTitle, sourceEvent.getStartTime(), sourceEvent.getEndTime(), {
        description: `This is a blocking event. Source: ${sourceCal.getName()}.\n sync-event`
      });
      newBlockingEvent.setTag('sourceEventId', sourceEventId);
      newBlockingEvent.setTag('sourceCalendarId', sourceCal.getId());
      newBlockingEvent.setVisibility(CalendarApp.EventVisibility.PRIVATE);
    }
  });
}
