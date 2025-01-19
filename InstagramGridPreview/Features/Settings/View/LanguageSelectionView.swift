import SwiftUI

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
                Button(action: {
                    selectedLanguage = language
                    languageManager.setLanguage(language)
                    if languageManager.needsRestart {
                        showingRestartAlert = true
                    } else {
                        dismiss()
                    }
                }) {
                    HStack {
                        Text(language.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if language == selectedLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("settings.language".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("alert.cancel".localized) {
                        dismiss()
                    }
                }
            }
            .alert("settings.language".localized, isPresented: $showingRestartAlert) {
                Button("alert.ok".localized) {
                    // Restart app logic would go here
                    dismiss()
                }
            } message: {
                Text("settings.languageChangeRestart".localized)
            }
        }
    }
} 