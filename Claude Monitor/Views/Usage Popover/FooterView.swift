//
//  FooterView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// The footer section displaying metadata about the usage data.
///
/// `FooterView` shows when the usage data was last successfully refreshed,
/// formatted as a relative time (e.g., "Updated 2 minutes ago").
///
/// - Parameters:
///   - tokenSourceName: The name of the active token source (currently unused).
///   - lastUpdated: The date when data was last refreshed, or `nil` if never.
struct FooterView: View {
  let tokenSourceName: String?
  let lastUpdated: Date?

  var body: some View {
    TimelineView(.periodic(from: .now, by: 1)) { context in
      HStack {
        //      if let source = tokenSourceName {
        //        Label(source, systemImage: "key.fill")
        //          .font(.caption2)
        //      }

        Spacer()

        if let updated = lastUpdated {
          Text("Updated \(updated.formatted(.relative(presentation: .named, unitsStyle: .wide)))")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .id(context.date)
        }
      }
      .padding(.horizontal)
      .padding(.bottom, 8)
    }
  }
}

#Preview {
  FooterView(tokenSourceName: "Claude Code", lastUpdated: .now.addingTimeInterval(-120))
    .frame(width: 320)
}
