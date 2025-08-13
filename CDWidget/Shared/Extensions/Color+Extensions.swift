import SwiftUI

extension Color {
    static let eventColors: [Color] = [
        .blue,
        .green,
        .orange,
        .purple,
        .pink
    ]
    
    static func eventColor(for colorId: Int) -> Color {
        return eventColors[colorId % eventColors.count]
    }
    
    // App-specific colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let background = Color(UIColor.systemBackground)
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let accentBlue = Color.blue
    static let warningRed = Color.red
    static let successGreen = Color.green
}

extension UIColor {
    static let eventColors: [UIColor] = [
        .systemBlue,
        .systemGreen,
        .systemOrange,
        .systemPurple,
        .systemPink
    ]
    
    static func eventColor(for colorId: Int) -> UIColor {
        return eventColors[colorId % eventColors.count]
    }
}