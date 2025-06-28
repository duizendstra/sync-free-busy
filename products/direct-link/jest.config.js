/** @type {import('jest').Config} */
const config = {
    // Automatically clear mock calls, instances, contexts and results before every test
    clearMocks: true,
  
    // The test environment that will be used for testing
    testEnvironment: "node",
  
    // A path to a module which exports an async function that is triggered once before all test suites
    setupFilesAfterEnv: ["<rootDir>/jest.setup.js"],
  };
  
  module.exports = config;
