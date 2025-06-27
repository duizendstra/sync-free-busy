# SyncFreeBusy Project

This repository contains the source code and development environment for **SyncFreeBusy**, a Google Apps Script project for synchronizing availability across multiple Google Calendars.

The goal of this project is to prevent double-booking and provide a clear, unified view of your true availability, even when you manage separate calendars for work, personal life, and other commitments.

## How This Repository is Organized

This project is organized into a structured monorepo to keep the code, documentation, and automation tools clean and maintainable.

*   **`/products`**: This is where the deployable code lives. It contains the two distinct product variants:
    *   **`direct-link`**: A simple, two-way sync between two calendars.
    *   **`availability-hub`**: An advanced solution that uses a dedicated calendar to aggregate availability from multiple sources.

*   **`/factory`**: This directory contains the project's automation framework, powered by `go-task`. It includes all the commands for deploying, analyzing, and managing the products.

*   **`/docs`**: This directory holds all internal project documentation, including the product backlog (`PBIs`), sprint plans, and other development-related artifacts.

## Getting Started

1.  **Explore the Products:** Review the `README.md` files inside each of the `products/` subdirectories for specific setup instructions.
2.  **Use the Factory:** Use the `task` command to see a list of available automation tasks for managing the project.
