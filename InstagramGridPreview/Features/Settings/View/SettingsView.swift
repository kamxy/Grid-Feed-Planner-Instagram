import SwiftUI

struct SettingsView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingLanguageSelection = false
    
    private let appReviewService = AppReviewService.shared
    
    var body: some View {
        NavigationStack {
            Form {
                // Appearance Section
                Section("settings.appearance".localized) {
                    Toggle("settings.darkMode".localized, isOn: $isDarkMode)
                }
                
                // Language Section
                Section("settings.language".localized) {
                    Button {
                        showingLanguageSelection = true
                    } label: {
                        HStack {
                            Text(languageManager.currentLanguage.displayName)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Support Section
                Section("settings.support".localized) {
                    Button {
                        appReviewService.requestReview()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.appPink)
                            Text("settings.rateApp".localized)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.example.com/privacy")!) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.appPink)
                            Text("settings.privacyPolicy".localized)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.example.com/terms")!) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.appPink)
                            Text("settings.termsOfService".localized)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // About Section
                Section {
                    HStack {
                        Text("settings.version".localized)
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("settings.title".localized)
            .sheet(isPresented: $showingLanguageSelection) {
                LanguageSelectionView()
            }
        }
    }
}

private extension Bundle {
    var appVersion: String {
        return "\(infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")"
    }
}

struct LanguageSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguage: Language
    @State private var showingRestartAlert = false
    
    init() {
        _selectedLanguage = State(initialValue: LanguageManager.shared.currentLanguage)
    }
    
    var body: some View {
        NavigationStack {
            List(Language.allCases) { language in
                Button {
                    selectedLanguage = language
                    languageManager.setLanguage(language)
                    showingRestartAlert = true
                } label: {
                    HStack {
                        Text(language.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if language == selectedLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.pink)
                        }
                    }
                }
            }
            .navigationTitle("settings.selectLanguage".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("alert.done".localized) {
                        if languageManager.needsRestart {
                            showingRestartAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .alert("settings.languageChanged".localized, isPresented: $showingRestartAlert) {
                Button("alert.ok".localized, role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("settings.languageChangeEffect".localized)
            }
        }
    }
}
