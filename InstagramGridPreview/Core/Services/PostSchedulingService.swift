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
    private let cloudKitService = CloudKitService.shared
    private let imageStorage = ImageStorageService.shared
    
    private init() {
        loadPosts()
        requestNotificationPermissions()
        setupCloudSync()
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
        
        // Save post locally and to iCloud
        await MainActor.run {
            scheduledPosts.append(post)
            savePosts()
        }
        
        try await cloudKitService.save(post)
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
        var imageIds: [String] = []
        for image in images {
            let imageId = UUID().uuidString
            try imageStorage.saveImage(image, withId: imageId)
            imageIds.append(imageId)
        }
        return imageIds
    }
    
    private func deleteImages(_ imageIds: [String]) async throws {
        for imageId in imageIds {
            try imageStorage.deleteImage(withId: imageId)
        }
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
    
    private func setupCloudSync() {
        Task {
            do {
                try await cloudKitService.checkiCloudStatus()
                let cloudPosts = try await cloudKitService.fetchAllPosts()
                
                await MainActor.run {
                    // Merge cloud posts with local posts
                    let allPosts = Set(scheduledPosts + drafts)
                    let cloudSet = Set(cloudPosts)
                    
                    // Use most recent version of each post
                    let mergedPosts = allPosts.union(cloudSet).sorted {
                        $0.lastModified > $1.lastModified
                    }
                    
                    // Update local state
                    scheduledPosts = mergedPosts.filter { !$0.isDraft }
                    drafts = mergedPosts.filter { $0.isDraft }
                    
                    savePosts()
                }
                
                // Sync back to cloud
                try await cloudKitService.syncPosts(scheduledPosts + drafts)
            } catch {
                print("Cloud sync failed: \(error)")
            }
        }
    }
    
    private func savePosts() {
        if let data = try? JSONEncoder().encode(scheduledPosts) {
            defaults.set(data, forKey: "scheduledPosts")
        }
        
        if let data = try? JSONEncoder().encode(drafts) {
            defaults.set(data, forKey: "drafts")
        }
        
        // Sync to iCloud
        Task {
            try await cloudKitService.syncPosts(scheduledPosts + drafts)
        }
    }
}
