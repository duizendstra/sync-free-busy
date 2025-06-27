# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-27
### Added
- **`availability-hub` variant**: A new, scalable synchronization method that uses a dedicated secondary calendar to aggregate availability from multiple source calendars. This keeps primary calendars clean.
- New project structure to support multiple, isolated product variants inside a `products` directory.

### Changed
- **Project Refactor**: The entire project has been restructured into a multi-package monorepo format.
- The original synchronization logic is now the **`direct-link` variant**, isolated in its own folder.
- Updated documentation to guide users to the appropriate variant.

## [0.0.1] - 2024-08-18
### Added
- Initial release of **SyncFreeBusy**.
- Synchronization of events between primary and remote Google Calendars.
- Creation of "blocking events" to prevent double-booking across calendars.
- Automatic removal of obsolete or expired blocking events.
- Support for configurable look-back and look-ahead periods for event synchronization.
- Basic error handling with logging capabilities in Google Apps Script.
- Setup instructions including Google Calendar permissions and time-driven triggers.
- Example usage documentation.
- Support and maintenance contact information.

[0.0.1]: https://github.com/duizendstra/sync-free-busy/releases/tag/v0.0.1
