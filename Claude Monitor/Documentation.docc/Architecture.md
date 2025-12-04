# Architecture Overview

Understand the structure and design patterns used in Claude Monitor.

## Overview

Claude Monitor follows the Model-View-ViewModel (MVVM) architecture pattern with a dedicated service layer for external interactions. The app is built with SwiftUI and uses Swift's modern concurrency features.

## Layer Diagram

```
┌─────────────────────────────────────────────────┐
│                    Views                         │
│  (SwiftUI views for UI presentation)            │
├─────────────────────────────────────────────────┤
│                 View Models                      │
│  (State management with @Observable)            │
├─────────────────────────────────────────────────┤
│                  Services                        │
│  (API communication, Keychain access)           │
├─────────────────────────────────────────────────┤
│                   Models                         │
│  (Data structures, Codable types)               │
└─────────────────────────────────────────────────┘
```

## Models

The model layer contains pure data structures:

- ``UsageLimit`` — Domain model representing a single usage limit with utilization and reset time
- ``UsageResponse`` — Codable struct matching the Anthropic API response format
- ``UsageBucket`` — Individual usage bucket from the API (utilization percentage and reset timestamp)

## Services

The service layer handles external interactions:

### ClaudeAPIService

A singleton service that communicates with the Anthropic API:
- Fetches usage data from the OAuth endpoint
- Validates tokens
- Handles HTTP errors and network failures

### KeychainService

A singleton service for secure token storage:
- Reads tokens from Claude Code's Keychain entry
- Manages the app's own Keychain entry for manual tokens
- Resolves which token to use based on user preference

### UsageDataService

A singleton actor that owns all business logic:
- Fetches usage data from the API and caches state
- Handles background refresh scheduling (every 60 seconds)
- Publishes state changes via `AsyncStream` for reactive updates
- Started at app launch by `AppDelegate`

### NotificationService

A singleton service for macOS desktop notifications:
- Sends notifications when usage crosses 75% (warning) or 90% (critical)
- Tracks notification state to prevent duplicate alerts
- Monitors session (5-hour) and weekly (7-day) limits
- Resets notification state when limits reset or usage drops

## View Models

### UsageViewModelProtocol

Defines the contract for status view models, enabling dependency injection and testability.

### UsageViewModel

A thin view model that bridges `UsageDataService` with SwiftUI:
- Subscribes to `UsageDataService.stateStream` for reactive updates
- Manages UI-only state (loading indicators, form fields)
- Forwards user actions to `UsageDataService`
- Shared via environment across all views

### MockUsageViewModel

A mock implementation for SwiftUI previews and testing with pre-configured states.

## Views

### Main Views

- **Claude_MonitorApp** — App entry point with MenuBarExtra scene
- **ContentView** — Generic view composing the popover UI

### Settings Views

- **SettingsView** — Token source selection and configuration
- **ManualTokenView** — Token input, validation, and storage
- **SettingsHelpView** — Help text and documentation links

### Usage Popover Views

- **UsageHeaderView** — Title and refresh button
- **UsageContentView** — Conditional content (data, error, empty, loading states)
- **UsageLimitRow** — Individual limit display with progress bar
- **ShadedProgressView** — Reusable colored progress bar
- **FooterView** — Token source and last updated timestamp
- **ActionButtonsView** — Settings and Quit buttons
- **ErrorView** — Error display with retry action
- **NoTokenView** — Prompt to configure token
- **EmptyStateView** — No data available state

## Error Handling

The app uses Swift's `LocalizedError` protocol for user-friendly error messages:

- ``APIError`` — API communication errors with recovery suggestions
- ``KeychainError`` — Keychain access errors

Each error type provides:
- `errorDescription` — General error category
- `failureReason` — Specific cause
- `recoverySuggestion` — Actionable steps (when applicable)

## Concurrency

The app uses Swift 6 structured concurrency:
- `actor` for `UsageDataService` to safely manage shared state
- `AsyncStream` for reactive state publishing from actor to view model
- `@MainActor` for view model isolation (required for SwiftUI)
- `async/await` for API calls and actor method calls
- `Sendable` conformance for thread-safe services

## Topics

### Services

- ``UsageDataService``
- ``ClaudeAPIService``
- ``KeychainService``
- ``NotificationService``

### View Models

- ``UsageViewModelProtocol``
- ``UsageViewModel``
- ``MockUsageViewModel``

### Error Types

- ``APIError``
- ``KeychainError``
