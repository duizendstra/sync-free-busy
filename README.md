# SyncFreeBusy Project

This repository contains the source code and documentation for **SyncFreeBusy**, a Google Apps Script project for synchronizing availability across multiple Google Calendars.

The goal of this project is to prevent double-booking and provide a clear, unified view of your true availability, even when you manage separate calendars for work, personal life, and other commitments.

## The Products

This project contains two distinct "products" or variants, each designed for a different use case. They are located in the `products` directory. Choose the one that best fits your needs.

### 1. `direct-link`
- **What it is:** A simple, direct synchronization between two calendars.
- **How it works:** Events from your work calendar are mirrored as blocking events in your personal calendar, and vice-versa.
- **Best for:** Users who want a straightforward, two-way sync and don't mind seeing blocking events integrated directly into their primary calendars.
- **[Go to direct-link variant](./products/direct-link/README.md)**

### 2. `availability-hub`
- **What it is:** An advanced, scalable solution that uses a dedicated calendar to aggregate your availability.
- **How it works:** Events from all your source calendars (work, personal, etc.) are used to create blocking events on a single, separate "hub" calendar. Your primary calendars remain untouched and clean.
- **Best for:** Power users who manage multiple calendars and want a single, shareable source of truth for their availability.
- **[Go to availability-hub variant](./products/availability-hub/README.md)**

## Contributing
If you'd like to contribute, please fork the repository and submit a pull request. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
