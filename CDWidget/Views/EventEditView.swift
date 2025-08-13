import SwiftUI

struct EventEditView: View {
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dismiss) private var dismiss
    
    let event: Event?
    
    @State private var title: String = ""
    @State private var targetDate: Date = Date()
    @State private var isAllDay: Bool = false
    @State private var selectedColorId: Int = 0
    @State private var selectedEmoji: String? = nil
    @State private var notifyPolicy: NotificationPolicy = NotificationPolicy()
    
    @State private var showingEmojiPicker = false
    
    private let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
    private let emojis = ["📅", "🎯", "✈️", "🎓", "💰", "🎉", "📝", "💼", "🏠", "❤️"]
    
    var isEditing: Bool {
        event != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                eventDetailsSection
                appearanceSection
                notificationSection
            }
            .navigationTitle(isEditing ? "イベント編集" : "新しいイベント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            loadEventData()
        }
    }
    
    private var eventDetailsSection: some View {
        Section("イベント詳細") {
            TextField("タイトル", text: $title)
                .font(.title3)
            
            DatePicker(
                "日時",
                selection: $targetDate,
                displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
            )
            
            Toggle("終日", isOn: $isAllDay)
        }
    }
    
    private var appearanceSection: some View {
        Section("外観") {
            colorSelectionView
            emojiSelectionView
        }
    }
    
    private var colorSelectionView: some View {
        VStack(alignment: .leading) {
            Text("色")
                .font(.headline)
            
            colorButtonsHStack
        }
    }
    
    private var colorButtonsHStack: some View {
        HStack {
            ForEach(0..<colors.count, id: \.self) { index in
                colorButton(for: index)
            }
            Spacer()
        }
    }
    
    private func colorButton(for index: Int) -> some View {
        Button {
            selectedColorId = index
        } label: {
            Circle()
                .fill(colors[index])
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(selectedColorId == index ? Color.primary : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var emojiSelectionView: some View {
        VStack(alignment: .leading) {
            Text("絵文字")
                .font(.headline)
            
            emojiGrid
        }
    }
    
    private var emojiGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
            ForEach(emojis, id: \.self) { emoji in
                emojiButton(for: emoji)
            }
        }
    }
    
    private func emojiButton(for emoji: String) -> some View {
        Button {
            selectedEmoji = selectedEmoji == emoji ? nil : emoji
        } label: {
            Text(emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(
                    selectedEmoji == emoji ? Color.gray.opacity(0.3) : Color.clear
                )
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var notificationSection: some View {
        Section("通知") {
            Toggle("1日前", isOn: $notifyPolicy.oneDayBefore)
            Toggle("1時間前", isOn: $notifyPolicy.oneHourBefore)
            Toggle("当日朝", isOn: $notifyPolicy.morningOfDay)
        }
    }
    
    private func loadEventData() {
        if let event = event {
            title = event.title
            targetDate = event.targetDate
            isAllDay = event.isAllDay
            selectedColorId = event.colorId
            selectedEmoji = event.emoji
            notifyPolicy = event.notifyPolicy
        } else {
            // 新規作成時のデフォルト値
            targetDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        }
    }
    
    private func saveEvent() {
        let newEvent = Event(
            id: event?.id ?? UUID(),
            title: title,
            targetDate: targetDate,
            isAllDay: isAllDay,
            colorId: selectedColorId,
            emoji: selectedEmoji,
            notifyPolicy: notifyPolicy,
            createdAt: event?.createdAt ?? Date(),
            updatedAt: Date(),
            completedAt: event?.completedAt
        )
        
        if isEditing {
            eventManager.updateEvent(newEvent)
        } else {
            eventManager.createEvent(newEvent)
        }
        
        dismiss()
    }
}

#Preview {
    EventEditView(event: nil)
        .environmentObject(EventManager())
}