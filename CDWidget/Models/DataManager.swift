import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let appGroupID = "group.com.lizaria.countdown.CDWidget"
    private let eventsFileName = "events.json"
    private let settingsFileName = "settings.json"
    private let lockFileName = ".lock"
    
    private var containerURL: URL? {
        // App Groups設定がない場合はDocument Directoryを使用
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return appGroupURL
        } else {
            // フォールバック：Document Directory
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        }
    }
    
    private var eventsURL: URL? {
        containerURL?.appendingPathComponent(eventsFileName)
    }
    
    private var settingsURL: URL? {
        containerURL?.appendingPathComponent(settingsFileName)
    }
    
    private var lockURL: URL? {
        containerURL?.appendingPathComponent(lockFileName)
    }
    
    private init() {}
    
    // MARK: - File Locking
    
    private func withFileLock<T>(_ operation: () throws -> T) throws -> T {
        guard let lockURL = lockURL else {
            throw DataManagerError.appGroupNotConfigured
        }
        
        let lockData = Data()
        
        // Create lock file
        try lockData.write(to: lockURL)
        defer {
            try? FileManager.default.removeItem(at: lockURL)
        }
        
        return try operation()
    }
    
    // App Groups設定時のヘルパーメソッド
    private func withOptionalFileLock<T>(_ operation: () throws -> T) throws -> T {
        if let lockURL = lockURL {
            let lockData = Data()
            
            // Create lock file
            try lockData.write(to: lockURL)
            defer {
                try? FileManager.default.removeItem(at: lockURL)
            }
        }
        
        return try operation()
    }
    
    // MARK: - Events Management
    
    func loadEvents() throws -> [Event] {
        return try withOptionalFileLock {
            guard let eventsURL = eventsURL else {
                return [] // App Groups設定がない場合は空配列を返す
            }
            
            guard FileManager.default.fileExists(atPath: eventsURL.path) else {
                return []
            }
            
            let data = try Data(contentsOf: eventsURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let events = try decoder.decode([Event].self, from: data)
            return events
        }
    }
    
    func saveEvents(_ events: [Event]) throws {
        try withOptionalFileLock {
            guard let eventsURL = eventsURL else {
                return // App Groups設定がない場合は何もしない
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(events)
            try data.write(to: eventsURL)
        }
    }
    
    // MARK: - Settings Management
    
    func loadSettings() throws -> AppSettings {
        return try withOptionalFileLock {
            guard let settingsURL = settingsURL else {
                return AppSettings() // App Groups設定がない場合はデフォルト設定を返す
            }
            
            guard FileManager.default.fileExists(atPath: settingsURL.path) else {
                return AppSettings()
            }
            
            let data = try Data(contentsOf: settingsURL)
            let settings = try JSONDecoder().decode(AppSettings.self, from: data)
            return settings
        }
    }
    
    func saveSettings(_ settings: AppSettings) throws {
        try withOptionalFileLock {
            guard let settingsURL = settingsURL else {
                return // App Groups設定がない場合は何もしない
            }
            
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsURL)
        }
    }
}

enum DataManagerError: Error, LocalizedError {
    case appGroupNotConfigured
    case fileAccessError
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .appGroupNotConfigured:
            return "App Group が設定されていません"
        case .fileAccessError:
            return "ファイルへのアクセスに失敗しました"
        case .encodingError:
            return "データのエンコードに失敗しました"
        case .decodingError:
            return "データのデコードに失敗しました"
        }
    }
}