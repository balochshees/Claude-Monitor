//
//  ManualTokenView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// A form section for entering a manual OAuth token.
///
/// `ManualTokenView` provides the UI for users who want to manually enter
/// a Claude OAuth token rather than using the automatic Claude Code integration.
/// The token is automatically saved to Keychain when entered.
struct ManualTokenView: View {
  @Environment(\.viewModel)
  private var viewModel

  var body: some View {
    @Bindable var viewModel = viewModel

    VStack(alignment: .leading, spacing: 12) {
      SecureField(
        "OAuth Token",
        text: $viewModel.manualTokenInput,
        prompt: Text("Paste your OAuth token")
      )
      .textFieldStyle(.roundedBorder)
      .onChange(of: viewModel.manualTokenInput) { _, newValue in
        viewModel.saveManualTokenDebounced(newValue)
      }

      HStack {
        Button("Validate") {
          Task { await viewModel.validateManualToken() }
        }
        .disabled(viewModel.manualTokenInput.isEmpty || viewModel.isValidatingToken)

        if viewModel.isValidatingToken {
          ProgressView()
            .controlSize(.small)
        }

        if let result = viewModel.tokenValidationResult {
          Label(
            result == .valid ? "Valid" : "Invalid",
            systemImage: result == .valid ? "checkmark.circle.fill" : "xmark.circle.fill"
          )
          .foregroundStyle(result == .valid ? .green : .red)
        }
      }

      if let error = viewModel.error {
        Text(error.localizedDescription)
          .font(.caption)
          .foregroundStyle(.red)
      }
    }
  }
}

#Preview {
  Form {
    Section {
      ManualTokenView()
    }
  }
  .viewModel(UsageViewModel())
  .formStyle(.grouped)
  .frame(width: 400)
}
