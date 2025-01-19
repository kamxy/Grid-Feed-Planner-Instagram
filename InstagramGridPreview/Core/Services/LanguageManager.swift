import Foundation
import SwiftUI

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case chinese = "zh-Hans"
    case hindi = "hi"
    case arabic = "ar"
    case portuguese = "pt"
    case bengali = "bn"
    case russian = "ru"
    case japanese = "ja"
    case french = "fr"
    case german = "de"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .chinese: return "中文"
        case .hindi: return "हिन्दी"
        case .arabic: return "العربية"
        case .portuguese: return "Português"
        case .bengali: return "বাংলা"
        case .russian: return "Русский"
        case .japanese: return "日本語"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
    
    var isRTL: Bool {
        return self == .arabic
    }
}

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published private(set) var currentLanguage: Language
    @Published private(set) var needsRestart = false
    
    private let defaults = UserDefaults.standard
    private let languageKey = "app_language"
    
    private init() {
        if let savedLanguage = defaults.string(forKey: languageKey),
           let language = Language(rawValue: savedLanguage)
        {
            currentLanguage = language
        } else {
            // Use device language or fallback to English
            let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            currentLanguage = Language(rawValue: preferredLanguage) ?? .english
        }
        
        // Set initial language
        applyLanguage(currentLanguage)
    }
    
    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        
        currentLanguage = language
        defaults.set(language.rawValue, forKey: languageKey)
        defaults.synchronize()
        
        applyLanguage(language)
        needsRestart = true
        
        // Post notification for views to refresh
        NotificationCenter.default.post(name: NSNotification.Name("LanguageDidChange"), object: nil)
    }
    
    private func applyLanguage(_ language: Language) {
        // Set app-wide language
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.set(language.rawValue, forKey: "AppleLocale")
        UserDefaults.standard.synchronize()
        
        // Update semantic content attribute for RTL support
        UIView.appearance().semanticContentAttribute = language.isRTL ? .forceRightToLeft : .forceLeftToRight
        
        // Force update the bundle
        Bundle.main.forceLoadLocalizableBundle()
    }
    
    // Helper method to get localized string with current language
    func localizedString(for key: String) -> String {
        let languagePath = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj")
        if let path = languagePath,
           let bundle = Bundle(path: path)
        {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        return NSLocalizedString(key, comment: "")
    }
}

// Helper extension to force bundle reload
private extension Bundle {
    func forceLoadLocalizableBundle() {
        guard let languagePath = Bundle.main.path(forResource: LanguageManager.shared.currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: languagePath) else { return }
        
        if let stringsPath = bundle.path(forResource: "Localizable", ofType: "strings") {
            let languageCode = URL(fileURLWithPath: stringsPath)
                .deletingLastPathComponent()
                .lastPathComponent
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
}
