import Foundation

struct AppSettings: Codable {
    var isPro: Bool
    var widgetAutoSelectPolicy: WidgetSelectPolicy
    var postDueDisplay: PostDueDisplayPolicy
    
    init(
        isPro: Bool = false,
        widgetAutoSelectPolicy: WidgetSelectPolicy = .nearestUpcoming,
        postDueDisplay: PostDueDisplayPolicy = .completed
    ) {
        self.isPro = isPro
        self.widgetAutoSelectPolicy = widgetAutoSelectPolicy
        self.postDueDisplay = postDueDisplay
    }
}

enum WidgetSelectPolicy: String, Codable, CaseIterable {
    case nearestUpcoming = "nearestUpcoming"
    case fixedByWidget = "fixedByWidget"
    
    var localizedTitle: String {
        switch self {
        case .nearestUpcoming:
            return "最近接未完了"
        case .fixedByWidget:
            return "固定選択"
        }
    }
}

enum PostDueDisplayPolicy: String, Codable, CaseIterable {
    case elapsed = "elapsed"
    case completed = "completed"
    
    var localizedTitle: String {
        switch self {
        case .elapsed:
            return "経過時間表示"
        case .completed:
            return "完了表示"
        }
    }
}