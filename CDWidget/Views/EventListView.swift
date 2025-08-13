import SwiftUI
import WidgetKit

struct EventListView: View {
    @EnvironmentObject var eventManager: EventManager
    @State private var showingEventEdit = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingEvent: Event?
    
    var body: some View {
        NavigationStack {
            VStack {
                if eventManager.isLoading {
                    VStack {
                        LoadingDotsView()
                        Text(NSLocalizedString("Loading...", comment: ""))
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .slideUpTransition()
                } else if eventManager.events.isEmpty {
                    emptyStateView
                        .slideUpTransition()
                } else {
                    eventsList
                        .slideUpTransition()
                }
                
                Spacer()
            }
            .navigationTitle(NSLocalizedString("Events", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("Settings", comment: "")) {
                        HapticFeedback.light()
                        showingSettings = true
                    }
                    .springButton()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticFeedback.medium()
                        addNewEvent()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                    .springButton()
                }
            }
            .sheet(isPresented: $showingEventEdit) {
                EventEditView(event: editingEvent)
                    .environmentObject(eventManager)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(eventManager)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(eventManager)
            }
            .alert("エラー", isPresented: .constant(eventManager.errorMessage != nil)) {
                Button("OK") {
                    eventManager.errorMessage = nil
                }
            } message: {
                if let errorMessage = eventManager.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(NSLocalizedString("Add Widget to Home Screen", comment: ""))
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(NSLocalizedString("Create First Event", comment: "")) {
                HapticFeedback.success()
                addNewEvent()
            }
            .buttonStyle(.borderedProminent)
            .springButton()
            
            Button(NSLocalizedString("How to Add Widgets", comment: "")) {
                HapticFeedback.light()
                // Widget追加ガイドを表示
            }
            .buttonStyle(.bordered)
            .springButton()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var eventsList: some View {
        List {
            ForEach(eventManager.getActiveEvents()) { event in
                EventRowView(event: event) {
                    editingEvent = event
                    showingEventEdit = true
                }
            }
            .onDelete(perform: deleteEvents)
        }
        .listStyle(PlainListStyle())
    }
    
    private func addNewEvent() {
        if eventManager.shouldShowPaywall() {
            showingPaywall = true
        } else {
            editingEvent = nil
            showingEventEdit = true
        }
    }
    
    private func forceUpdateWidget() {
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 手動ウィジェット更新実行")
    }
    
    private func deleteEvents(offsets: IndexSet) {
        let activeEvents = eventManager.getActiveEvents()
        for index in offsets {
            if index < activeEvents.count {
                eventManager.deleteEvent(id: activeEvents[index].id)
            }
        }
    }
}

struct EventRowView: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap()
        }) {
            HStack {
                // 色とEmoji
                Circle()
                    .fill(eventColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(event.emoji ?? "📅")
                            .font(.title2)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(countdownText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(mainCountdown)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(event.isPastDue ? .red : .primary)
                    
                    if let subCountdown = subCountdown {
                        Text(subCountdown)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .springButton()
        .accessibilityEventRow(
            title: event.title,
            countdown: countdownText,
            date: formattedDate,
            isOverdue: event.isPastDue
        )
    }
    
    private var eventColor: Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        return colors[event.colorId % colors.count]
    }
    
    private var countdownText: String {
        let formatter = CountdownFormatter.shared
        let result = formatter.formatCountdown(
            from: Date(),
            to: event.targetDate,
            isAllDay: event.isAllDay,
            postDueDisplay: .completed
        )
        return result.main
    }
    
    private var mainCountdown: String {
        let formatter = CountdownFormatter.shared
        let result = formatter.formatCountdown(
            from: Date(),
            to: event.targetDate,
            isAllDay: event.isAllDay,
            postDueDisplay: .completed
        )
        return result.main
    }
    
    private var subCountdown: String? {
        let formatter = CountdownFormatter.shared
        let result = formatter.formatCountdown(
            from: Date(),
            to: event.targetDate,
            isAllDay: event.isAllDay,
            postDueDisplay: .completed
        )
        return result.sub
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        if event.isAllDay {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        }
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: event.targetDate)
    }
}

#Preview {
    NavigationStack {
        EventListView()
            .environmentObject(EventManager())
    }
}