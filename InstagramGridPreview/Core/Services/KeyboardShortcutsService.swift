import SwiftUI

/// Represents different keyboard shortcut actions available in the app
enum ShortcutAction {
    // Navigation
    case nextImage
    case previousImage
    case nextRow
    case previousRow
    
    // Grid Actions
    case addImage
    case deleteSelected
    case selectAll
    case deselectAll
    case toggleEditMode
    
    // Modal Controls
    case closeModal
    case confirmAction
    case cancelAction
    
    // Editing
    case enterEditMode
    case saveChanges
    case discardChanges
    case copySelected
    case pasteImages
    
    // Scheduling
    case schedulePost
    case saveDraft
    
    var shortcut: KeyboardShortcut {
        switch self {
        // Navigation
        case .nextImage:
            return KeyboardShortcut(.rightArrow, modifiers: [])
        case .previousImage:
            return KeyboardShortcut(.leftArrow, modifiers: [])
        case .nextRow:
            return KeyboardShortcut(.downArrow, modifiers: [])
        case .previousRow:
            return KeyboardShortcut(.upArrow, modifiers: [])
            
        // Grid Actions
        case .addImage:
            return KeyboardShortcut("n", modifiers: .command)
        case .deleteSelected:
            return KeyboardShortcut(.delete, modifiers: [])
        case .selectAll:
            return KeyboardShortcut("a", modifiers: .command)
        case .deselectAll:
            return KeyboardShortcut("d", modifiers: .command)
        case .toggleEditMode:
            return KeyboardShortcut("e", modifiers: .command)
            
        // Modal Controls
        case .closeModal:
            return KeyboardShortcut(.escape, modifiers: [])
        case .confirmAction:
            return KeyboardShortcut(.return, modifiers: [])
        case .cancelAction:
            return KeyboardShortcut(.escape, modifiers: [])
            
        // Editing
        case .enterEditMode:
            return KeyboardShortcut("e", modifiers: .command)
        case .saveChanges:
            return KeyboardShortcut("s", modifiers: .command)
        case .discardChanges:
            return KeyboardShortcut(.escape, modifiers: [])
        case .copySelected:
            return KeyboardShortcut("c", modifiers: .command)
        case .pasteImages:
            return KeyboardShortcut("v", modifiers: .command)
            
        // Scheduling
        case .schedulePost:
            return KeyboardShortcut("p", modifiers: .command)
        case .saveDraft:
            return KeyboardShortcut("s", modifiers: [.command, .shift])
        }
    }
    
    var label: String {
        switch self {
        case .nextImage: return "Next Image"
        case .previousImage: return "Previous Image"
        case .nextRow: return "Next Row"
        case .previousRow: return "Previous Row"
        case .addImage: return "Add Image"
        case .deleteSelected: return "Delete Selected"
        case .selectAll: return "Select All"
        case .deselectAll: return "Deselect All"
        case .toggleEditMode: return "Toggle Edit Mode"
        case .closeModal: return "Close"
        case .confirmAction: return "Confirm"
        case .cancelAction: return "Cancel"
        case .enterEditMode: return "Enter Edit Mode"
        case .saveChanges: return "Save Changes"
        case .discardChanges: return "Discard Changes"
        case .copySelected: return "Copy Selected"
        case .pasteImages: return "Paste Images"
        case .schedulePost: return "Schedule Post"
        case .saveDraft: return "Save Draft"
        }
    }
}

final class KeyboardShortcutsService: ObservableObject {
    static let shared = KeyboardShortcutsService()
    
    @Published private(set) var currentFocus: Int = 0
    @Published private(set) var isEditMode: Bool = false
    
    private let gridColumns = 3
    
    private init() {}
    
    // MARK: - Navigation
    
    func handleNavigation(_ action: ShortcutAction) {
        switch action {
        case .nextImage:
            if currentFocus < gridColumns * gridColumns - 1 {
                currentFocus += 1
            }
        case .previousImage:
            if currentFocus > 0 {
                currentFocus -= 1
            }
        case .nextRow:
            if currentFocus + gridColumns < gridColumns * gridColumns {
                currentFocus += gridColumns
            }
        case .previousRow:
            if currentFocus - gridColumns >= 0 {
                currentFocus -= gridColumns
            }
        default:
            break
        }
    }
    
    // MARK: - Edit Mode
    
    func toggleEditMode() {
        isEditMode.toggle()
    }
    
    // MARK: - Helper Methods
    
    func getFocusedIndex() -> Int {
        return currentFocus
    }
    
    func resetFocus() {
        currentFocus = 0
    }
    
    // MARK: - Shortcut Handling
    
    func handleShortcut(_ action: ShortcutAction) {
        switch action {
        case .nextImage, .previousImage, .nextRow, .previousRow:
            handleNavigation(action)
        case .toggleEditMode, .enterEditMode:
            toggleEditMode()
        default:
            // Other actions will be handled by respective views
            break
        }
    }
} 