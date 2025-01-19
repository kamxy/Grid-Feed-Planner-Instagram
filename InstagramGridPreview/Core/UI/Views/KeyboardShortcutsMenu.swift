import SwiftUI

struct KeyboardShortcutsMenu: View {
    var body: some View {
        Menu("Keyboard Shortcuts") {
            Group {
                Section("Navigation") {
                    KeyboardShortcutLabel(action: .nextImage)
                    KeyboardShortcutLabel(action: .previousImage)
                    KeyboardShortcutLabel(action: .nextRow)
                    KeyboardShortcutLabel(action: .previousRow)
                }
                
                Section("Grid Actions") {
                    KeyboardShortcutLabel(action: .addImage)
                    KeyboardShortcutLabel(action: .deleteSelected)
                    KeyboardShortcutLabel(action: .selectAll)
                    KeyboardShortcutLabel(action: .deselectAll)
                    KeyboardShortcutLabel(action: .toggleEditMode)
                }
            }
            
            Group {
                Section("Editing") {
                    KeyboardShortcutLabel(action: .saveChanges)
                    KeyboardShortcutLabel(action: .discardChanges)
                    KeyboardShortcutLabel(action: .copySelected)
                    KeyboardShortcutLabel(action: .pasteImages)
                }
                
                Section("Scheduling") {
                    KeyboardShortcutLabel(action: .schedulePost)
                    KeyboardShortcutLabel(action: .saveDraft)
                }
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .buttonStyle(.plain)
        .padding(.horizontal)
        .help("View keyboard shortcuts")
    }
}

#Preview {
    KeyboardShortcutsMenu()
} 