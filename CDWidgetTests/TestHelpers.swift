import Foundation
import XCTest
@testable import CDWidget

// MARK: - Test Helpers

class TestHelpers {
    
    // MARK: - Sample Data Creation
    
    static func createSampleEvent(
        title: String = "Test Event",
        daysFromNow: Int = 1,
        isAllDay: Bool = true,
        emoji: String = "📅",
        colorId: Int = 0
    ) -> Event {
        let targetDate = Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
        
        return Event(
            title: title,
            targetDate: targetDate,
            isAllDay: isAllDay,
            colorId: colorId,
            emoji: emoji
        )
    }
    
    static func createSampleEvents(count: Int) -> [Event] {
        return (0..<count).map { index in
            createSampleEvent(
                title: "Event \(index + 1)",
                daysFromNow: index + 1,
                isAllDay: index % 2 == 0,
                emoji: ["📅", "🎉", "💼", "✈️", "🎂"][index % 5],
                colorId: index % 5
            )
        }
    }
    
    static func createCompletedEvent(
        title: String = "Completed Event",
        daysAgo: Int = 1
    ) -> Event {
        let targetDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        var event = Event(title: title, targetDate: targetDate)
        event.completedAt = Date()
        return event
    }
    
    // MARK: - Test Data Cleanup
    
    static func clearTestData() {
        // テスト後のデータクリーンアップ
        // 実際の実装では、テスト専用のDataManagerまたはデータベースを使用
        UserDefaults.standard.removeObject(forKey: "test_events")
        UserDefaults.standard.removeObject(forKey: "test_settings")
    }
    
    // MARK: - Async Test Helpers
    
    static func waitForAsync<T>(
        timeout: TimeInterval = 5.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result = try await operation()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Assertion Helpers
    
    static func assertEventEquals(_ event1: Event, _ event2: Event, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(event1.id, event2.id, file: file, line: line)
        XCTAssertEqual(event1.title, event2.title, file: file, line: line)
        XCTAssertEqual(event1.targetDate, event2.targetDate, file: file, line: line)
        XCTAssertEqual(event1.isAllDay, event2.isAllDay, file: file, line: line)
        XCTAssertEqual(event1.emoji, event2.emoji, file: file, line: line)
        XCTAssertEqual(event1.colorId, event2.colorId, file: file, line: line)
    }
    
    static func assertDateWithinRange(
        _ date: Date,
        expectedDate: Date,
        tolerance: TimeInterval = 1.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let difference = abs(date.timeIntervalSince(expectedDate))
        XCTAssertLessThanOrEqual(difference, tolerance, "Date difference exceeds tolerance: \(difference)s", file: file, line: line)
    }
    
    // MARK: - Performance Testing Helpers
    
    static func measurePerformance<T>(
        name: String = "Operation",
        iterations: Int = 10,
        operation: () throws -> T
    ) throws -> T {
        var result: T!
        var totalTime: TimeInterval = 0
        
        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            result = try operation()
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            totalTime += timeElapsed
        }
        
        let averageTime = totalTime / Double(iterations)
        print("📊 \(name) average time: \(String(format: "%.4f", averageTime))s over \(iterations) iterations")
        
        return result
    }
    
    // MARK: - Mock Data Persistence
    
    static func saveTestEvents(_ events: [Event]) {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: "test_events")
        } catch {
            print("Failed to save test events: \(error)")
        }
    }
    
    static func loadTestEvents() -> [Event] {
        guard let data = UserDefaults.standard.data(forKey: "test_events") else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Event].self, from: data)
        } catch {
            print("Failed to load test events: \(error)")
            return []
        }
    }
    
    static func saveTestSettings(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: "test_settings")
        } catch {
            print("Failed to save test settings: \(error)")
        }
    }
    
    static func loadTestSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: "test_settings") else {
            return AppSettings()
        }
        
        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            print("Failed to load test settings: \(error)")
            return AppSettings()
        }
    }
}

// MARK: - XCTestCase Extensions

extension XCTestCase {
    
    func waitForAsyncOperation<T>(
        timeout: TimeInterval = 5.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await TestHelpers.waitForAsync(timeout: timeout, operation: operation)
    }
    
    func createSampleEvent(
        title: String = "Test Event",
        daysFromNow: Int = 1,
        isAllDay: Bool = true
    ) -> Event {
        return TestHelpers.createSampleEvent(
            title: title,
            daysFromNow: daysFromNow,
            isAllDay: isAllDay
        )
    }
    
    func measureAsyncPerformance<T>(
        name: String = "Async Operation",
        iterations: Int = 10,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var result: T!
        var totalTime: TimeInterval = 0
        
        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            result = try await operation()
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            totalTime += timeElapsed
        }
        
        let averageTime = totalTime / Double(iterations)
        print("📊 \(name) average time: \(String(format: "%.4f", averageTime))s over \(iterations) iterations")
        
        return result
    }
}

// MARK: - Test Configuration

struct TestConfiguration {
    static let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    static let testTimeout: TimeInterval = 10.0
    static let performanceIterations = 100
    static let shortTimeout: TimeInterval = 2.0
    static let longTimeout: TimeInterval = 30.0
}