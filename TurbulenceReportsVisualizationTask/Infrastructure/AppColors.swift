import SwiftUI

extension Color {
    static let chartBackground = Color(
        red: 16 / 255.0,
        green: 24 / 255.0,
        blue: 35 / 255.0
    )
}


extension ShapeStyle where Self == Color {
    static var chartBackground: Color {.chartBackground }
}
