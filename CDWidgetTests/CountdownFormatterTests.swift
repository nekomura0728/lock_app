import XCTest
@testable import CDWidget

final class CountdownFormatterTests: XCTestCase {
    var formatter: CountdownFormatter!
    
    override func setUpWithError() throws {
        formatter = CountdownFormatter.shared
    }
    
    override func tearDownWithError() throws {
        formatter = nil
    }
    
    // MARK: - Upcoming Events Tests
    
    func testFormatCountdownForDaysRemaining() throws {
        // Given
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: now)!
        
        // When
        let result = formatter.formatCountdown(
            from: now,
            to: futureDate,
            isAllDay: true,
            postDueDisplay: .completed
        )
        
        // Then
        XCTAssertTrue(result.main.contains("5"))
        XCTAssertTrue(result.main.contains("日") || result.main.contains("days"))
    }
    
    func testFormatCountdownForHoursRemaining() throws {
        // Given
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .hour, value: 3, to: now)!
        
        // When
        let result = formatter.formatCountdown(
            from: now,
            to: futureDate,
            isAllDay: false,
            postDueDisplay: .completed
        )
        
        // Then
        XCTAssertTrue(result.main.contains("3"))
        XCTAssertTrue(result.main.contains("時間") || result.main.contains("hours"))
    }
    
    func testFormatCountdownForMinutesRemaining() throws {
        // Given
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: 30, to: now)!
        
        // When
        let result = formatter.formatCountdown(
            from: now,
            to: futureDate,
            isAllDay: false,
            postDueDisplay: .completed
        )
        
        // Then
        XCTAssertTrue(result.main.contains("30"))
        XCTAssertTrue(result.main.contains("分") || result.main.contains("minutes"))
    }
    
    // MARK: - Past Due Events Tests
    
    func testFormatCountdownForCompletedPastDueEvent() throws {
        // Given
        let now = Date()
        let pastDate = Calendar.current.date(byAdding: .day, value: -2, to: now)!
        
        // When
        let result = formatter.formatCountdown(
            from: now,
            to: pastDate,
            isAllDay: true,
            postDueDisplay: .completed
        )
        
        // Then
        XCTAssertTrue(result.main.contains("完了") || result.main.contains("completed"))
    }
    
    func testFormatCountdownForElapsedPastDueEvent() throws {
        // Given
        let now = Date()
        let pastDate = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        
        // When
        let result = formatter.formatCountdown(
            from: now,
            to: pastDate,
            isAllDay: true,
            postDueDisplay: .elapsed
        )
        
        // Then
        XCTAssertTrue(result.main.contains("3"))
        XCTAssertTrue(result.main.contains("経過") || result.main.contains("elapsed"))
    }
    
    // MARK: - Widget Format Tests
    
    func testFormatForWidget() throws {
        // Given
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        let title = "Test Event"
        
        // When
        let result = formatter.formatForWidget(
            from: now,
            to: futureDate,
            title: title,
            maxLength: 20
        )
        
        // Then
        XCTAssertTrue(result.contains("Test Event"))
        XCTAssertTrue(result.contains("7"))
        XCTAssertLessThanOrEqual(result.count, 20)
    }
    
    func testFormatForInlineWidget() throws {
        // Given
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .hour, value: 2, to: now)!
        let title = "Meeting"
        let emoji = "📅"
        
        // When
        let result = formatter.formatForInlineWidget(
            from: now,
            to: futureDate,
            title: title,
            emoji: emoji
        )
        
        // Then
        XCTAssertTrue(result.contains("📅"))
        XCTAssertTrue(result.contains("Meeting"))
        XCTAssertTrue(result.contains("2"))
    }
    
    // MARK: - Edge Cases Tests
    
    func testFormatCountdownForVeryFarFuture() throws {
        // Given
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 365, to: now)!
        
        // When
        let result = formatter.formatCountdown(
            from: now,
            to: futureDate,
            isAllDay: true,
            postDueDisplay: .completed
        )
        
        // Then
        XCTAssertTrue(result.main.contains("365"))
        XCTAssertNil(result.sub) // 非常に遠い場合はサブテキストなし
    }
    
    func testFormatCountdownForSameDateTime() throws {
        // Given
        let now = Date()
        
        // When
        let result = formatter.formatCountdown(
            from: now,
            to: now,
            isAllDay: false,
            postDueDisplay: .completed
        )
        
        // Then
        XCTAssertTrue(result.main.contains("完了") || result.main.contains("completed"))
    }
    
    // MARK: - Localization Tests
    
    func testFormatCountdownUsesLocalizedStrings() throws {
        // Given
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        // When
        let result = formatter.formatCountdown(
            from: now,
            to: futureDate,
            isAllDay: true,
            postDueDisplay: .completed
        )
        
        // Then
        // 現在の言語設定に応じて適切な文字列が使用されることを確認
        let isJapanese = Locale.current.language.languageCode?.identifier == "ja"
        if isJapanese {
            XCTAssertTrue(result.main.contains("残り") && result.main.contains("日"))
        } else {
            XCTAssertTrue(result.main.contains("remaining") && result.main.contains("day"))
        }
    }
}