//
//  UsageHeaderView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// The header section of the usage popover.
///
/// `UsageHeaderView` displays the title "Plan usage limits" and a refresh button.
/// When a refresh is in progress, the button is replaced with a spinner.
///
/// - Parameters:
///   - isLoading: Whether a refresh operation is currently in progress.
///   - onRefresh: An async closure called when the refresh button is tapped.
struct UsageHeaderView: View {
  let isLoading: Bool
  let onRefresh: () async -> Void

  var body: some View {
    HStack {
      Label("Claude usage limits", systemImage: "chart.bar.fill")
        .font(.headline)
        .labelStyle(.titleOnly)

      Spacer()

      if isLoading {
        ProgressView()
          .controlSize(.small)
      } else {
        Button {
          Task { await onRefresh() }
        } label: {
          Image(systemName: "arrow.clockwise")
            .accessibilityLabel("Refresh")
        }
        .buttonStyle(.plain)
        .help("Refresh")
      }
    }
    .padding()
  }
}

#Preview("Idle") {
  UsageHeaderView(isLoading: false, onRefresh: {})
    .frame(width: 320)
}

#Preview("Loading") {
  UsageHeaderView(isLoading: true, onRefresh: {})
    .frame(width: 320)
}
