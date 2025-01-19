import Foundation
import SwiftUI
import UserNotifications

struct ScheduledPost: Codable, Identifiable {
    let id: UUID
    var imageIds: [String]
    var caption: String
    var hashtags: [String]
    var scheduledDate: Date
    var notificationId: String
    var isDraft: Bool
    var lastModified: Date
    var status: PostStatus
    
    enum PostStatus: String, Codable {
        case draft
        case scheduled
        case posted
        case failed
    }
}

enum SchedulingError: Error {
    case notificationsDenied
    case invalidDate
    case postNotFound
    case schedulingFailed
}

final class PostSchedulingService: ObservableObject {
    static let shared = PostSchedulingService()
    
    @Published private(set) var scheduledPosts: [ScheduledPost] = []
    @Published private(set) var drafts: [ScheduledPost] = []
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    
    private init() {
        loadPosts()
        requestNotificationPermissions()
    }
    
    // MARK: - Post Management
    
    func schedulePost(images: [UIImage], caption: String, hashtags: [String], date: Date) async throws -> ScheduledPost {
        // Validate date
        guard date > Date() else {
            throw SchedulingError.invalidDate
        }
        
        // Save images
        let imageIds = try await saveImages(images)
        
        // Create notification
        let notificationId = UUID().uuidString
        try await scheduleNotification(for: date, notificationId: notificationId)
        
        // Create post
        let post = ScheduledPost(
            id: UUID(),
            imageIds: imageIds,
            caption: caption,
            hashtags: hashtags,
            scheduledDate: date,
            notificationId: notificationId,
            isDraft: false,
            lastModified: Date(),
            status: .scheduled
        )
        
        // Save post
        await MainActor.run {
            scheduledPosts.append(post)
            savePosts()
        }
        
        return post
    }
    
    func saveDraft(images: [UIImage], caption: String, hashtags: [String]) async throws -> ScheduledPost {
        let imageIds = try await saveImages(images)
        
        let draft = ScheduledPost(
            id: UUID(),
            imageIds: imageIds,
            caption: caption,
            hashtags: hashtags,
            scheduledDate: Date(),
            notificationId: "",
            isDraft: true,
            lastModified: Date(),
            status: .draft
        )
        
        await MainActor.run {
            drafts.append(draft)
            savePosts()
        }
        
        return draft
    }
    
    func updatePost(_ post: ScheduledPost) async throws {
        await MainActor.run {
            if post.isDraft {
                if let index = drafts.firstIndex(where: { $0.id == post.id }) {
                    drafts[index] = post
                }
            } else {
                if let index = scheduledPosts.firstIndex(where: { $0.id == post.id }) {
                    scheduledPosts[index] = post
                }
            }
            savePosts()
        }
    }
    
    func deletePost(_ post: ScheduledPost) async throws {
        // Cancel notification if scheduled
        if !post.notificationId.isEmpty {
            await notificationCenter.removePendingNotificationRequests(withIdentifiers: [post.notificationId])
        }
        
        // Delete images
        try await deleteImages(post.imageIds)
        
        // Remove post
        await MainActor.run {
            if post.isDraft {
                drafts.removeAll { $0.id == post.id }
            } else {
                scheduledPosts.removeAll { $0.id == post.id }
            }
            savePosts()
        }
    }
    
    func convertDraftToScheduledPost(_ draft: ScheduledPost, scheduledDate: Date) async throws {
        guard scheduledDate > Date() else {
            throw SchedulingError.invalidDate
        }
        
        // Create notification
        let notificationId = UUID().uuidString
        try await scheduleNotification(for: scheduledDate, notificationId: notificationId)
        
        // Update post
        var updatedPost = draft
        updatedPost.scheduledDate = scheduledDate
        updatedPost.notificationId = notificationId
        updatedPost.isDraft = false
        updatedPost.status = .scheduled
        updatedPost.lastModified = Date()
        
        await MainActor.run {
            drafts.removeAll { $0.id == draft.id }
            scheduledPosts.append(updatedPost)
            savePosts()
        }
    }
    
    // MARK: - Private Methods
    
    private func requestNotificationPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
        }
    }
    
    private func scheduleNotification(for date: Date, notificationId: String) async throws {
        let current = await notificationCenter.notificationSettings()
        guard current.authorizationStatus == .authorized else {
            throw SchedulingError.notificationsDenied
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Post!"
        content.body = "Your scheduled Instagram post is ready to be published."
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        try await notificationCenter.add(request)
    }
    
    private func saveImages(_ images: [UIImage]) async throws -> [String] {
        // Implementation for saving images to local storage
        // This would be enhanced with iCloud sync later
        return []
    }
    
    private func deleteImages(_ imageIds: [String]) async throws {
        // Implementation for deleting images from local storage
        // This would be enhanced with iCloud sync later
    }
    
    private func loadPosts() {
        if let data = defaults.data(forKey: "scheduledPosts"),
           let posts = try? JSONDecoder().decode([ScheduledPost].self, from: data)
        {
            scheduledPosts = posts
        }
        
        if let data = defaults.data(forKey: "drafts"),
           let loadedDrafts = try? JSONDecoder().decode([ScheduledPost].self, from: data)
        {
            drafts = loadedDrafts
        }
    }
    
    private func savePosts() {
        if let data = try? JSONEncoder().encode(scheduledPosts) {
            defaults.set(data, forKey: "scheduledPosts")
        }
        
        if let data = try? JSONEncoder().encode(drafts) {
            defaults.set(data, forKey: "drafts")
        }
    }
}
