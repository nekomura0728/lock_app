import Foundation

struct L10n {
    // MARK: - Event List
    static let events = NSLocalizedString("Events", comment: "")
    static let settings = NSLocalizedString("Settings", comment: "")
    static let addEvent = NSLocalizedString("Add Event", comment: "")
    static let loading = NSLocalizedString("Loading...", comment: "")
    static let noEventsYet = NSLocalizedString("No events yet", comment: "")
    static let createFirstEvent = NSLocalizedString("Create your first event", comment: "")
    static let howToAddWidgets = NSLocalizedString("How to add widgets", comment: "")
    static let addWidgetToHomeScreen = NSLocalizedString("Add your widget to home screen to see countdown", comment: "")
    
    // MARK: - Event Edit
    static let newEvent = NSLocalizedString("New Event", comment: "")
    static let editEvent = NSLocalizedString("Edit Event", comment: "")
    static let eventTitle = NSLocalizedString("Event Title", comment: "")
    static let enterTitle = NSLocalizedString("Enter title...", comment: "")
    static let dateTime = NSLocalizedString("Date & Time", comment: "")
    static let allDay = NSLocalizedString("All Day", comment: "")
    static let color = NSLocalizedString("Color", comment: "")
    static let emoji = NSLocalizedString("Emoji", comment: "")
    static let save = NSLocalizedString("Save", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    static let delete = NSLocalizedString("Delete", comment: "")
    
    // MARK: - Countdown
    static func remainingDays(_ count: Int) -> String {
        return String(format: NSLocalizedString("remaining %d days", comment: ""), count)
    }
    static func remainingHours(_ count: Int) -> String {
        return String(format: NSLocalizedString("remaining %d hours", comment: ""), count)
    }
    static func remainingMinutes(_ count: Int) -> String {
        return String(format: NSLocalizedString("remaining %d minutes", comment: ""), count)
    }
    static func remainingSeconds(_ count: Int) -> String {
        return String(format: NSLocalizedString("remaining %d seconds", comment: ""), count)
    }
    static let completed = NSLocalizedString("completed", comment: "")
    static func elapsedDays(_ count: Int) -> String {
        return String(format: NSLocalizedString("elapsed %d days", comment: ""), count)
    }
    static func elapsedHours(_ count: Int) -> String {
        return String(format: NSLocalizedString("elapsed %d hours", comment: ""), count)
    }
    
    // MARK: - Settings
    static let general = NSLocalizedString("General", comment: "")
    static let notifications = NSLocalizedString("Notifications", comment: "")
    static let eventManagement = NSLocalizedString("Event Management", comment: "")
    static let postDueDisplay = NSLocalizedString("Post Due Display", comment: "")
    static let autoSelection = NSLocalizedString("Auto Selection", comment: "")
    static let help = NSLocalizedString("Help", comment: "")
    static let widgetGuide = NSLocalizedString("Widget Guide", comment: "")
    static let termsOfService = NSLocalizedString("Terms of Service", comment: "")
    static let privacyPolicy = NSLocalizedString("Privacy Policy", comment: "")
    static let version = NSLocalizedString("Version", comment: "")
    static let done = NSLocalizedString("Done", comment: "")
    
    // MARK: - Pro/Paywall
    static let pro = NSLocalizedString("Pro", comment: "")
    static let freeVersion = NSLocalizedString("Free Version", comment: "")
    static let upToOneEvent = NSLocalizedString("Up to 1 event", comment: "")
    static let allFeaturesAvailable = NSLocalizedString("All features available", comment: "")
    static let upgradeToPro = NSLocalizedString("Upgrade to Pro", comment: "")
    static let restorePurchase = NSLocalizedString("Restore Purchase", comment: "")
    static let multipleEvents = NSLocalizedString("Multiple Events", comment: "")
    static let createMultipleEvents = NSLocalizedString("Create 2 or more events", comment: "")
    static let widgetDualDisplay = NSLocalizedString("Widget Dual Display", comment: "")
    static let showMultipleEvents = NSLocalizedString("Show multiple events on home screen", comment: "")
    static let oneTimePurchase = NSLocalizedString("One-time Purchase", comment: "")
    static let useForever = NSLocalizedString("Use forever with single purchase", comment: "")
    static func purchaseProFor(_ price: String) -> String {
        return String(format: NSLocalizedString("Purchase Pro for %@", comment: ""), price)
    }
    static let purchasePro = NSLocalizedString("Purchase Pro", comment: "")
    static let oneTimePurchaseForever = NSLocalizedString("One-time purchase (forever)", comment: "")
    static let payOnceUseForever = NSLocalizedString("Pay once, use forever. Charged to your iTunes account.", comment: "")
    
    // MARK: - Notifications
    static let notificationSettings = NSLocalizedString("Notification Settings", comment: "")
    static let allowNotifications = NSLocalizedString("Allow notifications to receive event reminders.", comment: "")
    static let notificationStatus = NSLocalizedString("Notification Status", comment: "")
    static let notificationsEnabled = NSLocalizedString("Notifications enabled", comment: "")
    static let notificationsDenied = NSLocalizedString("Notifications denied", comment: "")
    static let authorizationRequired = NSLocalizedString("Authorization required", comment: "")
    static let allow = NSLocalizedString("Allow", comment: "")
    static let notificationTiming = NSLocalizedString("Notification Timing", comment: "")
    static let optimalNotifications = NSLocalizedString("We send optimal notifications based on event type.", comment: "")
    static let oneDayBefore = NSLocalizedString("1 day before", comment: "")
    static let oneHourBefore = NSLocalizedString("1 hour before", comment: "")
    static let morningNotification = NSLocalizedString("Morning notification", comment: "")
    static let timeSpecificOnly = NSLocalizedString("Time-specific events only", comment: "")
    static let allDayOnly = NSLocalizedString("All-day events only", comment: "")
    static let testNotification = NSLocalizedString("Test Notification", comment: "")
    static let testNotificationDescription = NSLocalizedString("Sends test notification in 5 seconds.", comment: "")
    
    // MARK: - Widget Guide
    static let howToAddWidgetsTitle = NSLocalizedString("How to Add Widgets", comment: "")
    static let longPressHomeScreen = NSLocalizedString("Long press home screen", comment: "")
    static let longPressDescription = NSLocalizedString("Long press until app icons start wiggling.", comment: "")
    static let tapPlusButton = NSLocalizedString("Tap '+' button", comment: "")
    static let tapPlusDescription = NSLocalizedString("Tap the '+' button in top-left corner.", comment: "")
    static let searchCDWidget = NSLocalizedString("Search for 'CDWidget'", comment: "")
    static let searchDescription = NSLocalizedString("Select 'CDWidget' from widget list.", comment: "")
    static let chooseSize = NSLocalizedString("Choose size", comment: "")
    static let chooseSizeDescription = NSLocalizedString("Select your preferred size: Small, Medium, or Large.", comment: "")
    static let addWidget = NSLocalizedString("Add Widget", comment: "")
    static let addWidgetDescription = NSLocalizedString("Tap 'Add Widget' to complete.", comment: "")
    
    // MARK: - Errors
    static let error = NSLocalizedString("Error", comment: "")
    static let ok = NSLocalizedString("OK", comment: "")
    static let freeVersionLimit = NSLocalizedString("Free version allows up to 1 event. Please upgrade to Pro.", comment: "")
    static let eventNotFound = NSLocalizedString("Event not found", comment: "")
    static let duplicateEventFailed = NSLocalizedString("Failed to duplicate event", comment: "")
    static let productNotFound = NSLocalizedString("Product not found", comment: "")
    static func purchaseFailed(_ error: String) -> String {
        return String(format: NSLocalizedString("Purchase failed: %@", comment: ""), error)
    }
    static func restoreFailed(_ error: String) -> String {
        return String(format: NSLocalizedString("Restore failed: %@", comment: ""), error)
    }
    
    // MARK: - Widget
    static let noEvents = NSLocalizedString("No events", comment: "")
    static let pleaseCreateEvent = NSLocalizedString("Please create an event", comment: "")
    
    // MARK: - Notification Content
    static let tomorrowEvent = NSLocalizedString("Tomorrow is your event!", comment: "")
    static func eventTomorrow(_ emoji: String, _ title: String) -> String {
        return String(format: NSLocalizedString("%@ %@ is tomorrow", comment: ""), emoji, title)
    }
    static let eventStartingSoon = NSLocalizedString("Event starting soon!", comment: "")
    static func eventStartsInHour(_ emoji: String, _ title: String) -> String {
        return String(format: NSLocalizedString("%@ %@ starts in 1 hour", comment: ""), emoji, title)
    }
    static let todayEvent = NSLocalizedString("Today is your event!", comment: "")
    static func todayIs(_ emoji: String, _ title: String) -> String {
        return String(format: NSLocalizedString("Today is %@ %@", comment: ""), emoji, title)
    }
    static let testNotificationTitle = NSLocalizedString("CDWidget Test Notification", comment: "")
    static let testNotificationBody = NSLocalizedString("Notifications are working properly!", comment: "")
}
