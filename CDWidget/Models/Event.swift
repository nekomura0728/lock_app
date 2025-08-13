import Foundation

struct Event: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var targetDate: Date
    var isAllDay: Bool
    var colorId: Int
    var emoji: String?
    var notifyPolicy: NotificationPolicy
    let createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        targetDate: Date,
        isAllDay: Bool = false,
        colorId: Int = 0,
        emoji: String? = nil,
        notifyPolicy: NotificationPolicy = NotificationPolicy(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.isAllDay = isAllDay
        self.colorId = colorId
        self.emoji = emoji
        self.notifyPolicy = notifyPolicy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }
    
    var isCompleted: Bool {
        completedAt != nil
    }
    
    var isPastDue: Bool {
        Date() > targetDate
    }
    
    var timeRemaining: TimeInterval {
        targetDate.timeIntervalSince(Date())
    }
}

struct NotificationPolicy: Codable, Hashable {
    var oneDayBefore: Bool
    var oneHourBefore: Bool
    var morningOfDay: Bool
    
    init(
        oneDayBefore: Bool = false,
        oneHourBefore: Bool = false,
        morningOfDay: Bool = false
    ) {
        self.oneDayBefore = oneDayBefore
        self.oneHourBefore = oneHourBefore
        self.morningOfDay = morningOfDay
    }
}