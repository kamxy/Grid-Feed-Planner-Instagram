import SwiftUI

struct KeyboardShortcutsModifier: ViewModifier {
    @StateObject private var shortcutsService = KeyboardShortcutsService.shared
    var onAction: (ShortcutAction) -> Void
    
    func body(content: Content) -> some View {
        content
            // Navigation
            .keyboardShortcut(.rightArrow, modifiers: [], action: { onAction(.nextImage) })
            .keyboardShortcut(.leftArrow, modifiers: [], action: { onAction(.previousImage) })
            .keyboardShortcut(.downArrow, modifiers: [], action: { onAction(.nextRow) })
            .keyboardShortcut(.upArrow, modifiers: [], action: { onAction(.previousRow) })
            
            // Grid Actions
            .keyboardShortcut("n", modifiers: .command, action: { onAction(.addImage) })
            .keyboardShortcut(.delete, modifiers: [], action: { onAction(.deleteSelected) })
            .keyboardShortcut("a", modifiers: .command, action: { onAction(.selectAll) })
            .keyboardShortcut("d", modifiers: .command, action: { onAction(.deselectAll) })
            .keyboardShortcut("e", modifiers: .command, action: { onAction(.toggleEditMode) })
            
            // Modal Controls
            .keyboardShortcut(.escape, modifiers: [], action: { onAction(.closeModal) })
            .keyboardShortcut(.return, modifiers: [], action: { onAction(.confirmAction) })
            
            // Editing
            .keyboardShortcut("s", modifiers: .command, action: { onAction(.saveChanges) })
            .keyboardShortcut("c", modifiers: .command, action: { onAction(.copySelected) })
            .keyboardShortcut("v", modifiers: .command, action: { onAction(.pasteImages) })
            
            // Scheduling
            .keyboardShortcut("p", modifiers: .command, action: { onAction(.schedulePost) })
            .keyboardShortcut("s", modifiers: [.command, .shift], action: { onAction(.saveDraft) })
    }
}

extension View {
    func withKeyboardShortcuts(onAction: @escaping (ShortcutAction) -> Void) -> some View {
        modifier(KeyboardShortcutsModifier(onAction: onAction))
    }
}

// Helper view to show keyboard shortcuts in menus
struct KeyboardShortcutLabel: View {
    let action: ShortcutAction
    
    var body: some View {
        HStack {
            Text(action.label)
            Spacer()
            KeyboardShortcutView(shortcut: action.shortcut)
        }
    }
}

struct KeyboardShortcutView: View {
    let shortcut: KeyboardShortcut
    
    var body: some View {
        HStack(spacing: 2) {
            if shortcut.modifiers.contains(.command) {
                Text("⌘")
            }
            if shortcut.modifiers.contains(.shift) {
                Text("⇧")
            }
            if shortcut.modifiers.contains(.option) {
                Text("⌥")
            }
            if shortcut.modifiers.contains(.control) {
                Text("⌃")
            }
            
            switch shortcut.key {
            case .rightArrow:
                Text("→")
            case .leftArrow:
                Text("←")
            case .upArrow:
                Text("↑")
            case .downArrow:
                Text("↓")
            case .escape:
                Text("⎋")
            case .return:
                Text("↩")
            case .delete:
                Text("⌫")
            default:
                if let character = shortcut.key.character {
                    Text(character.uppercased())
                }
            }
        }
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundColor(.secondary)
    }
} 