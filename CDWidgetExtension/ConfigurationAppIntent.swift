import AppIntents
import SwiftUI
import WidgetKit

// MARK: - App Intent for Widget Configuration

struct ConfigurationAppIntent: AppIntent, WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "イベントを選択"
    static let description = IntentDescription("ウィジェットに表示するイベントを選択してください")
    
    // パラメータ: 選択されたイベント
    @Parameter(title: "イベント", description: "表示するイベントを選択")
    var selectedEvent: EventEntity?
    
    // パラメータ: ウィジェットスタイル
    @Parameter(title: "表示スタイル", description: "ウィジェットの表示スタイル", default: .automatic)
    var displayStyle: WidgetDisplayStyle
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// MARK: - Event Entity for App Intent

struct EventEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "イベント"
    static let defaultQuery = EventQuery()
    
    let id: String
    let title: String
    let emoji: String?
    let targetDate: Date
    let colorId: Int
    
    var displayRepresentation: DisplayRepresentation {
        let emoji = self.emoji ?? "📅"
        return DisplayRepresentation(
            title: "\(emoji) \(title)",
            subtitle: LocalizedStringResource(stringLiteral: DateFormatter.mediumDateFormatter.string(from: targetDate))
        )
    }
    
    init(from event: Event) {
        self.id = event.id.uuidString
        self.title = event.title
        self.emoji = event.emoji
        self.targetDate = event.targetDate
        self.colorId = event.colorId
    }
}

// MARK: - Event Query

struct EventQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [EventEntity] {
        let dataManager = DataManager.shared
        do {
            let events = try dataManager.loadEvents()
            return events
                .filter { identifiers.contains($0.id.uuidString) }
                .map { EventEntity(from: $0) }
        } catch {
            print("🚨 Widget Configuration Error: \(error)")
            return []
        }
    }
    
    func suggestedEntities() async throws -> [EventEntity] {
        let dataManager = DataManager.shared
        do {
            let events = try dataManager.loadEvents()
            let activeEvents = events
                .filter { !$0.isCompleted }
                .sorted { $0.targetDate < $1.targetDate }
            return Array(activeEvents.prefix(5)).map { EventEntity(from: $0) }
        } catch {
            print("🚨 Widget Configuration Error: \(error)")
            return []
        }
    }
    
    func defaultResult() async -> EventEntity? {
        do {
            let suggested = try await suggestedEntities()
            return suggested.first
        } catch {
            return nil
        }
    }
}

// MARK: - Widget Display Style

enum WidgetDisplayStyle: String, AppEnum, CaseIterable {
    case automatic = "automatic"
    case minimal = "minimal"
    case detailed = "detailed"
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "表示スタイル"
    static let caseDisplayRepresentations: [WidgetDisplayStyle: DisplayRepresentation] = [
        .automatic: "自動",
        .minimal: "シンプル",
        .detailed: "詳細"
    ]
}

// MARK: - Date Formatter Extension

extension DateFormatter {
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}