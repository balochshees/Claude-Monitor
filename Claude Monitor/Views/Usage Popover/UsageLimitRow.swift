//
//  UsageLimitRow.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// A row displaying a single usage limit with progress indicator.
///
/// `UsageLimitRow` shows:
/// - The limit's title (e.g., "Current session", "All models")
/// - The utilization percentage
/// - A color-coded progress bar via ``ShadedProgressView``
/// - The time until the limit resets (if available)
///
/// ## Progress Colors
/// The progress bar color indicates usage severity:
/// - **Blue** — Under 50% usage (normal)
/// - **Yellow** — 50-80% usage (moderate)
/// - **Orange** — 80-95% usage (high)
/// - **Red** — Over 95% usage (critical)
struct UsageLimitRow: View {
  let limit: UsageLimit

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .firstTextBaseline) {
        Text(limit.title)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(.primary)

        Spacer()

        Text(String(localized: "\(limit.utilization, format: .utilization) used"))
          .font(.system(size: 13, weight: .regular))
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .contentTransition(.numericText())
      }

      ShadedProgressView(value: limit.utilization, tint: progressColor)

      if let resetText = resetTimeText {
        Text(resetText)
          .font(.system(size: 11, weight: .regular))
          .foregroundStyle(.tertiary)
      }
    }
  }

  // MARK: - Private

  private var resetTimeText: String? {
    guard let resetsAt = limit.resetsAt else { return nil }

    let now = Date.now
    if resetsAt <= now { return String(localized: "Resetting…") }

    let interval = now..<resetsAt
    return String(localized: "Resets in \(interval, format: .resetInterval)")
  }

  private var progressColor: Color {
    switch limit.utilization {
      case 0..<0.5: .blue
      case 0.5..<0.8: .yellow
      case 0.8..<0.95: .orange
      default: .red
    }
  }
}

#Preview {
  VStack(spacing: 16) {
    UsageLimitRow(
      limit: UsageLimit(
        id: "test1",
        title: "Current session",
        utilization: 0.20,
        resetsAt: .now.addingTimeInterval(3600 * 1.75)
      )
    )

    UsageLimitRow(
      limit: UsageLimit(
        id: "test2",
        title: "All models",
        utilization: 0.55,
        resetsAt: .now.addingTimeInterval(3600 * 24 * 3)
      )
    )

    UsageLimitRow(
      limit: UsageLimit(
        id: "test3",
        title: "Sonnet only",
        utilization: 0.02,
        resetsAt: .now.addingTimeInterval(3600 * 24 * 3 + 3600 * 3)
      )
    )

    UsageLimitRow(
      limit: UsageLimit(
        id: "test4",
        title: "Opus only",
        utilization: 0.85,
        resetsAt: .now.addingTimeInterval(3600 * 24 * 3 + 3600 * 6)
      )
    )
  }
  .padding()
  .frame(width: 320)
}
