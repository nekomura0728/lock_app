import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject, NotificationProtocol {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private let center = UNUserNotificationCenter.current()
    
    init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    @MainActor
    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus()
            
            if granted {
                print("✅ 通知許可が付与されました")
            } else {
                print("❌ 通知許可が拒否されました")
            }
        } catch {
            errorMessage = "通知許可の取得に失敗しました: \(error.localizedDescription)"
            print("🚨 Notification Authorization Error: \(error)")
        }
    }
    
    @MainActor
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        print("🔔 通知許可状況: \(authorizationStatus)")
    }
    
    // MARK: - Schedule Notifications
    
    @MainActor
    func scheduleNotifications(for event: Event) async {
        guard authorizationStatus == .authorized else {
            print("⚠️ 通知が許可されていません")
            return
        }
        
        // 既存の通知をクリア
        await clearNotifications(for: event)
        
        // 通知をスケジュール
        await scheduleEventNotifications(for: event)
    }
    
    private func scheduleEventNotifications(for event: Event) async {
        let notifications = createNotifications(for: event)
        
        for notification in notifications {
            do {
                try await center.add(notification)
                print("📅 通知をスケジュール: \(notification.identifier)")
            } catch {
                print("🚨 通知スケジュールエラー: \(error)")
            }
        }
    }
    
    private func createNotifications(for event: Event) -> [UNNotificationRequest] {
        var notifications: [UNNotificationRequest] = []
        let now = Date()
        
        // 1日前通知
        if let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: event.targetDate),
           oneDayBefore > now {
            let content = createNotificationContent(
                title: "明日はイベントです！",
                body: "\(event.emoji ?? "📅") \(event.title) が明日に迫っています",
                event: event
            )
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneDayBefore),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "\(event.id.uuidString)_1day",
                content: content,
                trigger: trigger
            )
            notifications.append(request)
        }
        
        // 1時間前通知（終日でない場合のみ）
        if !event.isAllDay {
            if let oneHourBefore = Calendar.current.date(byAdding: .hour, value: -1, to: event.targetDate),
               oneHourBefore > now {
                let content = createNotificationContent(
                    title: "もうすぐイベントです！",
                    body: "\(event.emoji ?? "📅") \(event.title) が1時間後に開始されます",
                    event: event
                )
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneHourBefore),
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "\(event.id.uuidString)_1hour",
                    content: content,
                    trigger: trigger
                )
                notifications.append(request)
            }
        }
        
        // 当日朝通知（終日の場合のみ）
        if event.isAllDay {
            let morningTime = Calendar.current.dateComponents([.year, .month, .day], from: event.targetDate)
            var morningComponents = morningTime
            morningComponents.hour = 8
            morningComponents.minute = 0
            
            if let morningDate = Calendar.current.date(from: morningComponents),
               morningDate > now {
                let content = createNotificationContent(
                    title: "今日はイベントです！",
                    body: "\(event.emoji ?? "📅") \(event.title) の日です",
                    event: event
                )
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: morningComponents,
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "\(event.id.uuidString)_morning",
                    content: content,
                    trigger: trigger
                )
                notifications.append(request)
            }
        }
        
        return notifications
    }
    
    private func createNotificationContent(title: String, body: String, event: Event) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Deep Linkのためのユーザー情報
        content.userInfo = [
            "eventId": event.id.uuidString,
            "eventTitle": event.title
        ]
        
        return content
    }
    
    // MARK: - Clear Notifications
    
    @MainActor
    func clearNotifications(for event: Event) async {
        let identifiers = [
            "\(event.id.uuidString)_1day",
            "\(event.id.uuidString)_1hour",
            "\(event.id.uuidString)_morning"
        ]
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ イベントの通知をクリア: \(event.title)")
    }
    
    @MainActor
    func clearAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        print("🗑️ すべての通知をクリア")
    }
    
    // MARK: - Debug
    
    func listPendingNotifications() async {
        let requests = await center.pendingNotificationRequests()
        print("📋 予定されている通知数: \(requests.count)")
        for request in requests {
            print("  - \(request.identifier): \(request.content.title)")
        }
    }
}

// MARK: - Helper Extensions

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "未決定"
        case .denied:
            return "拒否"
        case .authorized:
            return "許可"
        case .provisional:
            return "仮許可"
        case .ephemeral:
            return "一時的"
        @unknown default:
            return "不明"
        }
    }
}