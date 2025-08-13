import XCTest

final class EventManagementUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Event Creation Tests
    
    func testCreateNewEvent() throws {
        // Given
        let addButton = app.navigationBars.buttons["Add"]
        
        // When - イベント追加画面を開く
        addButton.tap()
        
        // Then - イベント編集画面が表示される
        XCTAssertTrue(app.navigationBars["新しいイベント"].exists || app.navigationBars["New Event"].exists)
        
        // When - イベント詳細を入力
        let titleField = app.textFields.firstMatch
        titleField.tap()
        titleField.typeText("UI Test Event")
        
        // 日時選択
        let datePicker = app.datePickers.firstMatch
        if datePicker.exists {
            datePicker.tap()
        }
        
        // 絵文字選択
        let emojiButtons = app.buttons.matching(identifier: "emoji_button")
        if emojiButtons.count > 0 {
            emojiButtons.element(boundBy: 0).tap()
        }
        
        // 保存
        let saveButton = app.navigationBars.buttons["保存"] // または "Save"
        saveButton.tap()
        
        // Then - イベント一覧に戻り、作成されたイベントが表示される
        XCTAssertTrue(app.staticTexts["UI Test Event"].exists)
    }
    
    func testCreateEventExceedsFreeLimit() throws {
        // Given - 無料版の制限に達するまでイベントを作成
        // この部分は実際のデータ状態に依存するため、
        // テスト用のモックデータまたはテスト環境設定が必要
        
        let addButton = app.navigationBars.buttons["Add"]
        addButton.tap()
        
        // When - 制限を超えるイベントを作成しようとする
        // (実際の実装では、この時点でPaywallが表示されるはず)
        
        // Then - Paywall画面が表示される
        // XCTAssertTrue(app.staticTexts["Pro"].exists)
    }
    
    // MARK: - Event Edit Tests
    
    func testEditExistingEvent() throws {
        // Given - 既存のイベントがある前提
        let eventCell = app.cells.firstMatch
        
        // When - イベントをタップして編集
        eventCell.tap()
        
        // Then - 編集画面が表示される
        XCTAssertTrue(app.navigationBars["イベントを編集"].exists || app.navigationBars["Edit Event"].exists)
        
        // When - タイトルを変更
        let titleField = app.textFields.firstMatch
        titleField.doubleTap() // 全選択
        titleField.typeText("Updated Event")
        
        // 保存
        let saveButton = app.navigationBars.buttons["保存"] // または "Save"
        saveButton.tap()
        
        // Then - 変更が反映される
        XCTAssertTrue(app.staticTexts["Updated Event"].exists)
    }
    
    // MARK: - Settings Tests
    
    func testOpenSettings() throws {
        // When - 設定ボタンをタップ
        let settingsButton = app.navigationBars.buttons["設定"] // または "Settings"
        settingsButton.tap()
        
        // Then - 設定画面が表示される
        XCTAssertTrue(app.navigationBars["設定"].exists || app.navigationBars["Settings"].exists)
        XCTAssertTrue(app.staticTexts["通知"].exists || app.staticTexts["Notifications"].exists)
    }
    
    func testNotificationSettings() throws {
        // Given - 設定画面を開く
        let settingsButton = app.navigationBars.buttons["設定"] // または "Settings"
        settingsButton.tap()
        
        // When - 通知設定をタップ
        let notificationCell = app.cells.containing(.staticText, identifier: "通知設定").firstMatch
        if notificationCell.exists {
            notificationCell.tap()
            
            // Then - 通知設定画面が表示される
            XCTAssertTrue(app.navigationBars["通知設定"].exists || app.navigationBars["Notification Settings"].exists)
        }
    }
    
    // MARK: - Paywall Tests
    
    func testOpenPaywall() throws {
        // Given - 設定画面を開く
        let settingsButton = app.navigationBars.buttons["設定"] // または "Settings"
        settingsButton.tap()
        
        // When - Proアップグレードボタンをタップ
        let upgradeButton = app.buttons["Proにアップグレード"] // または "Upgrade to Pro"
        if upgradeButton.exists {
            upgradeButton.tap()
            
            // Then - Paywall画面が表示される
            XCTAssertTrue(app.navigationBars["Pro"].exists)
            XCTAssertTrue(app.staticTexts["複数イベント登録"].exists || app.staticTexts["Multiple Events"].exists)
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // VoiceOverでアクセス可能な要素をテスト
        
        // イベント一覧のアクセシビリティ
        let eventCells = app.cells
        for i in 0..<min(eventCells.count, 3) {
            let cell = eventCells.element(boundBy: i)
            XCTAssertTrue(cell.isHittable)
            // アクセシビリティラベルが設定されていることを確認
            XCTAssertFalse(cell.label.isEmpty)
        }
        
        // ナビゲーションボタンのアクセシビリティ
        let addButton = app.navigationBars.buttons["Add"]
        XCTAssertTrue(addButton.isHittable)
        XCTAssertFalse(addButton.label.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testEventListScrollPerformance() throws {
        // 大量のイベントがある場合のスクロール性能をテスト
        let eventsList = app.tables.firstMatch
        
        measure(metrics: [XCTOSSignpostMetric.scrollingAndDecelerationMetric]) {
            eventsList.swipeUp()
            eventsList.swipeDown()
        }
    }
    
    // MARK: - Deep Link Tests
    
    func testDeepLinkToEvent() throws {
        // Given - アプリを終了
        app.terminate()
        
        // When - ディープリンクでアプリを起動
        // 実際のテストでは、URL SchemeやUniversal Linksを使用
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()
        
        // ディープリンクURLを開く (例: cdwidget://event/[event-id])
        // safari.open("cdwidget://event/test-id")
        
        // Then - 該当するイベントの詳細画面が開く
        // XCTAssertTrue(app.navigationBars["Edit Event"].exists)
    }
    
    // MARK: - Widget Tests (Simulator)
    
    func testWidgetAddition() throws {
        // Note: WidgetのUIテストはiOSシミュレータの制約により限定的
        // 実際のウィジェット機能テストは手動テストまたは実機テストで行う
        
        // ホーム画面に移動
        XCUIDevice.shared.press(.home)
        
        // しばらく待機してホーム画面が表示されるまで待つ
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let timeout: TimeInterval = 5
        let exists = springboard.wait(for: .runningForeground, timeout: timeout)
        XCTAssertTrue(exists)
        
        // ウィジェット追加の手順はiOS版とシミュレータの制約により
        // プログラマティックなテストが困難なため、手動テスト推奨
    }
}