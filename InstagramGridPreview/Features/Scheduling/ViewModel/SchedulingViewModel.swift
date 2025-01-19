import SwiftUI

@MainActor
final class SchedulingViewModel: ObservableObject {
    @Published var scheduledPosts: [ScheduledPost] = []
    @Published var drafts: [ScheduledPost] = []
    @Published var selectedDate: Date = Date()
    @Published var caption: String = ""
    @Published var hashtags: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let schedulingService = PostSchedulingService.shared
    
    init() {
        loadPosts()
        
        // Observe scheduling service changes
        schedulingService.$scheduledPosts
            .assign(to: &$scheduledPosts)
        
        schedulingService.$drafts
            .assign(to: &$drafts)
    }
    
    func schedulePost(images: [UIImage]) async {
        isLoading = true
        do {
            _ = try await schedulingService.schedulePost(
                images: images,
                caption: caption,
                hashtags: hashtags,
                date: selectedDate
            )
            resetForm()
        } catch SchedulingError.invalidDate {
            showError(message: "Please select a future date")
        } catch SchedulingError.notificationsDenied {
            showError(message: "Please enable notifications to schedule posts")
        } catch {
            showError(message: "Failed to schedule post: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func saveDraft(images: [UIImage]) async {
        isLoading = true
        do {
            _ = try await schedulingService.saveDraft(
                images: images,
                caption: caption,
                hashtags: hashtags
            )
            resetForm()
        } catch {
            showError(message: "Failed to save draft: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func deletePost(_ post: ScheduledPost) async {
        isLoading = true
        do {
            try await schedulingService.deletePost(post)
        } catch {
            showError(message: "Failed to delete post: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func convertDraftToScheduled(_ draft: ScheduledPost) async {
        isLoading = true
        do {
            try await schedulingService.convertDraftToScheduledPost(draft, scheduledDate: selectedDate)
        } catch SchedulingError.invalidDate {
            showError(message: "Please select a future date")
        } catch {
            showError(message: "Failed to schedule draft: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func addHashtag(_ hashtag: String) {
        guard !hashtag.isEmpty else { return }
        hashtags.append(hashtag)
    }
    
    func removeHashtag(_ hashtag: String) {
        hashtags.removeAll { $0 == hashtag }
    }
    
    private func loadPosts() {
        // Posts are automatically loaded through Combine publishers
    }
    
    private func resetForm() {
        caption = ""
        hashtags = []
        selectedDate = Date()
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
} 