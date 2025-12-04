//
//  NoTokenView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// A view prompting the user to configure an API token.
///
/// `NoTokenView` is displayed when no valid token is available. It shows
/// the Claude logo, a brief message, and a prominent button to open Settings.
///
/// This view is shown instead of ``UsageContentView`` when
/// `hasValidToken` is `false` on the view model.
struct NoTokenView: View {
  var body: some View {
    VStack(spacing: 12) {
      Image("claude-logo")
        .resizable()
        .frame(width: 32, height: 32)
        .font(.largeTitle)
        .foregroundStyle(.secondary)
        .accessibilityLabel("Claude logo")

      Text("No API Token")
        .font(.headline)

      Text("Configure a token in Settings to view usage.")
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      SettingsLink {
        Text("Open Settings")
      }
      .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity)
    .padding()
  }
}

#Preview {
  NoTokenView()
    .frame(width: 320)
}
