//
//  UsageViewModel.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import Foundation
import Observation
import SwiftUI

/// The result of validating a token against the API.
enum TokenValidationResult {
  /// The token is valid and can access the API.
  case valid

  /// The token is invalid or expired.
  case invalid
}

/// A thin view model that subscribes to `UsageDataService` for state updates.
///
/// `UsageViewModel` bridges the `UsageDataService` actor with SwiftUI views.
/// It subscribes to the service's `AsyncStream` and updates its observable properties
/// when state changes. UI-only state (like loading indicators and form fields) is
/// managed locally.
///
/// ## Architecture
/// - **Service State**: `usageLimits`, `lastUpdated`, `error`, `tokenSource`, `hasValidToken`
///   are synced from `UsageDataService` via `AsyncStream`
/// - **UI State**: `isLoading`, `manualTokenInput`, `isValidatingToken`, etc.
///   are managed locally for UI responsiveness
///
/// ## Usage
/// ```swift
/// @State private var viewModel = UsageViewModel()
///
/// var body: some View {
///   ContentView()
///     .viewModel(viewModel)
/// }
/// ```
@Observable
@MainActor
final class UsageViewModel: UsageViewModelProtocol {
  // MARK: - State from Service (synced via AsyncStream)

  var usageLimits: [UsageLimit] = []
  var lastUpdated: Date?
  var error: Error?
  var tokenSource: TokenSource?
  var hasValidToken = false

  // MARK: - UI-Only State

  var isLoading = false
  var manualTokenInput = ""
  var isValidatingToken = false
  var tokenValidationResult: TokenValidationResult?

  var preferredTokenSource: TokenSource {
    didSet {
      guard oldValue != preferredTokenSource else { return }
      UserDefaults.standard.set(preferredTokenSource.rawValue, forKey: "preferredTokenSource")
      Task {
        await UsageDataService.shared.setPreferredTokenSource(preferredTokenSource)
      }
    }
  }

  // MARK: - Private State

  private var subscriptionTask: Task<Void, Never>?
  private var saveTask: Task<Void, Never>?

  // MARK: - Protocol Conformance

  var isClaudeCodeTokenAvailable: Bool {
    KeychainService.shared.isClaudeCodeTokenAvailable
  }

  // MARK: - Initialization

  init() {
    // Initialize from UserDefaults to match service state before stream connects
    if let savedSource = UserDefaults.standard.string(forKey: "preferredTokenSource"),
      let source = TokenSource(rawValue: savedSource)
    {
      self.preferredTokenSource = source
    } else {
      self.preferredTokenSource = .claudeCode
    }

    // Load existing manual token if available
    if let token = try? KeychainService.shared.readManualToken() {
      self.manualTokenInput = token
    }

    startSubscription()
  }

  // MARK: - Subscription

  private func startSubscription() {
    subscriptionTask = Task { [weak self] in
      for await state in UsageDataService.shared.stateStream {
        guard let self, !Task.isCancelled else { break }
        await MainActor.run {
          self.usageLimits = state.usageLimits
          self.lastUpdated = state.lastUpdated
          self.error = state.error
          self.tokenSource = state.tokenSource
          self.hasValidToken = state.hasValidToken
          self.preferredTokenSource = state.preferredTokenSource
        }
      }
    }
  }

  // MARK: - Public Methods

  func refresh() async {
    isLoading = true
    await UsageDataService.shared.refresh()
    isLoading = false
  }

  func checkTokenAvailability() {
    // Token availability is managed by UsageDataService and synced via stream.
    // This triggers a refresh to update the state.
    Task {
      await UsageDataService.shared.refresh()
    }
  }

  /// Saves the manual token after a brief delay to avoid saving on every keystroke.
  func saveManualTokenDebounced(_ token: String) {
    saveTask?.cancel()
    saveTask = Task {
      try? await Task.sleep(for: .milliseconds(300))
      guard !Task.isCancelled else { return }

      if token.isEmpty {
        try? await UsageDataService.shared.clearManualToken()
      } else {
        try? await UsageDataService.shared.saveManualToken(token)
      }
    }
  }

  /// Validates the manually-entered token against the API.
  func validateManualToken() async {
    guard !manualTokenInput.isEmpty else { return }

    isValidatingToken = true
    tokenValidationResult = nil

    let isValid = await UsageDataService.shared.validateToken(manualTokenInput)

    tokenValidationResult = isValid ? .valid : .invalid
    isValidatingToken = false
  }
}
