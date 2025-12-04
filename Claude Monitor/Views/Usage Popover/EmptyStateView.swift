//
//  EmptyStateView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// A view displayed when no usage data is available.
///
/// `EmptyStateView` is shown when the API returns successfully but
/// no usage limits are present in the response. This can occur when
/// the user hasn't made any API calls yet.
struct EmptyStateView: View {
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: "circle.slash")
        .font(.largeTitle)
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)

      Text("No usage data available")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding()
  }
}

#Preview {
  EmptyStateView()
    .frame(width: 320)
}
