import Foundation
import SwiftUI
import UIKit

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

@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published private(set) var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
            applyLanguage(currentLanguage)
        }
    }
    
    @Published var needsRestart = false
    
    private let defaults = UserDefaults.standard
    private let languageKey = "app_language"
    
    private init() {
        if let savedLanguage = defaults.string(forKey: languageKey),
           let language = Language(rawValue: savedLanguage) {
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
        needsRestart = true
        
        // Reset the bundle to force new language to take effect
        Bundle.main.localizations
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Post notification for views to refresh
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        
        // Force UI to update
        restartApp()
    }
    
    private func applyLanguage(_ language: Language) {
        // Set app-wide language
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Update semantic content attribute for RTL support
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.semanticContentAttribute = language.isRTL ? .forceRightToLeft : .forceLeftToRight
            }
        }
    }
    
    private func restartApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // Create a new instance of the root view
        let newRootView = RootContainerView()
            .environment(\.layoutDirection, currentLanguage.isRTL ? .rightToLeft : .leftToRight)
        
        // Replace the root view controller
        window.rootViewController = UIHostingController(rootView: newRootView)
        
        // Animate the transition
        UIView.transition(with: window,
                         duration: 0.3,
                         options: .transitionCrossDissolve,
                         animations: nil,
                         completion: nil)
    }
    
    // Helper method to get localized string with current language
    func localizedString(for key: String) -> String {
        let bundle = Bundle.main
        let languagePath = bundle.path(forResource: currentLanguage.rawValue, ofType: "lproj")
        let languageBundle = languagePath.flatMap(Bundle.init)
        
        return languageBundle?.localizedString(forKey: key, value: nil, table: nil)
            ?? bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
