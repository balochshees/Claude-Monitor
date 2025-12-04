//
//  MenuBarIconRenderer.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import AppKit
import Foundation

/// Renders the dynamic menu bar icon with a utilization gauge.
///
/// The icon consists of:
/// - A Claude "C" logo in the center
/// - A 270° arc (open at bottom) that fills based on utilization
///
/// The image uses template rendering mode for proper menu bar appearance,
/// allowing the system to tint it appropriately for light/dark mode.
enum MenuBarIconRenderer {

  /// The size of the menu bar icon canvas.
  private static let iconSize = NSSize(width: 26, height: 22)

  /// The center point of the icon (gauge center).
  private static var center: NSPoint {
    NSPoint(x: iconSize.width / 2, y: iconSize.height / 2)
  }

  /// The radius of the gauge arc center line.
  private static let arcRadius: CGFloat = 9.5

  /// Line width for the arc stroke.
  private static let arcLineWidth: CGFloat = 3.0

  /// The total arc sweep in degrees (270° = 3/4 of a circle, open at bottom).
  private static let totalArcDegrees: CGFloat = 270

  /// The starting angle of the arc (bottom-left, in macOS coordinates where 0° is right).
  /// 225° points to the bottom-left corner.
  private static let arcStartAngle: CGFloat = 225

  /// The ending angle of the arc (bottom-right).
  /// -45° (or 315°) points to the bottom-right corner.
  private static let arcEndAngle: CGFloat = -45

  /// Renders the menu bar icon with the given utilization level.
  ///
  /// - Parameter utilization: A value between 0.0 and 1.0 representing usage,
  ///   or `nil` if usage data is not available (arc will not be drawn).
  /// - Returns: An NSImage configured as a template image for the menu bar.
  static func render(utilization: Double?) -> NSImage {
    let image = NSImage(size: iconSize, flipped: false) { _ in
      // Only draw the gauge if utilization data is available
      if let utilization {
        // Clamp utilization to valid range
        let clampedUtilization = max(0, min(1, utilization))

        // Draw the background track (subtle)
        drawGaugeTrack()

        // Draw the filled portion of the gauge
        drawGaugeFill(utilization: clampedUtilization)
      }

      // Draw the Claude "C" logo in the center
      drawClaudeLogo()

      return true
    }

    // Set as template image so system can tint it
    image.isTemplate = true

    return image
  }

  /// Draws a subtle background track for the gauge (270° arc, open at bottom).
  private static func drawGaugeTrack() {
    let path = NSBezierPath()
    path.appendArc(
      withCenter: center,
      radius: arcRadius,
      startAngle: arcStartAngle,
      endAngle: arcEndAngle,
      clockwise: true
    )
    path.lineWidth = arcLineWidth
    path.lineCapStyle = .round

    // Subtle track
    NSColor.black.withAlphaComponent(0.2).setStroke()
    path.stroke()
  }

  /// Draws the filled portion of the gauge arc.
  private static func drawGaugeFill(utilization: Double) {
    guard utilization > 0 else { return }

    // Calculate the end angle based on utilization
    // Start from bottom-left (225°) and sweep clockwise toward bottom-right (-45°)
    // The sweep covers 270° total, so we calculate the portion to fill
    let sweepDegrees = totalArcDegrees * CGFloat(utilization)
    let endAngle = arcStartAngle - sweepDegrees

    let path = NSBezierPath()
    path.appendArc(
      withCenter: center,
      radius: arcRadius,
      startAngle: arcStartAngle,
      endAngle: endAngle,
      clockwise: true
    )
    path.lineWidth = arcLineWidth
    path.lineCapStyle = .round

    // Solid black for template image
    NSColor.black.setStroke()
    path.stroke()
  }

  /// Draws the Claude "C" logo in the center of the icon.
  private static func drawClaudeLogo() {
    // Scale and position the logo to fit in the center of the gauge
    // The original logo path is approximately 13x13 units, centered around (11.5, 12)

    let logoPath = createClaudeLogoPath()

    // Transform: translate to center, scale down
    // swiftlint:disable:next legacy_objc_type
    let transform = NSAffineTransform()

    // The logo's original bounding box is roughly (5, 5.6) to (18, 18.6)
    // Original center is approximately (11.5, 12.1)
    // We want to center it in our canvas

    // Scale factor to fit the logo inside the gauge arc
    let scale: CGFloat = 0.85

    // First translate to move the logo's center to origin, then scale, then translate to canvas center
    transform.translateX(by: center.x, yBy: center.y)
    transform.scale(by: scale)
    transform.translateX(by: -11.5, yBy: -12.1)

    logoPath.transform(using: transform as AffineTransform)

    NSColor.black.setFill()
    logoPath.fill()
  }

  /// Creates the Claude star logo bezier path.
  ///
  /// This path is extracted from the existing menu-icon.svg.
  private static func createClaudeLogoPath() -> NSBezierPath {
    let path = NSBezierPath()

    // Path data extracted from menu-icon.svg (the path with id="path147")
    // Converted from SVG path commands to NSBezierPath

    path.move(to: NSPoint(x: 7.55017154, y: 14.2491535))
    path.line(to: NSPoint(x: 10.1082096, y: 12.8147485))
    path.line(to: NSPoint(x: 10.1512244, y: 12.6901692))
    path.line(to: NSPoint(x: 10.1082096, y: 12.6208635))
    path.line(to: NSPoint(x: 9.98355596, y: 12.6208635))
    path.line(to: NSPoint(x: 9.55604614, y: 12.5945425))
    path.line(to: NSPoint(x: 8.09443469, y: 12.555065))
    path.line(to: NSPoint(x: 6.82682708, y: 12.5024257))
    path.line(to: NSPoint(x: 5.59872295, y: 12.4366278))
    path.line(to: NSPoint(x: 5.28972194, y: 12.3708293))
    path.line(to: NSPoint(x: 5.000033, y: 11.989198))
    path.line(to: NSPoint(x: 5.02988006, y: 11.7988228))
    path.line(to: NSPoint(x: 5.28972194, y: 11.6242364))
    path.line(to: NSPoint(x: 5.66192783, y: 11.6566962))
    path.line(to: NSPoint(x: 6.48446825, y: 11.7128454))
    path.line(to: NSPoint(x: 7.71871754, y: 11.7979452))
    path.line(to: NSPoint(x: 8.61411868, y: 11.8505839))
    path.line(to: NSPoint(x: 9.94054246, y: 11.9883197))
    path.line(to: NSPoint(x: 10.1512244, y: 11.9883197))
    path.line(to: NSPoint(x: 10.1810708, y: 11.9032206))
    path.line(to: NSPoint(x: 10.1090885, y: 11.8505839))
    path.line(to: NSPoint(x: 10.0529065, y: 11.7979452))
    path.line(to: NSPoint(x: 8.77564234, y: 10.9329145))
    path.line(to: NSPoint(x: 7.39303722, y: 10.0187576))
    path.line(to: NSPoint(x: 6.66881558, y: 9.49237077))
    path.line(to: NSPoint(x: 6.27729701, y: 9.22566683))
    path.line(to: NSPoint(x: 6.07978193, y: 8.97563259))
    path.line(to: NSPoint(x: 5.99463093, y: 8.42994649))
    path.line(to: NSPoint(x: 6.35015759, y: 8.03866457))
    path.line(to: NSPoint(x: 6.82770524, y: 8.07112502))
    path.line(to: NSPoint(x: 6.94972557, y: 8.10358612))
    path.line(to: NSPoint(x: 7.43341805, y: 8.47556677))
    path.line(to: NSPoint(x: 8.46664068, y: 9.27479632))
    path.line(to: NSPoint(x: 9.81588846, y: 10.2679135))
    path.line(to: NSPoint(x: 10.0134036, y: 10.4319704))
    path.line(to: NSPoint(x: 10.092409, y: 10.3758238))
    path.line(to: NSPoint(x: 10.1020655, y: 10.3363436))
    path.line(to: NSPoint(x: 10.0134036, y: 10.1880782))
    path.line(to: NSPoint(x: 9.27952499, y: 8.86246185))
    path.line(to: NSPoint(x: 8.49648767, y: 7.51403301))
    path.line(to: NSPoint(x: 8.14798353, y: 6.95518441))
    path.line(to: NSPoint(x: 8.05580936, y: 6.62005238))
    path.curve(
      to: NSPoint(x: 7.99962736, y: 6.22526259),
      controlPoint1: NSPoint(x: 8.02332953, y: 6.48231324),
      controlPoint2: NSPoint(x: 7.99962736, y: 6.36650959)
    )
    path.line(to: NSPoint(x: 8.40431385, y: 5.67606529))
    path.line(to: NSPoint(x: 8.62816434, y: 5.604126))
    path.line(to: NSPoint(x: 9.16803882, y: 5.67606529))
    path.line(to: NSPoint(x: 9.39540031, y: 5.87346084))
    path.line(to: NSPoint(x: 9.73073763, y: 6.64022995))
    path.line(to: NSPoint(x: 10.2741221, y: 7.84741177))
    path.line(to: NSPoint(x: 11.1168537, y: 9.48886025))
    path.line(to: NSPoint(x: 11.3635279, y: 9.97576756))
    path.line(to: NSPoint(x: 11.4952042, y: 10.4267066))
    path.line(to: NSPoint(x: 11.5443636, y: 10.564445))
    path.line(to: NSPoint(x: 11.6295144, y: 10.564445))
    path.line(to: NSPoint(x: 11.6295144, y: 10.485488))
    path.line(to: NSPoint(x: 11.6988649, y: 9.56080087))
    path.line(to: NSPoint(x: 11.8270299, y: 8.42555965))
    path.line(to: NSPoint(x: 11.9516836, y: 6.96483572))
    path.line(to: NSPoint(x: 11.9946984, y: 6.55337755))
    path.line(to: NSPoint(x: 12.198359, y: 6.06032747))
    path.line(to: NSPoint(x: 12.6030452, y: 5.79362552))
    path.line(to: NSPoint(x: 12.9190685, y: 5.9445225))
    path.line(to: NSPoint(x: 13.1789112, y: 6.31650182))
    path.line(to: NSPoint(x: 13.142919, y: 6.55688543))
    path.line(to: NSPoint(x: 12.988419, y: 7.56053026))
    path.line(to: NSPoint(x: 12.6855615, y: 9.13267234))
    path.line(to: NSPoint(x: 12.4880467, y: 10.185446))
    path.line(to: NSPoint(x: 12.6030452, y: 10.185446))
    path.line(to: NSPoint(x: 12.7347215, y: 10.0538496))
    path.line(to: NSPoint(x: 13.2675727, y: 9.34673627))
    path.line(to: NSPoint(x: 14.162974, y: 8.22816476))
    path.line(to: NSPoint(x: 14.5580036, y: 7.78424482))
    path.line(to: NSPoint(x: 15.0188724, y: 7.29382698))
    path.line(to: NSPoint(x: 15.3147066, y: 7.0604631))
    path.line(to: NSPoint(x: 15.8738934, y: 7.0604631))
    path.line(to: NSPoint(x: 16.2856029, y: 7.67194905))
    path.line(to: NSPoint(x: 16.1012546, y: 8.30361325))
    path.line(to: NSPoint(x: 15.5253886, y: 9.03353574))
    path.line(to: NSPoint(x: 15.0478413, y: 9.65204209))
    path.line(to: NSPoint(x: 14.363122, y: 10.5732187))
    path.line(to: NSPoint(x: 13.9356121, y: 11.3101603))
    path.line(to: NSPoint(x: 13.975115, y: 11.3689384))
    path.line(to: NSPoint(x: 14.0769456, y: 11.3592891))
    path.line(to: NSPoint(x: 15.6237073, y: 11.0302971))
    path.line(to: NSPoint(x: 16.4594159, y: 10.8793995))
    path.line(to: NSPoint(x: 17.4566465, y: 10.7083229))
    path.line(to: NSPoint(x: 17.9078588, y: 10.918877))
    path.line(to: NSPoint(x: 17.9570175, y: 11.1329416))
    path.line(to: NSPoint(x: 17.7796932, y: 11.5707214))
    path.line(to: NSPoint(x: 16.7131127, y: 11.8339148))
    path.line(to: NSPoint(x: 15.4621839, y: 12.0839491))
    path.line(to: NSPoint(x: 13.5993977, y: 12.5243585))
    path.line(to: NSPoint(x: 13.5765747, y: 12.5410275))
    path.line(to: NSPoint(x: 13.6029097, y: 12.573488))
    path.line(to: NSPoint(x: 14.442129, y: 12.6524457))
    path.line(to: NSPoint(x: 14.8011671, y: 12.6717463))
    path.line(to: NSPoint(x: 15.6798893, y: 12.6717463))
    path.line(to: NSPoint(x: 17.3161905, y: 12.793694))
    path.line(to: NSPoint(x: 17.7437017, y: 13.0761887))
    path.line(to: NSPoint(x: 18.000033, y: 13.4218497))
    path.line(to: NSPoint(x: 17.9570175, y: 13.6850424))
    path.line(to: NSPoint(x: 17.2986339, y: 14.0201738))
    path.line(to: NSPoint(x: 16.4102559, y: 13.8096197))
    path.line(to: NSPoint(x: 14.3367883, y: 13.316571))
    path.line(to: NSPoint(x: 13.6257333, y: 13.139355))
    path.line(to: NSPoint(x: 13.5274153, y: 13.139355))
    path.line(to: NSPoint(x: 13.5274153, y: 13.1981331))
    path.line(to: NSPoint(x: 14.1199605, y: 13.7771593))
    path.line(to: NSPoint(x: 15.2058533, y: 14.7571147))
    path.line(to: NSPoint(x: 16.5656354, y: 16.0204457))
    path.line(to: NSPoint(x: 16.6349839, y: 16.3327686))
    path.line(to: NSPoint(x: 16.4602927, y: 16.5792923))
    path.line(to: NSPoint(x: 16.2759457, y: 16.552972))
    path.line(to: NSPoint(x: 15.0811996, y: 15.6546052))
    path.line(to: NSPoint(x: 14.6203315, y: 15.2501661))
    path.line(to: NSPoint(x: 13.5765747, y: 14.3719762))
    path.line(to: NSPoint(x: 13.5072242, y: 14.3719762))
    path.line(to: NSPoint(x: 13.5072242, y: 14.464093))
    path.line(to: NSPoint(x: 13.7477538, y: 14.8158961))
    path.line(to: NSPoint(x: 15.0179949, y: 16.7240479))
    path.line(to: NSPoint(x: 15.0838334, y: 17.3092161))
    path.line(to: NSPoint(x: 14.9916593, y: 17.499592))
    path.line(to: NSPoint(x: 14.6624675, y: 17.6145193))
    path.line(to: NSPoint(x: 14.3007961, y: 17.5487208))
    path.line(to: NSPoint(x: 13.5572617, y: 16.5055984))
    path.line(to: NSPoint(x: 12.7900254, y: 15.330877))
    path.line(to: NSPoint(x: 12.1711445, y: 14.2781034))
    path.line(to: NSPoint(x: 12.0956495, y: 14.3210934))
    path.line(to: NSPoint(x: 11.7304676, y: 18.2523256))
    path.line(to: NSPoint(x: 11.5592871, y: 18.453229))
    path.line(to: NSPoint(x: 11.1642567, y: 18.604126))
    path.line(to: NSPoint(x: 10.8350649, y: 18.3540924))
    path.line(to: NSPoint(x: 10.6603751, y: 17.9496527))
    path.line(to: NSPoint(x: 10.8350649, y: 17.1504231))
    path.line(to: NSPoint(x: 11.0457483, y: 16.1072988))
    path.line(to: NSPoint(x: 11.2169281, y: 15.2782384))
    path.line(to: NSPoint(x: 11.3714281, y: 14.2482752))
    path.line(to: NSPoint(x: 11.4636022, y: 13.9061247))
    path.line(to: NSPoint(x: 11.4574577, y: 13.8833129))
    path.line(to: NSPoint(x: 11.3819634, y: 13.8929656))
    path.line(to: NSPoint(x: 10.6050699, y: 14.9588984))
    path.line(to: NSPoint(x: 9.42349131, y: 16.5547279))
    path.line(to: NSPoint(x: 8.48858685, y: 17.5548629))
    path.line(to: NSPoint(x: 8.26473668, y: 17.6434719))
    path.line(to: NSPoint(x: 7.8767297, y: 17.4425671))
    path.line(to: NSPoint(x: 7.91272087, y: 17.083747))
    path.line(to: NSPoint(x: 8.12954869, y: 16.7644043))
    path.line(to: NSPoint(x: 9.42349131, y: 15.1194447))
    path.line(to: NSPoint(x: 10.2038958, y: 14.1000098))
    path.line(to: NSPoint(x: 10.7077781, y: 13.5113336))
    path.line(to: NSPoint(x: 10.7042668, y: 13.4262352))
    path.line(to: NSPoint(x: 10.6744204, y: 13.4262352))
    path.line(to: NSPoint(x: 7.23765839, y: 15.6563591))
    path.line(to: NSPoint(x: 6.62580141, y: 15.7353188))
    path.line(to: NSPoint(x: 6.36244801, y: 15.4887944))
    path.line(to: NSPoint(x: 6.39492784, y: 15.0843533))
    path.line(to: NSPoint(x: 6.51958159, y: 14.9527563))
    path.line(to: NSPoint(x: 7.55280487, y: 14.2421331))
    path.line(to: NSPoint(x: 7.54929338, y: 14.2456436))
    path.line(to: NSPoint(x: 7.55017154, y: 14.2491535))
    path.close()

    return path
  }
}
