import SwiftUI

struct ContentView: View {
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        NavigationStack {
            EventListView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(EventManager())
}