# Getting Started with Claude Monitor

Learn how to set up and use Claude Monitor to track your Claude API usage.

## Overview

Claude Monitor is a macOS menu bar application that displays your Claude API usage limits in real-time. It shows your current session usage, weekly limits, and model-specific quotas directly in your menu bar.

## Token Configuration

Claude Monitor needs an OAuth token to access your usage data. There are two ways to configure this:

### Using Claude Code (Recommended)

If you have [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed, Claude Monitor automatically detects and uses its OAuth token. This is the easiest setup:

1. Install Claude Code if you haven't already
2. Sign in to Claude Code with your Anthropic account
3. Launch Claude Monitor — it will automatically find your token

### Manual Token Entry

If you don't use Claude Code, you can manually enter an OAuth token:

1. Open Claude Monitor's Settings (click the menu bar icon, then "Settings...")
2. Select "Manual" as your token source
3. Paste your OAuth token (starts with `sk-ant-oat...`)
4. Click "Validate" to verify the token works
5. Click "Save" to store it securely in your Keychain

> Important: Only OAuth tokens work with the usage API. Regular API keys (`sk-ant-api...`) will not work.

## Reading Your Usage

The popover displays several usage metrics:

- **Current session** — Your 5-hour rolling usage limit
- **All models** — Your 7-day combined usage across all Claude models
- **Sonnet only** — Your 7-day usage for Claude Sonnet (if applicable)
- **Opus only** — Your 7-day usage for Claude Opus (if applicable)

Each limit shows:
- A progress bar with color coding (blue → yellow → orange → red)
- The percentage of your limit used
- Time until the limit resets

## Automatic Refresh

Claude Monitor automatically refreshes your usage data in the background approximately every 60 seconds using an energy-efficient system scheduler. When you open the popover, it will refresh immediately if the data is more than 20 seconds old.

You can also manually refresh by clicking the refresh button in the header.

## Usage Notifications

Claude Monitor sends desktop notifications when your usage is running low:

- **Warning** at 75% — A heads-up that you're using a significant portion of your limit
- **Critical** at 90% — An urgent alert that you're approaching your limit

Notifications are sent for session (5-hour) and weekly (7-day) limits. Each threshold triggers only once per limit period — you won't be spammed with repeated alerts.

> Tip: Make sure to allow notifications from Claude Monitor in System Settings when prompted.

## Topics

### Essentials

- <doc:Architecture>
