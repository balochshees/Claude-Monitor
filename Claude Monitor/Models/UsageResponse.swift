//
//  UsageResponse.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import Foundation

/// The raw JSON response from the Anthropic OAuth usage API endpoint.
///
/// This struct maps directly to the JSON returned by `GET /api/oauth/usage`.
/// Each property represents a different usage bucket that may or may not be
/// present depending on the user's plan and activity.
///
/// ## API Endpoint
/// ```
/// GET https://api.anthropic.com/api/oauth/usage
/// Headers:
///   Authorization: Bearer {token}
///   anthropic-beta: oauth-2025-04-20
/// ```
///
/// ## Example Response
/// ```json
/// {
///   "five_hour": { "utilization": 6.0, "resets_at": "2025-11-04T04:59:59+00:00" },
///   "seven_day": { "utilization": 35.0, "resets_at": "2025-11-06T03:59:59+00:00" },
///   "seven_day_opus": { "utilization": 0.0, "resets_at": null }
/// }
/// ```
struct UsageResponse: Codable {
  /// The 5-hour rolling session limit.
  let fiveHour: UsageBucket?

  /// The 7-day combined usage limit across all models.
  let sevenDay: UsageBucket?

  /// The 7-day usage limit for OAuth applications.
  let sevenDayOauthApps: UsageBucket?

  /// The 7-day usage limit specifically for Claude Opus.
  let sevenDayOpus: UsageBucket?

  /// The 7-day usage limit specifically for Claude Sonnet.
  let sevenDaySonnet: UsageBucket?

  enum CodingKeys: String, CodingKey {
    case fiveHour = "five_hour"
    case sevenDay = "seven_day"
    case sevenDayOauthApps = "seven_day_oauth_apps"
    case sevenDayOpus = "seven_day_opus"
    case sevenDaySonnet = "seven_day_sonnet"
  }
}

/// A single usage bucket from the API response.
///
/// Each bucket contains the current utilization percentage and an optional
/// reset timestamp. The utilization is returned as a percentage (0-100),
/// not a fraction.
struct UsageBucket: Codable {
  /// The current utilization as a percentage (0-100).
  ///
  /// A value of 50.0 means 50% of the limit has been consumed.
  /// This differs from ``UsageLimit/utilization`` which uses 0.0-1.0.
  let utilization: Double

  /// The ISO 8601 timestamp when this limit will reset, or `nil` if not applicable.
  let resetsAt: String?

  enum CodingKeys: String, CodingKey {
    case utilization
    case resetsAt = "resets_at"
  }
}
