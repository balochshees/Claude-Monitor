//
//  FormatStyle+Extensions.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import Foundation

// MARK: - Percent Format Styles

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
  /// A format style for displaying utilization percentages.
  ///
  /// Formats values as whole-number percentages without decimal places.
  /// For example, `0.35` is formatted as "35%".
  ///
  /// ## Example
  /// ```swift
  /// Text("\(limit.utilization, format: .utilization) used")
  /// // "35% used"
  /// ```
  static var utilization: Self {
    .percent.precision(.fractionLength(0))
  }
}

// MARK: - Date Format Styles

extension FormatStyle where Self == Date.RelativeFormatStyle {
  /// A format style for displaying "last updated" timestamps.
  ///
  /// Uses relative formatting with named presentation (e.g., "2 minutes ago",
  /// "yesterday", "just now").
  ///
  /// ## Example
  /// ```swift
  /// Text("Updated \(date, format: .lastUpdated)")
  /// // "Updated 2 minutes ago"
  /// ```
  static var lastUpdated: Self {
    .relative(presentation: .named)
  }
}

extension FormatStyle where Self == Date.ComponentsFormatStyle {
  /// A format style for displaying time until a limit resets.
  ///
  /// Uses abbreviated component formatting showing days, hours, and minutes.
  /// For example, "3d 2h 15m" or "45m".
  ///
  /// ## Example
  /// ```swift
  /// let interval = Date.now..<resetsAt
  /// Text("Resets in \(interval, format: .resetInterval)")
  /// // "Resets in 2h 30m"
  /// ```
  static var resetInterval: Self {
    .components(style: .abbreviated, fields: [.day, .hour, .minute])
  }
}
