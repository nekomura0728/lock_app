import SwiftUI

// MARK: - Accessibility Extensions

extension View {
    func accessibilityEventRow(
        title: String,
        countdown: String,
        date: String,
        isOverdue: Bool = false
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(title). \(countdown). \(date)" +
                (isOverdue ? ". Overdue event" : "")
            )
            .accessibilityHint("Double tap to edit this event")
            .accessibilityAddTraits(.isButton)
    }
    
    func accessibilityCountdown(
        main: String,
        sub: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(
                main + (sub != nil ? ". \(sub!)" : "")
            )
    }
    
    func accessibilityColorPicker(
        selectedColor: Color,
        colorName: String
    ) -> some View {
        self
            .accessibilityLabel("Color picker")
            .accessibilityValue("\(colorName) selected")
            .accessibilityHint("Double tap to select this color")
            .accessibilityAddTraits(.isButton)
    }
    
    func accessibilityEmojiPicker(
        selectedEmoji: String?,
        emoji: String
    ) -> some View {
        self
            .accessibilityLabel("Emoji picker")
            .accessibilityValue(
                selectedEmoji == emoji ? "\(emoji) selected" : emoji
            )
            .accessibilityHint("Double tap to select this emoji")
            .accessibilityAddTraits(.isButton)
    }
    
    func accessibilityNotificationStatus(
        isEnabled: Bool,
        status: String
    ) -> some View {
        self
            .accessibilityLabel("Notification status")
            .accessibilityValue(status)
            .accessibilityHint(
                isEnabled ? 
                "Notifications are enabled" : 
                "Double tap to enable notifications"
            )
    }
    
    func accessibilityProFeature(
        title: String,
        description: String,
        isPro: Bool
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(description)")
            .accessibilityValue(isPro ? "Available" : "Pro feature")
    }
    
    func accessibilityWidget(
        eventTitle: String,
        countdown: String,
        hasBackground: Bool = false
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Event widget")
            .accessibilityValue("\(eventTitle). \(countdown)")
            .accessibilityHint("Shows countdown for this event")
    }
}

// MARK: - Dynamic Type Support

extension Font {
    static let dynamicTitle = Font.system(.title, design: .default)
    static let dynamicHeadline = Font.system(.headline, design: .default)
    static let dynamicBody = Font.system(.body, design: .default)
    static let dynamicCaption = Font.system(.caption, design: .default)
    static let dynamicFootnote = Font.system(.footnote, design: .default)
}

struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: CGFloat
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}

extension View {
    func scaledFont(name: String, size: CGFloat) -> some View {
        return self.modifier(ScaledFont(name: name, size: size))
    }
}

// MARK: - High Contrast Support

struct HighContrastColors {
    static func adaptiveColor(
        light: Color,
        dark: Color,
        highContrast: Color
    ) -> Color {
        return Color(
            UIColor { traits in
                if traits.accessibilityContrast == .high {
                    return UIColor(highContrast)
                } else if traits.userInterfaceStyle == .dark {
                    return UIColor(dark)
                } else {
                    return UIColor(light)
                }
            }
        )
    }
    
    static let primaryText = adaptiveColor(
        light: .black,
        dark: .white,
        highContrast: .black
    )
    
    static let secondaryText = adaptiveColor(
        light: .gray,
        dark: .gray,
        highContrast: .black
    )
    
    static let accent = adaptiveColor(
        light: .blue,
        dark: .blue,
        highContrast: .black
    )
    
    static let background = adaptiveColor(
        light: .white,
        dark: .black,
        highContrast: .white
    )
}

// MARK: - Reduced Motion Support

struct ReducedMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    let enabledAnimation: Animation
    let disabledAnimation: Animation
    
    init(
        enabled: Animation = .default,
        disabled: Animation = .easeInOut(duration: 0.1)
    ) {
        self.enabledAnimation = enabled
        self.disabledAnimation = disabled
    }
    
    func body(content: Content) -> some View {
        content
            .animation(
                reduceMotion ? disabledAnimation : enabledAnimation,
                value: UUID() // This would be replaced with actual state
            )
    }
}

extension View {
    func reducedMotionCompatible(
        enabled: Animation = .default,
        disabled: Animation = .easeInOut(duration: 0.1)
    ) -> some View {
        self.modifier(
            ReducedMotionModifier(enabled: enabled, disabled: disabled)
        )
    }
}

// MARK: - VoiceOver Helpers

struct VoiceOverHelper {
    static func announceSuccess(_ message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(
                notification: .announcement,
                argument: message
            )
        }
    }
    
    static func announceError(_ message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(
                notification: .announcement,
                argument: "Error: \(message)"
            )
        }
    }
    
    static func announcePageChange(_ title: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(
                notification: .screenChanged,
                argument: title
            )
        }
    }
}

// MARK: - Focus Management

struct AccessibilityFocusState {
    enum Field: Hashable {
        case title
        case date
        case saveButton
    }
}

// MARK: - Semantic Colors

extension Color {
    static let adaptivePrimary = Color(UIColor.label)
    static let adaptiveSecondary = Color(UIColor.secondaryLabel)
    static let adaptiveBackground = Color(UIColor.systemBackground)
    static let adaptiveGroupedBackground = Color(UIColor.systemGroupedBackground)
}