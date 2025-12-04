//
//  NotificationService.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import Foundation
import Logging
import UserNotifications

/// Notification thresholds for usage warnings.
///
/// Each threshold represents a utilization level that triggers a notification.
/// Thresholds are evaluated in order from lowest to highest.
enum UsageThreshold: Double, CaseIterable, Comparable, Codable {
  /// Warning level at 75% utilization.
  case warning = 0.75

  /// Critical level at 90% utilization.
  case critical = 0.90

  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

/// Tracks which thresholds have been notified for a specific usage limit.
struct NotificationState: Codable {
  /// The resetsAt date when this state was captured.
  /// Used to detect when the limit resets to a new period.
  var resetsAt: Date?

  /// Which thresholds have already triggered notifications.
  var notifiedThresholds: Set<UsageThreshold> = []
}

/// A service for managing macOS desktop notifications for usage warnings.
///
/// `NotificationService` handles:
/// - Requesting notification permission from the user
/// - Tracking which thresholds have already been notified
/// - Sending notifications when thresholds are crossed
/// - Resetting notification state when limits reset
///
/// ## Usage
/// ```swift
/// // Request permission at app launch
/// await NotificationService.shared.requestPermission()
///
/// // Evaluate limits after each refresh
/// await NotificationService.shared.evaluateLimits(usageLimits)
/// ```
///
/// ## Thread Safety
/// This service is an actor, providing safe concurrent access to notification state.
actor NotificationService {
  /// The shared singleton instance.
  static let shared = NotificationService()

  /// Limit IDs that should trigger notifications.
  private static let monitoredLimitIds: Set<String> = ["five_hour", "seven_day"]

  /// UserDefaults key for persisted notification state.
  private static let userDefaultsKey = "notificationState"

  /// Tracks notification state per limit ID.
  /// Key: limit ID (e.g., "five_hour"), Value: notification state
  private var notificationState: [String: NotificationState]

  private let logger = Logger(label: "codes.tim.Claude-Monitor.NotificationService")

  private init() {
    // Load persisted state from UserDefaults
    if let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
      let decoded = try? JSONDecoder().decode([String: NotificationState].self, from: data)
    {
      notificationState = decoded
    } else {
      notificationState = [:]
    }
  }

  /// Persists the current notification state to UserDefaults.
  private func persistState() {
    if let data = try? JSONEncoder().encode(notificationState) {
      UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
    }
  }

  // MARK: - Permission

  /// Requests notification permission from the user.
  ///
  /// This method should be called at app launch. macOS will only show the
  /// permission dialog once; subsequent calls are no-ops.
  ///
  /// - Returns: `true` if permission was granted, `false` otherwise.
  @discardableResult
  func requestPermission() async -> Bool {
    do {
      let granted = try await UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound])
      logger.info("Notification permission \(granted ? "granted" : "denied")")
      return granted
    } catch {
      logger.error("Failed to request notification permission", metadata: ["error": "\(error)"])
      return false
    }
  }

  // MARK: - Threshold Checking

  /// Evaluates usage limits and sends notifications for newly crossed thresholds.
  ///
  /// Call this method after each successful API refresh. It:
  /// 1. Filters to only monitored limits (`five_hour`, `seven_day`)
  /// 2. Checks if utilization has crossed a threshold
  /// 3. Sends a notification if threshold is newly crossed
  /// 4. Resets state if `resetsAt` changed or utilization dropped below threshold
  ///
  /// - Parameter limits: The current usage limits from the API.
  func evaluateLimits(_ limits: [UsageLimit]) async {
    for limit in limits where Self.monitoredLimitIds.contains(limit.id) {
      await evaluateLimit(limit)
    }
  }

  private func evaluateLimit(_ limit: UsageLimit) async {
    let currentState = notificationState[limit.id]
    var stateChanged = false

    // Check if limit has reset (resetsAt changed or utilization dropped)
    if shouldResetState(currentState: currentState, limit: limit) {
      notificationState[limit.id] = NotificationState(
        resetsAt: limit.resetsAt,
        notifiedThresholds: []
      )
      stateChanged = true
    }

    // Check each threshold from lowest to highest
    for threshold in UsageThreshold.allCases.sorted() where limit.utilization >= threshold.rawValue
    {
      let alreadyNotified =
        notificationState[limit.id]?.notifiedThresholds.contains(threshold)
        ?? false

      if !alreadyNotified {
        logger.info(
          "Threshold crossed",
          metadata: ["limit": "\(limit.id)", "threshold": "\(threshold.rawValue)"]
        )
        await sendNotification(for: limit, threshold: threshold)
        if notificationState[limit.id] == nil {
          notificationState[limit.id] = NotificationState(resetsAt: limit.resetsAt)
        }
        notificationState[limit.id]?.notifiedThresholds.insert(threshold)
        stateChanged = true
      }
    }

    // Persist state if it changed
    if stateChanged {
      persistState()
    }
  }

  private func shouldResetState(currentState: NotificationState?, limit: UsageLimit) -> Bool {
    guard let currentState else { return true }

    // Reset if resetsAt date has changed (new period)
    if currentState.resetsAt != limit.resetsAt {
      return true
    }

    // Reset if resetsAt date has passed
    if let resetsAt = currentState.resetsAt, Date() > resetsAt {
      return true
    }

    // Reset if utilization dropped below all notified thresholds
    let lowestNotifiedThreshold = currentState.notifiedThresholds.min()
    if let lowest = lowestNotifiedThreshold, limit.utilization < lowest.rawValue {
      return true
    }

    return false
  }

  // MARK: - Notification Delivery

  private func sendNotification(for limit: UsageLimit, threshold: UsageThreshold) async {
    await NotificationRenderer.shared.send(for: limit, threshold: threshold)
  }

  // MARK: - Testing Support

  /// Clears all notification state. For testing only.
  func resetAllState() {
    notificationState.removeAll()
    UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
  }
}
