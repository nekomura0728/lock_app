import SwiftUI

@main
struct CDWidgetApp: App {
    @StateObject private var eventManager = EventManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventManager)
        }
    }
}