//
//  SettingsHelpView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// An informational view explaining how to obtain API tokens.
///
/// `SettingsHelpView` provides guidance on the two token sources:
/// - **Claude Code (Recommended)** — Explains that tokens are automatically
///   detected from a Claude Code installation
/// - **Manual Token** — Explains how to use a manually obtained OAuth token
///
/// The view includes a link to the Claude Code documentation for users
/// who need to install it.
struct SettingsHelpView: View {
  private let claudeCodeURL = URL(string: "https://docs.anthropic.com/en/docs/claude-code")!

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text("Claude Code (Recommended)")
          .fontWeight(.medium)

        Text("If you have Claude Code installed, this app automatically uses its OAuth token.")
          .font(.caption)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.leading)
          .padding(.bottom, 4)

        Link(destination: claudeCodeURL) {
          Label("Learn about Claude Code", systemImage: "arrow.up.right.square")
            .font(.caption)
        }
      }

      Divider()

      VStack(alignment: .leading, spacing: 4) {
        Text("Manual Token")
          .fontWeight(.medium)

        Text(
          "If you have a Claude Code OAuth token from another source, paste it above. Regular API keys (sk-ant-api…) will not work."
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.leading)
      }
    }
  }
}

#Preview {
  SettingsHelpView()
    .padding()
    .frame(width: 400)
}
