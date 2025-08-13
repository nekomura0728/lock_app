import XCTest
@testable import CDWidget

final class EventManagerTests: XCTestCase {
    var eventManager: EventManager!
    var mockDataManager: MockDataManager!
    
    override func setUpWithError() throws {
        mockDataManager = MockDataManager()
        eventManager = EventManager()
        // 実際の実装ではDependency Injectionを使用
    }
    
    override func tearDownWithError() throws {
        eventManager = nil
        mockDataManager = nil
    }
    
    // MARK: - Event Creation Tests
    
    func testCreateEventSuccess() throws {
        // Given
        let initialCount = eventManager.events.count
        let newEvent = Event(
            title: "Test Event",
            targetDate: Date().addingTimeInterval(86400), // 1日後
            emoji: "🎉"
        )
        
        // When
        eventManager.createEvent(newEvent)
        
        // Then
        XCTAssertEqual(eventManager.events.count, initialCount + 1)
        XCTAssertTrue(eventManager.events.contains { $0.title == "Test Event" })
    }
    
    func testCreateEventExceedsFreeLimitShouldShowPaywall() throws {
        // Given
        eventManager.settings.isPro = false
        
        // 無料版の制限まで追加
        let firstEvent = Event(title: "First Event", targetDate: Date().addingTimeInterval(86400))
        eventManager.createEvent(firstEvent)
        
        let secondEvent = Event(title: "Second Event", targetDate: Date().addingTimeInterval(172800))
        
        // When
        eventManager.createEvent(secondEvent)
        
        // Then
        XCTAssertEqual(eventManager.events.count, 1) // 制限により追加されない
        XCTAssertNotNil(eventManager.errorMessage)
        XCTAssertTrue(eventManager.shouldShowPaywall())
    }
    
    func testCreateEventWithProSubscription() throws {
        // Given
        eventManager.settings.isPro = true
        let initialCount = eventManager.events.count
        
        // When
        for i in 1...10 {
            let event = Event(
                title: "Event \(i)",
                targetDate: Date().addingTimeInterval(TimeInterval(i * 86400))
            )
            eventManager.createEvent(event)
        }
        
        // Then
        XCTAssertEqual(eventManager.events.count, initialCount + 10)
    }
    
    // MARK: - Event Update Tests
    
    func testUpdateEventSuccess() throws {
        // Given
        let originalEvent = Event(title: "Original", targetDate: Date().addingTimeInterval(86400))
        eventManager.createEvent(originalEvent)
        
        var updatedEvent = originalEvent
        updatedEvent.title = "Updated"
        
        // When
        eventManager.updateEvent(updatedEvent)
        
        // Then
        let foundEvent = eventManager.events.first { $0.id == originalEvent.id }
        XCTAssertEqual(foundEvent?.title, "Updated")
        XCTAssertNotNil(foundEvent?.updatedAt)
    }
    
    // MARK: - Event Deletion Tests
    
    func testDeleteEventSuccess() throws {
        // Given
        let event = Event(title: "To Delete", targetDate: Date().addingTimeInterval(86400))
        eventManager.createEvent(event)
        let initialCount = eventManager.events.count
        
        // When
        eventManager.deleteEvent(id: event.id)
        
        // Then
        XCTAssertEqual(eventManager.events.count, initialCount - 1)
        XCTAssertFalse(eventManager.events.contains { $0.id == event.id })
    }
    
    // MARK: - Event Queries Tests
    
    func testGetActiveEventsFiltersCompletedEvents() throws {
        // Given
        let activeEvent = Event(title: "Active", targetDate: Date().addingTimeInterval(86400))
        var completedEvent = Event(title: "Completed", targetDate: Date().addingTimeInterval(-86400))
        completedEvent.completedAt = Date()
        
        eventManager.createEvent(activeEvent)
        eventManager.createEvent(completedEvent)
        
        // When
        let activeEvents = eventManager.getActiveEvents()
        
        // Then
        XCTAssertEqual(activeEvents.count, 1)
        XCTAssertEqual(activeEvents.first?.title, "Active")
    }
    
    func testGetNearestUpcomingEventReturnsSoonest() throws {
        // Given
        let soonEvent = Event(title: "Soon", targetDate: Date().addingTimeInterval(3600)) // 1時間後
        let laterEvent = Event(title: "Later", targetDate: Date().addingTimeInterval(86400)) // 1日後
        
        eventManager.createEvent(laterEvent)
        eventManager.createEvent(soonEvent)
        
        // When
        let nearestEvent = eventManager.getNearestUpcomingEvent()
        
        // Then
        XCTAssertEqual(nearestEvent?.title, "Soon")
    }
    
    // MARK: - Limitation Tests
    
    func testCanCreateNewEventWithFreeTier() throws {
        // Given
        eventManager.settings.isPro = false
        
        // When & Then
        XCTAssertTrue(eventManager.canCreateNewEvent()) // 最初は作成可能
        
        let event = Event(title: "First", targetDate: Date().addingTimeInterval(86400))
        eventManager.createEvent(event)
        
        XCTAssertFalse(eventManager.canCreateNewEvent()) // 制限に達したので不可
    }
    
    func testCanCreateNewEventWithProTier() throws {
        // Given
        eventManager.settings.isPro = true
        
        // When
        for i in 1...50 {
            let event = Event(title: "Event \(i)", targetDate: Date().addingTimeInterval(TimeInterval(i * 86400)))
            eventManager.createEvent(event)
        }
        
        // Then
        XCTAssertTrue(eventManager.canCreateNewEvent()) // Proは100件まで可能
    }
    
    // MARK: - Settings Tests
    
    func testUpdateProStatusUpdatesSettings() throws {
        // Given
        XCTAssertFalse(eventManager.settings.isPro)
        
        // When
        eventManager.updateProStatus(true)
        
        // Then
        XCTAssertTrue(eventManager.settings.isPro)
    }
}

// MARK: - Mock Data Manager

class MockDataManager {
    var events: [Event] = []
    var settings: AppSettings = AppSettings()
    
    func loadEvents() throws -> [Event] {
        return events
    }
    
    func saveEvents(_ events: [Event]) throws {
        self.events = events
    }
    
    func loadSettings() throws -> AppSettings {
        return settings
    }
    
    func saveSettings(_ settings: AppSettings) throws {
        self.settings = settings
    }
}