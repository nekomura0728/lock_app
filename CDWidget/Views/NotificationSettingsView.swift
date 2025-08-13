import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    notificationStatusRow
                } header: {
                    Text("通知設定")
                } footer: {
                    Text("イベントの通知を受け取るには、通知を許可してください。")
                }
                
                if notificationManager.authorizationStatus == .authorized {
                    Section {
                        notificationTimingRow
                    } header: {
                        Text("通知タイミング")
                    } footer: {
                        Text("イベントの種類に応じて最適なタイミングで通知をお送りします。")
                    }
                }
                
                Section {
                    Button("通知テスト") {
                        scheduleTestNotification()
                    }
                    .foregroundColor(.blue)
                } footer: {
                    Text("テスト通知を5秒後に送信します。")
                }
            }
            .navigationTitle("通知設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
            .alert("エラー", isPresented: .constant(notificationManager.errorMessage != nil)) {
                Button("OK") {
                    notificationManager.errorMessage = nil
                }
            } message: {
                if let errorMessage = notificationManager.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var notificationStatusRow: some View {
        HStack {
            Image(systemName: notificationIcon)
                .foregroundColor(notificationColor)
                .font(.title2)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("通知の状態")
                    .font(.headline)
                
                Text(notificationStatusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if notificationManager.authorizationStatus == .notDetermined {
                Button("許可") {
                    Task {
                        await notificationManager.requestAuthorization()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var notificationTimingRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundColor(.orange)
                Text("1日前通知")
                    .font(.subheadline)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
            
            HStack {
                Image(systemName: "clock.arrow.2.circlepath")
                    .foregroundColor(.blue)
                Text("1時間前通知")
                    .font(.subheadline)
                Spacer()
                Text("時間指定イベントのみ")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "sun.max")
                    .foregroundColor(.yellow)
                Text("当日朝の通知")
                    .font(.subheadline)
                Spacer()
                Text("終日イベントのみ")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var notificationIcon: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "bell.fill"
        case .denied:
            return "bell.slash.fill"
        case .notDetermined:
            return "bell.badge.waveform"
        default:
            return "bell"
        }
    }
    
    private var notificationColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        default:
            return .gray
        }
    }
    
    private var notificationStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "通知が許可されています"
        case .denied:
            return "通知が拒否されています"
        case .notDetermined:
            return "通知許可が必要です"
        default:
            return "不明"
        }
    }
    
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "CDWidget テスト通知"
        content.body = "通知が正常に動作しています！"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_notification_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🚨 テスト通知エラー: \(error)")
            } else {
                print("✅ テスト通知をスケジュール")
            }
        }
    }
}

#Preview {
    NotificationSettingsView()
}