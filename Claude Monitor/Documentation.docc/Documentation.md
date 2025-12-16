# ``Claude_Monitor``

A macOS menu bar app that displays your Claude API usage limits in real-time.

## Overview

Claude Monitor sits in your menu bar and shows your current Claude API usage at a glance. It displays session limits, weekly quotas, and model-specific usage with visual progress bars and countdown timers until limits reset.

The app can automatically detect your OAuth token from Claude Code, or you can manually configure a token in settings.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Architecture>

### Models

- ``UsageLimit``
- ``UsageResponse``
- ``UsageBucket``

### Services

- ``ClaudeAPIService``
- ``KeychainService``
- ``UsageDataService``
- ``NotificationService``
- ``TokenSource``

### View Models

- ``UsageViewModelProtocol``
- ``UsageViewModel``
- ``MockUsageViewModel``
- ``TokenValidationResult``

### Views

- ``ContentView``
- ``SettingsView``
- ``ManualTokenView``
- ``SettingsHelpView``

### Usage Popover Components

- ``UsageHeaderView``
- ``UsageContentView``
- ``UsageLimitRow``
- ``ShadedProgressView``
- ``FooterView``
- ``ActionButtonsView``
- ``ErrorView``
- ``NoTokenView``
- ``EmptyStateView``

### Error Handling

- ``APIError``
- ``KeychainError``
