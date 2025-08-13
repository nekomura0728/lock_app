import WidgetKit
import SwiftUI

struct CountDownProvider: AppIntentTimelineProvider {
    private let dataManager = DataManager.shared
    
    typealias Entry = CountDownEntry
    typealias Intent = ConfigurationAppIntent
    
    func placeholder(in context: Context) -> CountDownEntry {
        let placeholderEvent = Event(
            title: "イベント",
            targetDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            emoji: "📅"
        )
        
        return CountDownEntry(
            date: Date(),
            event: placeholderEvent
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> CountDownEntry {
        return createEntry(for: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<CountDownEntry> {
        let now = Date()
        let calendar = Calendar.current
        
        // 1時間ごとにエントリを生成
        let entries = stride(from: 0, through: 24, by: 1).compactMap { hour -> CountDownEntry? in
            guard let date = calendar.date(byAdding: .hour, value: hour, to: now) else {
                return nil
            }
            return createEntry(for: date, configuration: configuration)
        }
        
        // 次の更新は12時間後
        let nextUpdate = calendar.date(byAdding: .hour, value: 12, to: now) ?? now
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        
        return timeline
    }
    
    private func createEntry(for date: Date, configuration: ConfigurationAppIntent? = nil) -> CountDownEntry {
        do {
            let events = try dataManager.loadEvents()
            let settings = try dataManager.loadSettings()
            
            print("📊 Widget Debug: 読み込んだイベント数: \(events.count)")
            events.forEach { event in
                print("📅 Event: \(event.title), 日時: \(event.targetDate), 完了: \(event.isCompleted)")
            }
            
            let activeEvents = events
                .filter { !$0.isCompleted }
                .sorted { $0.targetDate < $1.targetDate }
            
            print("✅ アクティブなイベント数: \(activeEvents.count)")
            
            // 設定されたイベントがある場合は優先的に使用
            var selectedEvents: [Event] = []
            var primaryEvent: Event?
            
            if let configuredEventId = configuration?.selectedEvent?.id,
               let configuredEvent = activeEvents.first(where: { $0.id.uuidString == configuredEventId }) {
                // 設定されたイベントを優先
                selectedEvents = [configuredEvent]
                primaryEvent = configuredEvent
                print("🎯 設定されたイベントを使用: \(configuredEvent.title)")
            } else {
                // 通常のロジック（有料版では最大2つ、無料版は1つ）
                let maxEvents = settings.isPro ? 2 : 1
                selectedEvents = Array(activeEvents.prefix(maxEvents))
                primaryEvent = selectedEvents.first
            }
            
            if let event = primaryEvent {
                print("🎯 選択されたイベント: \(event.title)")
            } else {
                print("❌ 選択されたイベントなし")
            }
            
            return CountDownEntry(
                date: date,
                event: primaryEvent,
                events: selectedEvents
            )
        } catch {
            print("🚨 Widget Error: \(error.localizedDescription)")
            // エラー時は空の配列を返す
            return CountDownEntry(
                date: date,
                event: nil,
                events: []
            )
        }
    }
}