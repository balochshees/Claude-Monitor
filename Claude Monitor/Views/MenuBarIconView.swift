//
//  MenuBarIconView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// A view that renders the dynamic menu bar icon based on current utilization.
///
/// This view observes the `UsageViewModel` and automatically updates
/// the icon whenever the usage data changes. It displays a gauge that fills
/// based on the 5-hour session utilization.
///
/// ## Usage
/// ```swift
/// MenuBarExtra {
///   ContentView()
/// } label: {
///   MenuBarIconView()
///     .viewModel(viewModel)
/// }
/// ```
struct MenuBarIconView: View {
  @Environment(\.viewModel)
  private var viewModel

  /// The utilization value for the 5-hour session limit.
  ///
  /// Returns `nil` if no session data is available (e.g., during initial load or error state).
  private var sessionUtilization: Double? {
    viewModel.usageLimits
      .first { $0.id == "five_hour" }?
      .utilization
  }

  /// Generates an accessibility label based on the current utilization state.
  private var accessibilityLabel: String {
    guard let sessionUtilization else {
      return String(localized: "Claude usage: no data available")
    }
    return String(localized: "Claude usage: \(sessionUtilization, format: .utilization)")
  }

  var body: some View {
    Image(nsImage: MenuBarIconRenderer.render(utilization: sessionUtilization))
      .accessibilityLabel(accessibilityLabel)
  }
}

#Preview {
  HStack(spacing: 16) {
    VStack {
      Image(nsImage: MenuBarIconRenderer.render(utilization: nil))
      Text("No Data").font(.caption)
    }
    VStack {
      Image(nsImage: MenuBarIconRenderer.render(utilization: 0.0))
      Text("0%").font(.caption)
    }
    VStack {
      Image(nsImage: MenuBarIconRenderer.render(utilization: 0.5))
      Text("50%").font(.caption)
    }
    VStack {
      Image(nsImage: MenuBarIconRenderer.render(utilization: 0.75))
      Text("75%").font(.caption)
    }
    VStack {
      Image(nsImage: MenuBarIconRenderer.render(utilization: 1.0))
      Text("100%").font(.caption)
    }
  }
  .padding()
}
