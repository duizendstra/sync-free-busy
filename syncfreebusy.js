/* global CalendarApp, console */

/**
 * SyncFreeBusy Module
 * 
* This module provides functionality to synchronize events between a primary and remote calendar by ensuring that 
* free and busy times are managed to prevent double-booking. The module encapsulates the logic required to 
 * fetch events, create blocking events, and remove obsolete or expired events.
 * 
 * The SyncFreeBusy module is built using the **Module Pattern**, a design pattern that promotes code organization 
 * by creating a self-contained unit with private and public methods and variables. This pattern was popularized 
 * in the early 2000s by JavaScript pioneers like **Douglas Crockford**, particularly through his book 
 * *"JavaScript: The Good Parts"*.
 * 
 * The Module Pattern allows for the encapsulation of private data and functionality, exposing only the necessary 
 * parts (public API) to the outside world. This ensures that the internal workings of the module remain hidden, 
 * promoting better maintainability and reducing the risk of conflicts in the global namespace.
 * 
 * @param {Object} params - The parameters for the SyncFreeBusy.
 * @param {string} params.primaryCalendarId - The ID of the primary calendar.
 * @param {string} params.remoteCalendarId - The ID of the remote calendar.
 * @param {number} [params.lookBackPeriod=604800000] - The look-back period in milliseconds (default is 1 week).
 * @param {number} [params.lookAheadPeriod=7776000000] - The look-ahead period in milliseconds (default is 3 months).
 * @returns {Object} - The SyncFreeBusy module exposing the `synchronizeCalendars` and `removeBlockingEvents` methods.
 */
const SyncFreeBusy = (params = {}) => {
    // Validate required parameters
    // Ensures that both primaryCalendarId and remoteCalendarId are provided in the params object.
    if (!params.primaryCalendarId || !params.remoteCalendarId) {
        throw new Error("primaryCalendarId and remoteCalendarId are required");
    }

    // Destructure and set default values from the params object
    const {
        primaryCalendarId,
        remoteCalendarId,
        lookBackPeriod = 7 * 24 * 60 * 60 * 1000, // Default look-back period: one week in milliseconds
        lookAheadPeriod = 60 * 24 * 60 * 60 * 1000, // Default look-ahead period: 60 days in milliseconds
    } = params;

    // Get the primary calendar object by its ID
    const primaryCalendar = CalendarApp.getCalendarById(primaryCalendarId);
    // Get the remote calendar object by its ID
    const remoteCalendar = CalendarApp.getCalendarById(remoteCalendarId);

    // Validate that the primary calendar was successfully retrieved
    if (!primaryCalendar) {
        throw new Error(`Primary calendar with ID ${primaryCalendarId} not found`);
    }

    // Validate that the remote calendar was successfully retrieved
    if (!remoteCalendar) {
        throw new Error(`Remote calendar with ID ${remoteCalendarId} not found`);
    }

    // Calculate the look-back and look-ahead dates based on the current date
    const now = new Date();  // Current date and time
    const lookBackDate = new Date(now.getTime() - lookBackPeriod); // Date/time from which to start looking back
    const lookAheadDate = new Date(now.getTime() + lookAheadPeriod); // Date/time up to which to look ahead


    /**
     * Fetches events from a specified calendar within a given time range, then separates them into past and active events.
     *
     * @param {Object} params - The parameters for fetching events.
     * @param {string} params.calendarId - The ID of the calendar from which to fetch events.
     * @param {Date} params.lookBackDate - The start date from which to fetch past events.
     * @param {Date} params.lookAheadDate - The end date up to which to fetch future events.
     * @returns {Object} - An object containing two arrays: `pastEvents` and `activeEvents`.
     */
    const fetchEventsFromCalendar = ({ calendarId, lookBackDate, lookAheadDate }) => {
        console.time(`Fetching events from calendar ${calendarId}`); // Start timing the fetch process

        // Attempt to retrieve the calendar object by its ID
        const calendar = CalendarApp.getCalendarById(calendarId);
        if (!calendar) {
            // Log an error if the calendar was not found and return an empty array
            console.error(`Calendar with ID ${calendarId} not found`);
            console.timeEnd(`Fetching events from calendar ${calendarId}`); // End timing with an error
            return [];
        }

        // Fetch events within the specified time range (from lookBackDate to lookAheadDate)
        const events = calendar.getEvents(lookBackDate, lookAheadDate);

        // Get the current date and time to determine if events are past or active
        const now = new Date();

        // Filter the events into past events (those that have ended) and active events (those that are ongoing or upcoming)
        const pastEvents = events.filter(event => event.getEndTime() < now);
        const activeEvents = events.filter(event => event.getEndTime() >= now);

        // Log the number of events fetched and the breakdown of past vs. active events
        console.log(`Fetched ${events.length} events from calendar ${calendarId} - Past events: ${pastEvents.length}, Active events: ${activeEvents.length}`);

        console.timeEnd(`Fetching events from calendar ${calendarId}`); // End timing the fetch process

        // Return an object containing the past and active events
        return { pastEvents, activeEvents };
    };

    /**
     * Removes expired blocking events from both the primary and remote calendars.
     * Expired blocking events are those created by this script in either calendar that have passed their end time.
     *
     * @param {Object} params - The parameters for removing expired blocking events.
     * @param {Array} params.pastPrimaryEvents - The past events from the primary calendar.
     * @param {Array} params.pastRemoteEvents - The past events from the remote calendar.
     * @param {string} params.primaryCalendarId - The ID of the primary calendar.
     * @param {string} params.remoteCalendarId - The ID of the remote calendar.
     */
    const removeExpiredBlockingEvents = ({ pastPrimaryEvents, pastRemoteEvents, primaryCalendarId, remoteCalendarId }) => {
        console.time('Removing expired blocking events'); // Start timing the removal process

        /**
         * Removes expired blocking events from a specific calendar.
         *
         * @param {Array} events - The list of past events to check for expiration.
         * @param {string} calendarId - The ID of the calendar that originally created these blocking events.
         */
        const removeForCalendar = (events, calendarId) => {
            const now = new Date(); // Get the current date and time

            // Filter the events to find those that should be deleted
            const eventsToDelete = events.filter(event => {
                const blockedTag = event.getTag('blocked');
                const sourceCalendarIdTag = event.getTag('sourceCalendarId');

                // Identify events that were created by this script and are now expired
                return blockedTag === 'true' && sourceCalendarIdTag === calendarId && event.getEndTime() < now;
            });

            // Delete the identified expired blocking events
            eventsToDelete.forEach(event => {
                event.deleteEvent();
            });

            // Log the number of expired blocking events removed from the calendar
            console.log(`Removed ${eventsToDelete.length} expired blocking events from calendar ${calendarId}`);
        };

        // Remove expired blocking events in the primary calendar that were created based on events from the remote calendar
        removeForCalendar(pastPrimaryEvents, remoteCalendarId);

        // Remove expired blocking events in the remote calendar that were created based on events from the primary calendar
        removeForCalendar(pastRemoteEvents, primaryCalendarId);

        console.timeEnd('Removing expired blocking events'); // End timing the removal process
    };

    /**
     * Removes obsolete blocking events from both the primary and remote calendars.
     * Obsolete blocking events are those where the original source event has been deleted or its time has changed.
     *
     * @param {Object} params - The parameters for removing obsolete blocking events.
     * @param {Array} params.primaryEvents - The active events from the primary calendar.
     * @param {Array} params.remoteEvents - The active events from the remote calendar.
     * @param {string} params.primaryCalendarId - The ID of the primary calendar.
     * @param {string} params.remoteCalendarId - The ID of the remote calendar.
     */
    const removeObsoleteBlockingEvents = ({ primaryEvents, remoteEvents, primaryCalendarId, remoteCalendarId }) => {
        console.time('Removing obsolete blocking events'); // Start timing the removal process

        const now = new Date(); // Get the current date and time

        /**
         * Creates a map of events for fast lookups by a unique key (combination of event ID and start time).
         * This map will help quickly find corresponding events when checking for obsolescence.
         *
         * @param {Array} events - The list of events to map.
         * @returns {Map} - A map where the key is the unique event ID and start time, and the value is the event object.
         */
        const createEventMap = (events) => {
            const eventMap = new Map();
            events.forEach(event => {
                const uniqueEventId = `${event.getId()}_${event.getStartTime().getTime()}`;
                eventMap.set(uniqueEventId, event);
            });
            return eventMap;
        };

        // Create maps for quick lookups of the primary and remote events by their unique IDs and start times
        const primaryEventMap = createEventMap(primaryEvents);
        const remoteEventMap = createEventMap(remoteEvents);

        /**
         * Removes obsolete blocking events from the calendar.
         * Obsolete events are those that no longer match their source events in terms of existence or time.
         *
         * @param {Array} events - The list of events to check for obsolescence.
         * @param {Map} sourceEventMap - A map of source events to check against.
         * @param {string} calendarId - The ID of the calendar where the events are being removed.
         * @param {string} sourceCalendarId - The ID of the calendar from which the original events originated.
         */
        const removeObsolete = (events, sourceEventMap, calendarId, sourceCalendarId) => {
            const eventsToDelete = events.filter(event => {
                const blockedTag = event.getTag('blocked');
                const sourceEventId = event.getTag('sourceEventId');
                const sourceCalendarIdTag = event.getTag('sourceCalendarId');

                // Ensure the event was created by this script and corresponds to the source calendar
                if (blockedTag === 'true' && sourceCalendarIdTag === sourceCalendarId) {
                    const uniqueEventId = `${sourceEventId}_${event.getStartTime().getTime()}`;
                    const sourceEvent = sourceEventMap.get(uniqueEventId);

                    // Mark as obsolete if no matching source event exists or if event times don't match
                    if (!sourceEvent) {
                        return true;
                    }

                    const sourceStartTime = sourceEvent.getStartTime().getTime();
                    const sourceEndTime = sourceEvent.getEndTime().getTime();
                    const eventStartTime = event.getStartTime().getTime();
                    const eventEndTime = event.getEndTime().getTime();

                    // If the times don't match, it's obsolete
                    return sourceStartTime !== eventStartTime || sourceEndTime !== eventEndTime;
                }

                return false;
            });

            // Delete the identified obsolete events
            eventsToDelete.forEach(event => {
                console.log(`Deleting obsolete event: ${event.getTitle()} (Start: ${event.getStartTime()}, End: ${event.getEndTime()})`);
                event.deleteEvent();
            });

            // Log the number of obsolete blocking events removed
            console.log(`Removed ${eventsToDelete.length} obsolete blocking events from calendar ${calendarId}`);
        };

        // Remove obsolete events in the primary calendar that were created based on remote events
        removeObsolete(primaryEvents, remoteEventMap, primaryCalendarId, remoteCalendarId);

        // Remove obsolete events in the remote calendar that were created based on primary events
        removeObsolete(remoteEvents, primaryEventMap, remoteCalendarId, primaryCalendarId);

        console.timeEnd('Removing obsolete blocking events'); // End timing the removal process
    };

    /**
     * Creates blocking events in both the primary and remote calendars based on the events from the other calendar.
     *
     * This function ensures that no double-booking occurs by creating blocking events in one calendar if the other
     * calendar has an event at the same time.
     *
     * @param {Object} params - The parameters for creating blocking events.
     * @param {Array} params.primaryEvents - The active events from the primary calendar.
     * @param {Array} params.remoteEvents - The active events from the remote calendar.
     * @param {GoogleAppsScript.Calendar.Calendar} params.primaryCalendar - The primary calendar object.
     * @param {GoogleAppsScript.Calendar.Calendar} params.remoteCalendar - The remote calendar object.
     * @param {string} params.primaryCalendarId - The ID of the primary calendar.
     * @param {string} params.remoteCalendarId - The ID of the remote calendar.
     */
    const createBlockingEvents = ({ primaryEvents, remoteEvents, primaryCalendar, remoteCalendar, primaryCalendarId, remoteCalendarId }) => {
        console.time('Creating blocking events'); // Start timing the process of creating blocking events

        /**
         * Creates a blocking event in the specified calendar based on a source event from another calendar.
         *
         * @param {GoogleAppsScript.Calendar.Calendar} calendar - The calendar where the blocking event will be created.
         * @param {GoogleAppsScript.Calendar.CalendarEvent} event - The source event that requires blocking.
         * @param {string} sourceCalendarId - The ID of the calendar from which the event originated.
         * @param {boolean} isPersonalCalendar - Whether the target calendar is a personal calendar (affects the event title).
         */
        const createBlockingEvent = (calendar, event, sourceCalendarId, isPersonalCalendar) => {
            // Set the title of the blocking event based on whether it's a personal calendar
            const title = isPersonalCalendar
                ? `${sourceCalendarId}: ${event.getTitle()}`
                : "Blocked by remote calendar";

            // Create a new event in the target calendar with the blocking title and same start/end times
            const newEvent = calendar.createEvent(
                title,
                event.getStartTime(),
                event.getEndTime()
            );

            // Tag the new event to indicate it's a blocking event and reference the source event
            newEvent.setTag('blocked', 'true');
            newEvent.setTag('sourceEventId', event.getId());
            newEvent.setTag('sourceCalendarId', sourceCalendarId);

            // Log the creation of the blocking event
            console.log(`Created blocking event on ${event.getStartTime().toDateString()} in calendar ${calendar.getId()} from source calendar ${sourceCalendarId}`);
        };

        /**
         * Creates blocking events in the target calendar for events in the source calendar.
         *
         * @param {Array} sourceEvents - The list of source events that might require blocking.
         * @param {GoogleAppsScript.Calendar.Calendar} targetCalendar - The calendar where blocking events will be created.
         * @param {string} sourceCalendarId - The ID of the source calendar from which the events originate.
         * @param {boolean} isPersonalCalendar - Whether the target calendar is a personal calendar.
         * @param {string} targetCalendarId - The ID of the target calendar where blocking events will be created.
         */
        const createBlocks = (sourceEvents, targetCalendar, sourceCalendarId, isPersonalCalendar, targetCalendarId) => {
            const now = new Date(); // Current date and time

            // Filter the source events to determine which need blocking
            const eventsToBlock = sourceEvents.filter(sourceEvent => {
                // Ignore events that have already ended
                if (sourceEvent.getEndTime() < now) {
                    return false;
                }

                // Skip events that are already blocking events created by this script
                const isAlreadyBlocked = sourceEvent.getTag('blocked') === 'true' && sourceEvent.getTag('sourceCalendarId') === targetCalendarId;
                if (isAlreadyBlocked) {
                    console.log(`Skipping event "${sourceEvent.getTitle()}" as it is already a blocking event.`);
                    return false;
                }

                // Check if this event's time slot is already blocked in the target calendar
                const isBlocked = targetCalendar.getEvents(sourceEvent.getStartTime(), sourceEvent.getEndTime()).some(targetEvent => {
                    const blockedTag = targetEvent.getTag('blocked');
                    const targetSourceEventId = targetEvent.getTag('sourceEventId');
                    const targetSourceCalendarIdTag = targetEvent.getTag('sourceCalendarId');

                    // Ensure that the event isn't blocked by another blocking event created by the script
                    const isSameCalendarBlock = blockedTag === 'true' && targetSourceCalendarIdTag === sourceCalendarId;
                    return isSameCalendarBlock && targetSourceEventId === sourceEvent.getId();
                });

                // Include the event only if it is not already blocked
                return !isBlocked;
            });

            // Create blocking events for each event that needs blocking
            eventsToBlock.forEach(sourceEvent => {
                console.log(`Blocking time in ${targetCalendarId} for source event: ${sourceEvent.getTitle()} (Date: ${sourceEvent.getStartTime().toDateString()})`);

                createBlockingEvent(targetCalendar, sourceEvent, sourceCalendarId, isPersonalCalendar);
            });
        };

        // Create blocking events in the primary calendar based on events from the remote calendar
        createBlocks(remoteEvents, primaryCalendar, remoteCalendarId, false, primaryCalendarId);

        // Create blocking events in the remote calendar based on events from the primary calendar
        createBlocks(primaryEvents, remoteCalendar, primaryCalendarId, true, remoteCalendarId);

        console.timeEnd('Creating blocking events'); // End timing the process of creating blocking events
    };


    /**
     * Synchronizes events between a primary and remote calendar, removing expired and obsolete blocking events,
     * and creating new blocking events as necessary.
     *
     * The process involves:
     * 1. Fetching past and active events from both calendars.
     * 2. Removing expired blocking events that are no longer relevant.
     * 3. Removing obsolete blocking events where the original event has changed or been deleted.
     * 4. Creating new blocking events in both calendars to prevent double-booking.
     */
    const synchronizeCalendars = () => {
        console.time('Total Synchronization Time');

        try {
            console.log(`Starting synchronization from ${lookBackDate.toDateString()} to ${lookAheadDate.toDateString()}`);

            // Fetch events from both calendars
            const { pastEvents: pastPrimaryEvents, activeEvents: activePrimaryEvents } = fetchEventsFromCalendar({
                calendarId: primaryCalendarId,
                lookBackDate,
                lookAheadDate
            });

            const { pastEvents: pastRemoteEvents, activeEvents: activeRemoteEvents } = fetchEventsFromCalendar({
                calendarId: remoteCalendarId,
                lookBackDate,
                lookAheadDate
            });

            // Remove expired blocking events that are no longer relevant
            removeExpiredBlockingEvents({
                pastPrimaryEvents,
                pastRemoteEvents,
                primaryCalendarId,
                remoteCalendarId
            });

            // Remove obsolete blocking events where the original event has been deleted or changed
            removeObsoleteBlockingEvents({
                primaryEvents: activePrimaryEvents,
                remoteEvents: activeRemoteEvents,
                primaryCalendarId,
                remoteCalendarId
            });

            // Create new blocking events to prevent double-booking
            createBlockingEvents({
                primaryEvents: activePrimaryEvents,
                remoteEvents: activeRemoteEvents,
                primaryCalendar,
                remoteCalendar,
                primaryCalendarId,
                remoteCalendarId
            });

            console.log('Synchronization complete');
            console.timeEnd('Total Synchronization Time');
        } catch (error) {
            console.error(`Synchronization error for calendars ${primaryCalendarId} and ${remoteCalendarId}:`, error);
            throw error;  // Re-throw the error for higher-level handling
        }
    };

    /**
     * Removes all blocking events (both past and future) created by the script from the primary and remote calendars.
     * This function iterates over the events in both the primary and remote calendars, identifies events marked as 
     * "blocked" by this script, and removes them.
     */
    const removeBlockingEvents = () => {
        console.time('Removing all blocking events');

        /**
         * Removes all events in the given array that were created as blocking events by the script.
         *
         * @param {Array} events - The list of events to remove.
         * @param {string} sourceCalendarId - The ID of the calendar from which the blocking events originated.
         * @param {string} calendarId - The ID of the calendar where the blocking events are being removed.
         */
        const removeEventsForCalendar = (events, sourceCalendarId, calendarId) => {
            const removedEvents = []; // Array to track removed events

            // Filter and delete only the events that were created by the script (identified by specific tags)
            events.forEach(event => {
                const blockedTag = event.getTag('blocked');
                const sourceCalendarIdTag = event.getTag('sourceCalendarId');

                if (blockedTag === 'true' && sourceCalendarIdTag === sourceCalendarId) {
                    event.deleteEvent(); // Remove the event
                    removedEvents.push(event); // Add the removed event to the tracking array
                }
            });

            // Log the number of blocking events actually removed from the calendar
            console.log(`Removed ${removedEvents.length} blocking events from calendar ${calendarId}`);
        };

        // Fetch past and active events from the primary calendar
        const { pastEvents: pastPrimaryEvents, activeEvents: activePrimaryEvents } = fetchEventsFromCalendar({
            calendarId: primaryCalendarId,
            lookBackDate,
            lookAheadDate
        });

        // Fetch past and active events from the remote calendar
        const { pastEvents: pastRemoteEvents, activeEvents: activeRemoteEvents } = fetchEventsFromCalendar({
            calendarId: remoteCalendarId,
            lookBackDate,
            lookAheadDate
        });

        // Remove all blocking events from the primary calendar
        removeEventsForCalendar([...pastPrimaryEvents, ...activePrimaryEvents], remoteCalendarId, primaryCalendarId);

        // Remove all blocking events from the remote calendar
        removeEventsForCalendar([...pastRemoteEvents, ...activeRemoteEvents], primaryCalendarId, remoteCalendarId);

        console.timeEnd('Removing all blocking events');
    };

    return Object.freeze({
        // Return the `synchronizeCalendars` function as a method of the returned object.
        // This method handles the synchronization of events between the primary and remote calendars.
        synchronizeCalendars,

        // Return the `removeBlockingEvents` function as a method of the returned object.
        // This method removes all blocking events created by the script from both calendars.
        removeBlockingEvents
    });
};
