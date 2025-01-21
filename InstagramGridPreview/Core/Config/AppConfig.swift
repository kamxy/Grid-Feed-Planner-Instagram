import Foundation

enum AppConfig {
    // MARK: - RevenueCat
    private static let revenueCatAPIKeys: [String: String] = [
        "debug": "appl_QmaQIiKBowlUbbGaaOuZaAXJJsW",    // Development key
        "release": "appl_QmaQIiKBowlUbbGaaOuZaAXJJsW"                 // Production key - Replace with production key
    ]
    
    static var revenueCatAPIKey: String {
        #if DEBUG
        return revenueCatAPIKeys["debug"] ?? ""
        #else
        return revenueCatAPIKeys["release"] ?? ""
        #endif
    }
    
    // Add a method to validate configuration
    static func validateConfiguration() {
        assert(!revenueCatAPIKey.isEmpty, "RevenueCat API key not configured!")
        #if !DEBUG
        assert(revenueCatAPIKey != revenueCatAPIKeys["debug"], "Using debug API key in release build!")
        #endif
    }
} 