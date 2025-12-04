//
//  ActionButtonsView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// The button row at the bottom of the usage popover.
///
/// `ActionButtonsView` displays:
/// - A "Settings…" link that opens the settings window (optionally hidden)
/// - A "Quit" button that terminates the application
///
/// The Settings link is hidden when displaying ``NoTokenView`` since
/// that view already includes an "Open Settings" button.
///
/// - Parameters:
///   - showSettingsButton: Whether to show the Settings button. Defaults to `true`.
///   - onQuit: A closure called when the Quit button is tapped.
struct ActionButtonsView: View {
  var showSettingsButton = true
  let onQuit: () -> Void

  var body: some View {
    HStack {
      Spacer()

      if showSettingsButton { SettingsLink() }
      Button("Quit") { onQuit() }
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
  }
}

#Preview {
  ActionButtonsView(onQuit: {})
    .frame(width: 320)
}
