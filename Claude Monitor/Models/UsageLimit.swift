//
//  UsageLimit.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import Foundation

/// A usage limit representing a specific quota bucket from the Claude API.
///
/// Usage limits track how much of a particular quota has been consumed
/// and when it will reset. The app displays multiple limits including
/// session (5-hour), weekly, and model-specific quotas.
///
/// ## Example
/// ```swift
/// let limit = UsageLimit(
///   id: "five_hour",
///   title: "Current session",
///   utilization: 0.35,
///   resetsAt: Date().addingTimeInterval(3600)
/// )
/// ```
struct UsageLimit: Identifiable {
  /// A unique identifier for this limit, typically matching the API field name.
  let id: String

  /// A localized display title for the limit (e.g., "Current session", "All models").
  let title: String

  /// The utilization percentage as a value between 0.0 and 1.0.
  ///
  /// A value of 0.5 means 50% of the limit has been used.
  let utilization: Double

  /// The date when this limit will reset, or `nil` if unknown.
  let resetsAt: Date?
}
