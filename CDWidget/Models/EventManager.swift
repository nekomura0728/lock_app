import Foundation
import SwiftUI
import WidgetKit
import UserNotifications

// MARK: - Notification Protocol (内部定義)

protocol NotificationProtocol {
    func scheduleNotifications(for event: Event) async
    func clearNotifications(for event: Event) async
    func clearAllNotifications() async
}

// MARK: - Mock Implementation

class MockNotificationManager: NotificationProtocol {
    func scheduleNotifications(for event: Event) async {
        // Widget Extension用のno-op実装
    }
    
    func clearNotifications(for event: Event) async {
        // Widget Extension用のno-op実装
    }
    
    func clearAllNotifications() async {
        // Widget Extension用のno-op実装
    }
}

// MARK: - Real Implementation

class RealNotificationManager: NotificationProtocol {
    private let center = UNUserNotificationCenter.current()
    
    func scheduleNotifications(for event: Event) async {
        // 簡易的な通知実装
        print("📱 通知スケジュール: \(event.title)")
        
        // 1日前通知
        let dayBeforeIdentifier = "\(event.id.uuidString)_1day"
        let dayBeforeDate = Calendar.current.date(byAdding: .day, value: -1, to: event.targetDate)
        
        if let triggerDate = dayBeforeDate, triggerDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "明日はイベントです"
            content.body = "\(event.emoji ?? "📅") \(event.title)"
            content.sound = .default
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: dayBeforeIdentifier, content: content, trigger: trigger)
            
            try? await center.add(request)
        }
    }
    
    func clearNotifications(for event: Event) async {
        let identifiers = [
            "\(event.id.uuidString)_1day",
            "\(event.id.uuidString)_1hour",
            "\(event.id.uuidString)_morning"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func clearAllNotifications() async {
        center.removeAllPendingNotificationRequests()
    }
}

class EventManager: ObservableObject {
    @Published var events: [Event] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dataManager = DataManager.shared
    private var notificationManager: NotificationProtocol
    private let maxEventsForFree = 1
    private let maxEventsForPro = 100
    
    init() {
        // Bundle IDで主アプリかWidget Extensionかを判断
        let isWidgetExtension = Bundle.main.bundleIdentifier?.contains("Extension") ?? false
        self.notificationManager = isWidgetExtension ? MockNotificationManager() : RealNotificationManager()
        
        loadData()
        generatePresetsIfNeeded()
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try dataManager.loadEvents()
            settings = try dataManager.loadSettings()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - CRUD Operations
    
    func createEvent(_ event: Event) {
        guard canCreateNewEvent() else {
            errorMessage = "無料版では1件まで作成できます。Proにアップグレードしてください。"
            return
        }
        
        var newEvent = event
        newEvent.updatedAt = Date()
        
        events.append(newEvent)
        saveEvents()
        
        // 通知をスケジュール
        Task {
            await notificationManager.scheduleNotifications(for: newEvent)
        }
    }
    
    func updateEvent(_ event: Event) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else {
            errorMessage = "イベントが見つかりません"
            return
        }
        
        var updatedEvent = event
        updatedEvent.updatedAt = Date()
        
        events[index] = updatedEvent
        saveEvents()
        
        // 通知を再スケジュール
        Task {
            await notificationManager.scheduleNotifications(for: updatedEvent)
        }
    }
    
    func deleteEvent(id: UUID) {
        if let event = events.first(where: { $0.id == id }) {
            // 通知をクリア
            Task {
                await notificationManager.clearNotifications(for: event)
            }
        }
        
        events.removeAll { $0.id == id }
        saveEvents()
    }
    
    func duplicateEvent(id: UUID) {
        guard let originalEvent = events.first(where: { $0.id == id }) else {
            errorMessage = "複製するイベントが見つかりません"
            return
        }
        
        guard canCreateNewEvent() else {
            errorMessage = "無料版では1件まで作成できます。Proにアップグレードしてください。"
            return
        }
        
        let duplicatedEvent = Event(
            title: originalEvent.title + " (コピー)",
            targetDate: originalEvent.targetDate,
            isAllDay: originalEvent.isAllDay,
            colorId: originalEvent.colorId,
            emoji: originalEvent.emoji,
            notifyPolicy: originalEvent.notifyPolicy
        )
        
        events.append(duplicatedEvent)
        saveEvents()
        
        // 通知をスケジュール
        Task {
            await notificationManager.scheduleNotifications(for: duplicatedEvent)
        }
    }
    
    func completeEvent(id: UUID) {
        guard let index = events.firstIndex(where: { $0.id == id }) else {
            errorMessage = "イベントが見つかりません"
            return
        }
        
        events[index].completedAt = Date()
        events[index].updatedAt = Date()
        saveEvents()
    }
    
    // MARK: - Event Queries
    
    func getNearestUpcomingEvent() -> Event? {
        let upcomingEvents = events
            .filter { !$0.isCompleted && !$0.isPastDue }
            .sorted { $0.targetDate < $1.targetDate }
        
        return upcomingEvents.first
    }
    
    func getActiveEvents() -> [Event] {
        return events
            .filter { !$0.isCompleted }
            .sorted { $0.targetDate < $1.targetDate }
    }
    
    func getCompletedEvents() -> [Event] {
        return events
            .filter { $0.isCompleted }
            .sorted { $0.updatedAt > $1.updatedAt }
    }
    
    // MARK: - Limitation Checks
    
    func canCreateNewEvent() -> Bool {
        let activeEventCount = events.filter { !$0.isCompleted }.count
        
        if settings.isPro {
            return activeEventCount < maxEventsForPro
        } else {
            return activeEventCount < maxEventsForFree
        }
    }
    
    func shouldShowPaywall() -> Bool {
        let activeEventCount = events.filter { !$0.isCompleted }.count
        return !settings.isPro && activeEventCount >= maxEventsForFree
    }
    
    // MARK: - Settings Management
    
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        saveSettings()
    }
    
    func updateProStatus(_ isPro: Bool) {
        settings.isPro = isPro
        saveSettings()
    }
    
    // MARK: - Private Methods
    
    private func saveEvents() {
        do {
            try dataManager.saveEvents(events)
            // ウィジェットを強制更新
            WidgetCenter.shared.reloadAllTimelines()
            print("🔄 ウィジェット更新要求送信")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func saveSettings() {
        do {
            try dataManager.saveSettings(settings)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func generatePresetsIfNeeded() {
        guard events.isEmpty else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        // プリセット1: 給料日（毎月25日）
        var salaryComponents = calendar.dateComponents([.year, .month], from: now)
        salaryComponents.day = 25
        if let salaryDate = calendar.date(from: salaryComponents), salaryDate <= now {
            salaryComponents.month! += 1
        }
        
        if let salaryDate = calendar.date(from: salaryComponents) {
            let salaryEvent = Event(
                title: "給料日",
                targetDate: salaryDate,
                isAllDay: true,
                colorId: 0,
                emoji: "💰"
            )
            events.append(salaryEvent)
        }
        
        // プリセット2: 旅行（2ヶ月後）
        if let tripDate = calendar.date(byAdding: .month, value: 2, to: now) {
            let tripEvent = Event(
                title: "旅行",
                targetDate: tripDate,
                isAllDay: true,
                colorId: 1,
                emoji: "✈️"
            )
            events.append(tripEvent)
        }
        
        // プリセット3: レポート締切（1週間後）
        if let reportDate = calendar.date(byAdding: .weekOfYear, value: 1, to: now) {
            let reportEvent = Event(
                title: "レポート締切",
                targetDate: reportDate,
                isAllDay: false,
                colorId: 2,
                emoji: "📝"
            )
            events.append(reportEvent)
        }
        
        // 最初の1件のみ保持（無料版制限）
        if !events.isEmpty {
            events = Array(events.prefix(1))
            saveEvents()
        }
    }
}