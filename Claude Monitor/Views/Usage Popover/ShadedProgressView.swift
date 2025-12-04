//
//  ShadedProgressView.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import SwiftUI

/// A custom progress bar with a solid fill and rounded corners.
///
/// `ShadedProgressView` displays progress as a colored bar over a
/// translucent background track. Unlike the system `ProgressView`,
/// this view uses solid fills rather than gradients.
///
/// - Parameters:
///   - value: The progress value between 0.0 and 1.0. Values outside
///     this range are clamped.
///   - tint: The fill color for the progress bar. Defaults to the accent color.
///
/// ## Example
/// ```swift
/// ShadedProgressView(value: 0.65, tint: .orange)
/// ```
struct ShadedProgressView: View {
  let value: Double
  let tint: Color

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.secondary.opacity(0.2))

        RoundedRectangle(cornerRadius: 4)
          .fill(tint)
          .frame(width: geometry.size.width * min(max(value, 0), 1))
          .animation(.snappy, value: value)
      }
    }
    .frame(height: 8)
  }

  init(value: Double, tint: Color = .accentColor) {
    self.value = value
    self.tint = tint
  }
}

#Preview {
  VStack(spacing: 16) {
    ShadedProgressView(value: 0.2, tint: .blue)
    ShadedProgressView(value: 0.6, tint: .yellow)
    ShadedProgressView(value: 0.9, tint: .orange)
    ShadedProgressView(value: 1.0, tint: .red)
  }
  .padding()
  .frame(width: 320)
}
