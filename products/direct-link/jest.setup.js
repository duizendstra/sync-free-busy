// This file mocks the Google Apps Script global objects
// to allow Jest to run tests on the code locally.

const mockCalendar = {
    createEvent: jest.fn().mockReturnThis(),
    getEvents: jest.fn(() => []),
    setTag: jest.fn().mockReturnThis(),
    deleteEvent: jest.fn(),
  };
  
  const mockCalendarApp = {
    getCalendarById: jest.fn(() => mockCalendar),
    GuestStatus: {
      NO: 'NO'
    },
  };
  
  // Assign the mock to the global object to be available in all test files
  global.CalendarApp = mockCalendarApp;
