import XCTest
import UserNotifications
@testable import CDWidget

final class NotificationManagerTests: XCTestCase {
    var notificationManager: NotificationManager!
    var mockNotificationCenter: MockUNUserNotificationCenter!
    
    override func setUpWithError() throws {
        mockNotificationCenter = MockUNUserNotificationCenter()
        notificationManager = NotificationManager()
        // 実際の実装ではDependency Injectionを使用
    }
    
    override func tearDownWithError() throws {
        notificationManager = nil
        mockNotificationCenter = nil
    }
    
    // MARK: - Authorization Tests
    
    func testRequestAuthorizationSuccess() async throws {
        // Given
        mockNotificationCenter.authorizationGranted = true
        
        // When
        await notificationManager.requestAuthorization()
        
        // Then
        XCTAssertEqual(notificationManager.authorizationStatus, .authorized)
        XCTAssertTrue(mockNotificationCenter.requestAuthorizationCalled)
    }
    
    func testRequestAuthorizationDenied() async throws {
        // Given
        mockNotificationCenter.authorizationGranted = false
        
        // When
        await notificationManager.requestAuthorization()
        
        // Then
        XCTAssertEqual(notificationManager.authorizationStatus, .denied)
        XCTAssertTrue(mockNotificationCenter.requestAuthorizationCalled)
    }
    
    // MARK: - Notification Scheduling Tests
    
    func testScheduleNotificationsForAllDayEvent() async throws {
        // Given
        notificationManager.authorizationStatus = .authorized
        let event = Event(
            title: "All Day Event",
            targetDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            isAllDay: true,
            emoji: "📅"
        )
        
        // When
        await notificationManager.scheduleNotifications(for: event)
        
        // Then
        let scheduledCount = mockNotificationCenter.scheduledNotifications.count
        XCTAssertGreaterThan(scheduledCount, 0)
        
        // 終日イベントでは当日朝通知が含まれることを確認
        let hasMorningNotification = mockNotificationCenter.scheduledNotifications.contains { request in
            request.identifier.contains("_morning")
        }
        XCTAssertTrue(hasMorningNotification)
    }
    
    func testScheduleNotificationsForTimedEvent() async throws {
        // Given
        notificationManager.authorizationStatus = .authorized
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let event = Event(
            title: "Timed Event",
            targetDate: futureDate,
            isAllDay: false,
            emoji: "⏰"
        )
        
        // When
        await notificationManager.scheduleNotifications(for: event)
        
        // Then
        let scheduledCount = mockNotificationCenter.scheduledNotifications.count
        XCTAssertGreaterThan(scheduledCount, 0)
        
        // 時間指定イベントでは1時間前通知が含まれることを確認
        let hasHourlyNotification = mockNotificationCenter.scheduledNotifications.contains { request in
            request.identifier.contains("_1hour")
        }
        XCTAssertTrue(hasHourlyNotification)
    }
    
    func testScheduleNotificationsWithoutAuthorization() async throws {
        // Given
        notificationManager.authorizationStatus = .denied
        let event = Event(
            title: "Test Event",
            targetDate: Date().addingTimeInterval(86400),
            emoji: "📅"
        )
        
        // When
        await notificationManager.scheduleNotifications(for: event)
        
        // Then
        XCTAssertEqual(mockNotificationCenter.scheduledNotifications.count, 0)
    }
    
    // MARK: - Notification Content Tests
    
    func testNotificationContentForDailyReminder() async throws {
        // Given
        notificationManager.authorizationStatus = .authorized
        let event = Event(
            title: "Important Meeting",
            targetDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            isAllDay: false,
            emoji: "💼"
        )
        
        // When
        await notificationManager.scheduleNotifications(for: event)
        
        // Then
        let dayBeforeNotification = mockNotificationCenter.scheduledNotifications.first { request in
            request.identifier.contains("_1day")
        }
        
        XCTAssertNotNil(dayBeforeNotification)
        XCTAssertTrue(dayBeforeNotification!.content.title.contains("明日") || dayBeforeNotification!.content.title.contains("Tomorrow"))
        XCTAssertTrue(dayBeforeNotification!.content.body.contains("Important Meeting"))
        XCTAssertTrue(dayBeforeNotification!.content.body.contains("💼"))
    }
    
    // MARK: - Clear Notifications Tests
    
    func testClearNotificationsForEvent() async throws {
        // Given
        let event = Event(title: "Test Event", targetDate: Date().addingTimeInterval(86400))
        await notificationManager.scheduleNotifications(for: event)
        
        // When
        await notificationManager.clearNotifications(for: event)
        
        // Then
        XCTAssertTrue(mockNotificationCenter.removePendingCalled)
        
        let expectedIdentifiers = [
            "\(event.id.uuidString)_1day",
            "\(event.id.uuidString)_1hour",
            "\(event.id.uuidString)_morning"
        ]
        
        XCTAssertEqual(Set(mockNotificationCenter.removedIdentifiers), Set(expectedIdentifiers))
    }
    
    func testClearAllNotifications() async throws {
        // Given
        let event1 = Event(title: "Event 1", targetDate: Date().addingTimeInterval(86400))
        let event2 = Event(title: "Event 2", targetDate: Date().addingTimeInterval(172800))
        await notificationManager.scheduleNotifications(for: event1)
        await notificationManager.scheduleNotifications(for: event2)
        
        // When
        await notificationManager.clearAllNotifications()
        
        // Then
        XCTAssertTrue(mockNotificationCenter.removeAllPendingCalled)
    }
    
    // MARK: - Edge Cases Tests
    
    func testScheduleNotificationsForPastEvent() async throws {
        // Given
        notificationManager.authorizationStatus = .authorized
        let pastEvent = Event(
            title: "Past Event",
            targetDate: Date().addingTimeInterval(-86400), // 1日前
            emoji: "📅"
        )
        
        // When
        await notificationManager.scheduleNotifications(for: pastEvent)
        
        // Then
        // 過去のイベントには通知をスケジュールしない
        XCTAssertEqual(mockNotificationCenter.scheduledNotifications.count, 0)
    }
    
    func testScheduleNotificationsForVeryNearEvent() async throws {
        // Given
        notificationManager.authorizationStatus = .authorized
        let nearEvent = Event(
            title: "Near Event",
            targetDate: Date().addingTimeInterval(1800), // 30分後
            isAllDay: false,
            emoji: "⏰"
        )
        
        // When
        await notificationManager.scheduleNotifications(for: nearEvent)
        
        // Then
        // 1時間前通知は設定されないが、1日前通知は設定されない
        let hasHourlyNotification = mockNotificationCenter.scheduledNotifications.contains { request in
            request.identifier.contains("_1hour")
        }
        XCTAssertFalse(hasHourlyNotification)
    }
}

// MARK: - Mock UNUserNotificationCenter

class MockUNUserNotificationCenter {
    var authorizationGranted = true
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    var requestAuthorizationCalled = false
    var scheduledNotifications: [UNNotificationRequest] = []
    var removePendingCalled = false
    var removeAllPendingCalled = false
    var removedIdentifiers: [String] = []
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestAuthorizationCalled = true
        authorizationStatus = authorizationGranted ? .authorized : .denied
        return authorizationGranted
    }
    
    func add(_ request: UNNotificationRequest) async throws {
        scheduledNotifications.append(request)
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removePendingCalled = true
        removedIdentifiers.append(contentsOf: identifiers)
        scheduledNotifications.removeAll { request in
            identifiers.contains(request.identifier)
        }
    }
    
    func removeAllPendingNotificationRequests() {
        removeAllPendingCalled = true
        scheduledNotifications.removeAll()
    }
    
    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        return scheduledNotifications
    }
    
    func notificationSettings() async -> UNNotificationSettings {
        return UNNotificationSettings()
    }
}