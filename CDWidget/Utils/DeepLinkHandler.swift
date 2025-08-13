import Foundation
import SwiftUI

class DeepLinkHandler: ObservableObject {
    @Published var selectedEventId: UUID?
    @Published var shouldShowEventEdit = false
    
    func handleURL(_ url: URL) -> Bool {
        guard url.scheme == "cdwidget" else {
            return false
        }
        
        guard url.host == "event" else {
            return false
        }
        
        let pathComponents = url.pathComponents
        guard pathComponents.count >= 2 else {
            // 不正なURLの場合は安全にメイン画面にフォールバック
            return true
        }
        
        let eventIdString = pathComponents[1]
        guard let eventId = UUID(uuidString: eventIdString) else {
            // 不正なUUIDの場合も安全にメイン画面にフォールバック
            return true
        }
        
        // イベント編集画面を表示
        selectedEventId = eventId
        shouldShowEventEdit = true
        
        return true
    }
    
    func resetDeepLink() {
        selectedEventId = nil
        shouldShowEventEdit = false
    }
}

extension CDWidgetApp {
    func handleDeepLink(_ eventManager: EventManager) -> some View {
        ContentView()
            .environmentObject(eventManager)
            .onOpenURL { url in
                let deepLinkHandler = DeepLinkHandler()
                _ = deepLinkHandler.handleURL(url)
                
                // イベントが存在するかチェック
                if let eventId = deepLinkHandler.selectedEventId,
                   let _ = eventManager.events.first(where: { $0.id == eventId }) {
                    // イベント編集画面を表示
                    // NavigationPath経由で編集画面に遷移
                }
            }
    }
}