import Foundation

// MARK: - Import for Localization
// LocalizedString.swiftで定義されたL10n構造体を使用

struct CountdownFormatter {
    static let shared = CountdownFormatter()
    
    private init() {}
    
    func formatCountdown(from now: Date, to targetDate: Date, isAllDay: Bool, postDueDisplay: PostDueDisplayPolicy) -> (main: String, sub: String?) {
        let timeInterval = targetDate.timeIntervalSince(now)
        let isPastDue = timeInterval < 0
        let absoluteInterval = abs(timeInterval)
        
        if isPastDue {
            return formatPastDue(interval: absoluteInterval, policy: postDueDisplay)
        } else {
            return formatUpcoming(interval: absoluteInterval, targetDate: targetDate, isAllDay: isAllDay)
        }
    }
    
    private func formatUpcoming(interval: TimeInterval, targetDate: Date, isAllDay: Bool) -> (main: String, sub: String?) {
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(interval.truncatingRemainder(dividingBy: 60))
        
        if days > 30 {
            return (String(format: NSLocalizedString("remaining %d days", comment: ""), days), nil)
        } else if days >= 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            let dateString = formatter.string(from: targetDate)
            return (String(format: NSLocalizedString("remaining %d days", comment: ""), days), dateString)
        } else if hours >= 1 {
            // 1時間以上24時間未満
            return (String(format: NSLocalizedString("remaining %d hours", comment: ""), hours), nil)
        } else {
            // 1時間未満は分表示
            return (String(format: NSLocalizedString("remaining %d minutes", comment: ""), minutes), nil)
        }
    }
    
    private func formatPastDue(interval: TimeInterval, policy: PostDueDisplayPolicy) -> (main: String, sub: String?) {
        switch policy {
        case .completed:
            return (NSLocalizedString("completed", comment: ""), nil)
        case .elapsed:
            let days = Int(interval / 86400)
            let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
            
            if days >= 1 {
                return (String(format: NSLocalizedString("elapsed %d days", comment: ""), days), nil)
            } else {
                return (String(format: NSLocalizedString("elapsed %d hours", comment: ""), hours), nil)
            }
        }
    }
    
    func formatForWidget(from now: Date, to targetDate: Date, title: String, maxLength: Int = 20) -> String {
        let timeInterval = targetDate.timeIntervalSince(now)
        let isPastDue = timeInterval < 0
        let absoluteInterval = abs(timeInterval)
        
        let days = Int(absoluteInterval / 86400)
        let hours = Int((absoluteInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((absoluteInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        let countdownText: String
        if isPastDue {
            countdownText = NSLocalizedString("completed", comment: "")
        } else if days > 0 {
            countdownText = "\(days)日"
        } else if hours > 0 {
            countdownText = "\(hours)時間"
        } else {
            countdownText = "\(minutes)分"
        }
        
        let truncatedTitle = String(title.prefix(maxLength - countdownText.count - 1))
        return "\(truncatedTitle) \(countdownText)"
    }
    
    func formatForInlineWidget(from now: Date, to targetDate: Date, title: String, emoji: String?) -> String {
        let timeInterval = targetDate.timeIntervalSince(now)
        let isPastDue = timeInterval < 0
        let absoluteInterval = abs(timeInterval)
        
        let days = Int(absoluteInterval / 86400)
        let hours = Int((absoluteInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((absoluteInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        let countdownText: String
        if isPastDue {
            countdownText = NSLocalizedString("completed", comment: "")
        } else if days > 0 {
            countdownText = "\(days)日"
        } else if hours > 0 {
            countdownText = "\(hours)h"
        } else {
            countdownText = "\(minutes)m"
        }
        
        let displayEmoji = emoji ?? "⏳"
        let truncatedTitle = String(title.prefix(10))
        
        return "\(displayEmoji) \(truncatedTitle) \(countdownText)"
    }
}