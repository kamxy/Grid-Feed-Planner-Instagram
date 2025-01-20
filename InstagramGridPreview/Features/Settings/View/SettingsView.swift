import SwiftUI

struct SettingsView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingLanguageSelection = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Appearance Section
                Section {
                    Toggle(isOn: $isDarkMode) {
                        Label {
                            Text("settings.darkMode".localized)
                        } icon: {
                            Image(systemName: isDarkMode ? "moon.fill" : "moon")
                        }
                    }
                } header: {
                    Text("settings.appearance".localized)
                }
                
                // Language Section
                Section {
                    Button {
                        showingLanguageSelection = true
                    } label: {
                        HStack {
                            Label {
                                Text("settings.language".localized)
                            } icon: {
                                Image(systemName: "globe")
                            }
                            Spacer()
                            Text(languageManager.currentLanguage.displayName)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("settings.language".localized)
                }
                
                // About Section
                Section {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label {
                            Text("settings.privacy".localized)
                        } icon: {
                            Image(systemName: "hand.raised")
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label {
                            Text("settings.terms".localized)
                        } icon: {
                            Image(systemName: "doc.text")
                        }
                    }
                } header: {
                    Text("settings.about".localized)
                }
                
                // Version Section
                Section {
                    HStack {
                        Text("settings.version".localized)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
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
