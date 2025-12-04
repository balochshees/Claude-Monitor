//
//  UsageContentView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// The main content area of the usage popover.
///
/// `UsageContentView` displays usage data in one of several states:
/// - **Error** — Shows ``ErrorView`` when an error occurred
/// - **Loading** — Shows nothing while loading with no cached data
/// - **Empty** — Shows ``EmptyStateView`` when no limits are available
/// - **Data** — Shows a list of ``UsageLimitRow`` views for each limit
///
/// - Parameters:
///   - usageLimits: The array of usage limits to display.
///   - error: An optional error that occurred during fetching.
///   - isLoading: Whether a refresh operation is in progress.
///   - onRetry: An async closure called when the retry button is tapped.
struct UsageContentView: View {
  let usageLimits: [UsageLimit]
  let error: Error?
  let isLoading: Bool
  let onRetry: () async -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let error {
        ErrorView(error: error, onRetry: onRetry)
      } else if isLoading && usageLimits.isEmpty {
        EmptyView()
      } else if usageLimits.isEmpty {
        EmptyStateView()
      } else {
        VStack(alignment: .leading, spacing: 16) {
          ForEach(usageLimits) { limit in
            UsageLimitRow(limit: limit)
          }
        }
        .padding()
      }
    }
  }
}

#Preview("With Usage Limits") {
  UsageContentView(
    usageLimits: [
      UsageLimit(
        id: "test1",
        title: "Current session",
        utilization: 0.20,
        resetsAt: .now.addingTimeInterval(3600 * 1.75)
      ),
      UsageLimit(
        id: "test2",
        title: "All models",
        utilization: 0.55,
        resetsAt: .now.addingTimeInterval(3600 * 24 * 3)
      )
    ],
    error: nil,
    isLoading: false,
    onRetry: {}
  )
  .frame(width: 320)
}

#Preview("Error State") {
  UsageContentView(
    usageLimits: [],
    error: APIError.httpError(statusCode: 401, message: nil),
    isLoading: false,
    onRetry: {}
  )
  .frame(width: 320)
}

#Preview("Empty State") {
  UsageContentView(
    usageLimits: [],
    error: nil,
    isLoading: false,
    onRetry: {}
  )
  .frame(width: 320)
}
