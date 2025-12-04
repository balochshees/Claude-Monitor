//
//  ViewModelKey.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

// MARK: - Environment Key

/// Environment key for providing the view model.
///
/// Uses the concrete `UsageViewModel` type to ensure SwiftUI's observation
/// system works correctly with the `@Observable` macro.
private struct ViewModelKey: @preconcurrency EnvironmentKey {
  @MainActor static let defaultValue = UsageViewModel()
}

extension EnvironmentValues {
  /// The view model for Claude status.
  var viewModel: UsageViewModel {
    get { self[ViewModelKey.self] }
    set { self[ViewModelKey.self] = newValue }
  }
}

extension View {
  /// Sets the view model in the environment.
  func viewModel(_ viewModel: UsageViewModel) -> some View {
    environment(\.viewModel, viewModel)
  }
}
