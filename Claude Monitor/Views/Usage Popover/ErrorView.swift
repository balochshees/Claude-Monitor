//
//  ErrorView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// A view displaying an error state with retry option.
///
/// `ErrorView` shows error information with varying levels of detail:
/// - Always shows the `localizedDescription`
/// - For `LocalizedError` types, also shows `failureReason` and `recoverySuggestion`
/// - Includes a "Retry" button to attempt the operation again
///
/// The view works well with ``APIError`` which provides rich error descriptions.
///
/// - Parameters:
///   - error: The error to display.
///   - onRetry: An async closure called when the Retry button is tapped.
struct ErrorView: View {
  let error: Error
  let onRetry: () async -> Void

  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.largeTitle)
        .foregroundStyle(.yellow)
        .accessibilityLabel("Error")

      Text(error.localizedDescription)
        .font(.subheadline)
        .fontWeight(.medium)
        .multilineTextAlignment(.center)

      if let localizedError = error as? LocalizedError {
        if let failureReason = localizedError.failureReason {
          Text(failureReason)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }

        if let recoverySuggestion = localizedError.recoverySuggestion {
          Text(recoverySuggestion)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top)
        }
      }

      Button("Retry") {
        Task { await onRetry() }
      }
      .buttonStyle(.bordered)
      .padding(.top)
    }
    .frame(maxWidth: .infinity)
    .padding()
  }
}

#Preview("Localized Error") {
  ErrorView(
    error: APIError.httpError(statusCode: 401, message: nil),
    onRetry: {}
  )
  .frame(width: 320)
}

#Preview("Non-Localized Error") {
  ErrorView(
    error: URLError(.notConnectedToInternet),
    onRetry: {}
  )
  .frame(width: 320)
}
