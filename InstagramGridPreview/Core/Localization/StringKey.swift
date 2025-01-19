import Foundation

enum StringKey {
    // MARK: - Navigation

    case gridTitle
    case calendarTitle
    case settingsTitle

    // MARK: - Grid

    case addPhotos
    case editGrid
    case deleteSelected
    case selectAll
    case deselectAll
    case noPhotosMessage
    case noPhotosDescription

    // MARK: - Image Editor

    case editPhoto
    case applyFilter
    case adjustments
    case brightness
    case contrast
    case saturation
    case saveChanges
    case discardChanges

    // MARK: - Scheduling

    case schedulePost
    case saveDraft
    case addCaption
    case addHashtags
    case selectDate
    case notifications
    case scheduledFor
    case draft
    case postDetails
    case schedulingOptions
    case notificationReminder
    case postPreview

    // MARK: - Export

    case exportGrid
    case saveToPhotos
    case copyToClipboard
    case shareToInstagram
    case exportOptions
    case exportSuccess
    case exportFailed
    case exportInProgress
    case exportQuality
    case exportFormat

    // MARK: - Alerts

    case error
    case success
    case warning
    case confirm
    case cancel
    case delete
    case save
    case deleteConfirmation
    case unsavedChanges
    case networkError
    case tryAgain

    // MARK: - Settings

    case appearance
    case language
    case feedback
    case about
    case version
    case darkMode
    case lightMode
    case systemMode
    case privacyPolicy
    case termsOfService
    case rateApp
    case shareApp
    case logout

    var localized: String {
        switch self {
        // Navigation
        case .gridTitle:
            return NSLocalizedString("grid.title", comment: "Title for the grid view")
        case .calendarTitle:
            return NSLocalizedString("calendar.title", comment: "Title for the calendar view")
        case .settingsTitle:
            return NSLocalizedString("settings.title", comment: "Title for the settings view")
        // Grid
        case .addPhotos:
            return NSLocalizedString("grid.addPhotos", comment: "Button to add photos to grid")
        case .editGrid:
            return NSLocalizedString("grid.edit", comment: "Button to enter grid edit mode")
        case .deleteSelected:
            return NSLocalizedString("grid.deleteSelected", comment: "Button to delete selected photos")
        case .selectAll:
            return NSLocalizedString("grid.selectAll", comment: "Button to select all photos")
        case .deselectAll:
            return NSLocalizedString("grid.deselectAll", comment: "Button to deselect all photos")
        case .noPhotosMessage:
            return NSLocalizedString("grid.noPhotos.message", comment: "Message shown when grid is empty")
        case .noPhotosDescription:
            return NSLocalizedString("grid.noPhotos.description", comment: "Description shown when grid is empty")
        // Image Editor
        case .editPhoto:
            return NSLocalizedString("editor.title", comment: "Title for photo editor")
        case .applyFilter:
            return NSLocalizedString("editor.applyFilter", comment: "Button to apply filter")
        case .adjustments:
            return NSLocalizedString("editor.adjustments", comment: "Title for adjustments section")
        case .brightness:
            return NSLocalizedString("editor.brightness", comment: "Brightness adjustment label")
        case .contrast:
            return NSLocalizedString("editor.contrast", comment: "Contrast adjustment label")
        case .saturation:
            return NSLocalizedString("editor.saturation", comment: "Saturation adjustment label")
        case .saveChanges:
            return NSLocalizedString("editor.saveChanges", comment: "Button to save changes")
        case .discardChanges:
            return NSLocalizedString("editor.discardChanges", comment: "Button to discard changes")
        // Scheduling
        case .schedulePost:
            return NSLocalizedString("schedule.post", comment: "Button to schedule post")
        case .saveDraft:
            return NSLocalizedString("schedule.saveDraft", comment: "Button to save as draft")
        case .addCaption:
            return NSLocalizedString("schedule.addCaption", comment: "Placeholder for caption input")
        case .addHashtags:
            return NSLocalizedString("schedule.addHashtags", comment: "Button to add hashtags")
        case .selectDate:
            return NSLocalizedString("schedule.selectDate", comment: "Button to select date")
        case .notifications:
            return NSLocalizedString("schedule.notifications", comment: "Notifications settings")
        case .scheduledFor:
            return NSLocalizedString("schedule.scheduledFor", comment: "Label showing scheduled date")
        case .draft:
            return NSLocalizedString("schedule.draft", comment: "Draft label")
        case .postDetails:
            return NSLocalizedString("schedule.postDetails", comment: "Post details section")
        case .schedulingOptions:
            return NSLocalizedString("schedule.options", comment: "Scheduling options")
        case .notificationReminder:
            return NSLocalizedString("schedule.reminder", comment: "Notification reminder")
        case .postPreview:
            return NSLocalizedString("schedule.preview", comment: "Post preview")
        // Export
        case .exportGrid:
            return NSLocalizedString("export.grid", comment: "Button to export grid")
        case .saveToPhotos:
            return NSLocalizedString("export.saveToPhotos", comment: "Button to save to photos")
        case .copyToClipboard:
            return NSLocalizedString("export.copyToClipboard", comment: "Button to copy to clipboard")
        case .shareToInstagram:
            return NSLocalizedString("export.shareToInstagram", comment: "Button to share to Instagram")
        case .exportOptions:
            return NSLocalizedString("export.options", comment: "Export options")
        case .exportSuccess:
            return NSLocalizedString("export.success", comment: "Export success message")
        case .exportFailed:
            return NSLocalizedString("export.failed", comment: "Export failed message")
        case .exportInProgress:
            return NSLocalizedString("export.inProgress", comment: "Export in progress message")
        case .exportQuality:
            return NSLocalizedString("export.quality", comment: "Export quality setting")
        case .exportFormat:
            return NSLocalizedString("export.format", comment: "Export format setting")
        // Alerts
        case .error:
            return NSLocalizedString("alert.error", comment: "Error alert title")
        case .success:
            return NSLocalizedString("alert.success", comment: "Success alert title")
        case .warning:
            return NSLocalizedString("alert.warning", comment: "Warning alert title")
        case .confirm:
            return NSLocalizedString("alert.confirm", comment: "Confirm button")
        case .cancel:
            return NSLocalizedString("alert.cancel", comment: "Cancel button")
        case .delete:
            return NSLocalizedString("alert.delete", comment: "Delete button")
        case .save:
            return NSLocalizedString("alert.save", comment: "Save button")
        case .deleteConfirmation:
            return NSLocalizedString("alert.deleteConfirmation", comment: "Delete confirmation message")
        case .unsavedChanges:
            return NSLocalizedString("alert.unsavedChanges", comment: "Unsaved changes message")
        case .networkError:
            return NSLocalizedString("alert.networkError", comment: "Network error message")
        case .tryAgain:
            return NSLocalizedString("alert.tryAgain", comment: "Try again button")
        // Settings
        case .appearance:
            return NSLocalizedString("settings.appearance", comment: "Appearance settings")
        case .language:
            return NSLocalizedString("settings.language", comment: "Language settings")
        case .feedback:
            return NSLocalizedString("settings.feedback", comment: "Send feedback button")
        case .about:
            return NSLocalizedString("settings.about", comment: "About section")
        case .version:
            return NSLocalizedString("settings.version", comment: "App version")
        case .darkMode:
            return NSLocalizedString("settings.darkMode", comment: "Dark mode option")
        case .lightMode:
            return NSLocalizedString("settings.lightMode", comment: "Light mode option")
        case .systemMode:
            return NSLocalizedString("settings.systemMode", comment: "System mode option")
        case .privacyPolicy:
            return NSLocalizedString("settings.privacyPolicy", comment: "Privacy policy link")
        case .termsOfService:
            return NSLocalizedString("settings.termsOfService", comment: "Terms of service link")
        case .rateApp:
            return NSLocalizedString("settings.rateApp", comment: "Rate app button")
        case .shareApp:
            return NSLocalizedString("settings.shareApp", comment: "Share app button")
        case .logout:
            return NSLocalizedString("settings.logout", comment: "Logout button")
        }
    }
}
