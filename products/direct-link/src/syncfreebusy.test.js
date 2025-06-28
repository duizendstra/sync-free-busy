
// This line is necessary to load the script file in the Jest environment.
const fs = require('fs');
const path = require('path');
eval(fs.readFileSync(path.join(__dirname, 'syncfreebusy.js'), 'utf8'));

// We defined 'CalendarApp' in our jest.setup.js file, so it's available globally.

// Use require to import the function directly from the file.
const { SyncFreeBusy } = require('./syncfreebusy.js');

// We defined 'CalendarApp' in our jest.setup.js file, so it's available globally.

describe('SyncFreeBusy Factory', () => {
  // Test case 1: Ensure it throws an error if the primary calendar ID is missing.
  it('should throw an error if primaryCalendarId is not provided', () => {
    // We expect the function call to throw an error.
    // The function must be wrapped in another function for `toThrow` to work.
    expect(() => {
      SyncFreeBusy({ remoteCalendarId: 'remote@example.com' });
    }).toThrow('primaryCalendarId and remoteCalendarId are required');
  });

  // Test case 2: Ensure it throws an error if the remote calendar ID is missing.
  it('should throw an error if remoteCalendarId is not provided', () => {
    expect(() => {
      SyncFreeBusy({ primaryCalendarId: 'primary@example.com' });
    }).toThrow('primaryCalendarId and remoteCalendarId are required');
  });

  // Test case 3: Ensure it does NOT throw an error when all required IDs are present.
  it('should not throw an error when required parameters are provided', () => {
    expect(() => {
      SyncFreeBusy({
        primaryCalendarId: 'primary@example.com',
        remoteCalendarId: 'remote@example.com',
      });
    }).not.toThrow();
  });
});

try {
    module.exports = {
      SyncFreeBusy
    };
  } catch (e) {
    // We're in the Google Apps Script environment, not Node.js.
    // This error is expected and can be ignored.
  }
