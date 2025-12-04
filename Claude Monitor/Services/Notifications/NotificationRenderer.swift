//
//  NotificationRenderer.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import Foundation
import UserNotifications

/// Renders and delivers macOS desktop notifications.
///
/// `NotificationRenderer` is responsible for:
/// - Building notification content with localized strings
/// - Formatting utilization percentages and reset times
/// - Delivering notifications via `UNUserNotificationCenter`
///
/// This type is thread-safe and can be called from any context.
final class NotificationRenderer: Sendable {
  /// The shared singleton instance.
  static let shared = NotificationRenderer()

  private init() {}

  /// Sends a notification for a usage limit threshold crossing.
  ///
  /// - Parameters:
  ///   - limit: The usage limit that crossed the threshold.
  ///   - threshold: The threshold that was crossed.
  func send(for limit: UsageLimit, threshold: UsageThreshold) async {
    let content = UNMutableNotificationContent()

    switch threshold {
      case .warning:
        content.title = String(localized: "Usage Warning")
        content.body = String(
          localized:
            "Claude \(limit.title) — \(limit.utilization, format: .utilization) of tokens used"
        )
        content.sound = .default

      case .critical:
        content.title = String(localized: "Usage Critical")
        content.body = String(
          localized:
            "Claude \(limit.title) — \(limit.utilization, format: .utilization) of tokens used"
        )
        content.sound = .defaultCritical
    }

    // Add reset time to body if available
    if let resetsAt = limit.resetsAt {
      content.body += String(localized: "\nResets in \(resetsAt, format: .lastUpdated)")
    }

    let request = UNNotificationRequest(
      identifier: "\(limit.id)-\(threshold.rawValue)",
      content: content,
      trigger: nil  // Deliver immediately
    )

    do {
      try await UNUserNotificationCenter.current().add(request)
    } catch {
      // Silently fail - notifications are non-critical
    }
  }
}
