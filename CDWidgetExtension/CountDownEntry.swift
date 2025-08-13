import WidgetKit
import SwiftUI
import Foundation

struct CountDownEntry: TimelineEntry {
    let date: Date
    let event: Event?  // Primary event for lock screen
    let events: [Event]  // Multiple events for home screen
    
    init(date: Date, event: Event? = nil, events: [Event] = []) {
        self.date = date
        self.event = event
        self.events = events.isEmpty && event != nil ? [event!] : events
    }
    
    var displayText: String {
        guard let event = event else {
            return "イベントなし"
        }
        
        return CountdownFormatter.shared.formatForWidget(
            from: date,
            to: event.targetDate,
            title: event.title
        )
    }
    
    var countdown: String {
        guard let event = event else {
            return "---"
        }
        
        let formatter = CountdownFormatter.shared
        let result = formatter.formatCountdown(
            from: date,
            to: event.targetDate,
            isAllDay: event.isAllDay,
            postDueDisplay: .completed
        )
        
        return result.main
    }
    
    var inlineText: String {
        guard let event = event else {
            return "イベントなし"
        }
        
        return CountdownFormatter.shared.formatForInlineWidget(
            from: date,
            to: event.targetDate,
            title: event.title,
            emoji: event.emoji
        )
    }
    
    var eventColor: WidgetColor {
        guard let event = event else {
            return .gray
        }
        
        let colors: [WidgetColor] = [.blue, .green, .orange, .purple, .pink]
        return colors[event.colorId % colors.count]
    }
    
    // Helper methods for multiple events
    func countdown(for event: Event) -> String {
        let formatter = CountdownFormatter.shared
        let result = formatter.formatCountdown(
            from: date,
            to: event.targetDate,
            isAllDay: event.isAllDay,
            postDueDisplay: .completed
        )
        return result.main
    }
    
    func eventColor(for event: Event) -> WidgetColor {
        let colors: [WidgetColor] = [.blue, .green, .orange, .purple, .pink]
        return colors[event.colorId % colors.count]
    }
}

enum WidgetColor {
    case blue
    case green
    case orange
    case purple
    case pink
    case gray
    
    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .green:
            return .green
        case .orange:
            return .orange
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .gray:
            return .gray
        }
    }
}