import WidgetKit
import SwiftUI

struct CountDownWidgetEntryView: View {
    var entry: CountDownEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Home Screen Widgets

struct SmallWidgetView: View {
    let entry: CountDownEntry
    
    var body: some View {
        if entry.events.isEmpty {
            VStack {
                Image(systemName: "calendar")
                    .font(.title)
                    .foregroundColor(.gray)
                
                Text("イベントなし")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else if entry.events.count == 1 {
            // 1イベントの場合は大きく表示
            singleEventView(event: entry.events[0])
        } else {
            // 2イベントの場合は上下に分割
            VStack(spacing: 2) {
                ForEach(entry.events.prefix(2), id: \.id) { event in
                    compactEventView(event: event)
                }
            }
            .padding(2)
        }
    }
    
    private func singleEventView(event: Event) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(event.emoji ?? "📅")
                    .font(.title3)
                
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.countdown(for: event))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(entry.eventColor(for: event).color)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text(event.title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(entry.eventColor(for: event).color.opacity(0.1))
        )
        .padding(4)
        .widgetURL(URL(string: "cdwidget://event/\(event.id.uuidString)"))
    }
    
    private func compactEventView(event: Event) -> some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 0) {
                Text(event.title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(entry.countdown(for: event))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(entry.eventColor(for: event).color)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(event.emoji ?? "📅")
                .font(.caption)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(entry.eventColor(for: event).color.opacity(0.1))
        )
    }
    
    private var widgetURL: URL? {
        guard let event = entry.event else { return nil }
        return URL(string: "cdwidget://event/\(event.id.uuidString)")
    }
}

struct MediumWidgetView: View {
    let entry: CountDownEntry
    
    var body: some View {
        if entry.events.isEmpty {
            VStack {
                Image(systemName: "calendar")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                
                Text("イベントを作成してください")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else if entry.events.count == 1 {
            // 1イベントの場合は詳細表示
            singleEventDetailView(event: entry.events[0])
        } else {
            // 2イベントの場合は左右に分割
            HStack(spacing: 2) {
                ForEach(entry.events.prefix(2), id: \.id) { event in
                    mediumEventView(event: event)
                }
            }
            .padding(3)
        }
    }
    
    private func singleEventDetailView(event: Event) -> some View {
        HStack(spacing: 12) {
            // 左側: カウントダウン
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.countdown(for: event))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(entry.eventColor(for: event).color)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                
                Text(event.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(formattedDate(for: event))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text(dateDetail(for: event))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 右側: 絵文字（控えめなサイズ）
            Text(event.emoji ?? "📅")
                .font(.system(size: 40))
                .frame(width: 50)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(entry.eventColor(for: event).color.opacity(0.1))
        )
        .widgetURL(URL(string: "cdwidget://event/\(event.id.uuidString)"))
    }
    
    private func mediumEventView(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(event.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                Text(event.emoji ?? "📅")
                    .font(.caption)
            }
            
            Text(entry.countdown(for: event))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(entry.eventColor(for: event).color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            
            Spacer()
            
            Text(formattedDate(for: event))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(entry.eventColor(for: event).color.opacity(0.1))
        )
    }
    
    private func formattedDate(for event: Event) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: event.targetDate)
    }
    
    private func dateDetail(for event: Event) -> String {
        if event.isAllDay {
            return "終日"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: event.targetDate)
        }
    }
    
    private var widgetURL: URL? {
        guard let event = entry.event else { return nil }
        return URL(string: "cdwidget://event/\(event.id.uuidString)")
    }
}

// MARK: - Lock Screen Widgets

struct InlineWidgetView: View {
    let entry: CountDownEntry
    
    var body: some View {
        if let event = entry.event {
            HStack(spacing: 4) {
                Text(event.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(entry.countdown)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .widgetURL(widgetURL)
        } else {
            Text("イベントなし")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var widgetURL: URL? {
        guard let event = entry.event else { return nil }
        return URL(string: "cdwidget://event/\(event.id.uuidString)")
    }
}

struct CircularWidgetView: View {
    let entry: CountDownEntry
    
    var body: some View {
        ZStack {
            if let event = entry.event {
                // 背景の円
                Circle()
                    .stroke(entry.eventColor.color.opacity(0.3), lineWidth: 6)
                
                // 進捗の円
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(entry.eventColor.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                // 中央のテキスト
                VStack(spacing: 1) {
                    Text(countdownNumber)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(entry.eventColor.color)
                        .lineLimit(1)
                    
                    Text(event.title)
                        .font(.system(size: 8))
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            } else {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .widgetURL(widgetURL)
    }
    
    private var progressValue: Double {
        guard let event = entry.event else { return 0 }
        
        let totalDuration: TimeInterval = 30 * 24 * 60 * 60 // 30日
        let remaining = event.targetDate.timeIntervalSince(entry.date)
        let progress = min(max(remaining / totalDuration, 0), 1)
        
        return 1 - progress
    }
    
    private var countdownNumber: String {
        guard let event = entry.event else { return "0" }
        
        let timeInterval = event.targetDate.timeIntervalSince(entry.date)
        if timeInterval < 0 {
            return "完了"
        }
        
        let days = Int(timeInterval / 86400)
        let hours = Int((timeInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days)"
        } else {
            return "\(hours)"
        }
    }
    
    private var widgetURL: URL? {
        guard let event = entry.event else { return nil }
        return URL(string: "cdwidget://event/\(event.id.uuidString)")
    }
}

struct RectangularWidgetView: View {
    let entry: CountDownEntry
    
    var body: some View {
        Group {
            if let event = entry.event {
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(event.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text(entry.countdown)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(entry.eventColor.color)
                    }
                    
                    Spacer()
                    
                    Text(event.emoji ?? "📅")
                        .font(.caption)
                }
            } else {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("イベントなし")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .widgetURL(widgetURL)
    }
    
    private var widgetURL: URL? {
        guard let event = entry.event else { return nil }
        return URL(string: "cdwidget://event/\(event.id.uuidString)")
    }
}