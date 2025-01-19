import SwiftUI

struct SettingsView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingLanguageSelection = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            Form {
                Section("settings.appearance".localized) {
                    Toggle(isOn: $isDarkMode) {
                        Label {
                            Text("settings.darkMode".localized)
                        } icon: {
                            Image(systemName: isDarkMode ? "moon.fill" : "moon")
                        }
                    }
                    .onChange(of: isDarkMode) { newValue in
                        setAppearance(isDark: newValue)
                        NotificationCenter.default.post(name: NSNotification.Name("AppearanceDidChange"), object: nil)
                    }
                }
                
                Section("settings.language".localized) {
                    Button {
                        showingLanguageSelection = true
                    } label: {
                        HStack {
                            Label {
                                Text(languageManager.currentLanguage.displayName)
                            } icon: {
                                Image(systemName: "globe")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("settings.notifications".localized) {
                    NavigationLink {
                        Text("Notification Settings")
                    } label: {
                        Label {
                            Text("settings.notifications".localized)
                        } icon: {
                            Image(systemName: "bell")
                        }
                    }
                }
                
                Section {
                    Button {
                        // Send feedback
                    } label: {
                        Label {
                            Text("settings.feedback".localized)
                        } icon: {
                            Image(systemName: "envelope")
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.example.com/privacy")!) {
                        Label {
                            Text("settings.privacyPolicy".localized)
                        } icon: {
                            Image(systemName: "hand.raised")
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.example.com/terms")!) {
                        Label {
                            Text("settings.termsOfService".localized)
                        } icon: {
                            Image(systemName: "doc.text")
                        }
                    }
                }
                
                Section {
                    Button {
                        // Rate app
                    } label: {
                        Label {
                            Text("settings.rateApp".localized)
                        } icon: {
                            Image(systemName: "star")
                        }
                    }
                    
                    Button {
                        // Share app
                    } label: {
                        Label {
                            Text("settings.shareApp".localized)
                        } icon: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("settings.version".localized)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("settings.title".localized)
            .sheet(isPresented: $showingLanguageSelection) {
                LanguageSelectionView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            // Ensure the UI reflects the current dark mode setting
            setAppearance(isDark: isDarkMode)
        }
    }
    
    private func setAppearance(isDark: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }
}
