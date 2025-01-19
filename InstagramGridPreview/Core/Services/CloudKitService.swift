import CloudKit
import UIKit

enum CloudKitError: Error {
    case recordNotFound
    case invalidRecord
    case saveFailed
    case deleteFailed
    case fetchFailed
    case iCloudNotAvailable
}

final class CloudKitService {
    static let shared = CloudKitService()
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let recordType = "ScheduledPost"
    
    private init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Public Methods
    
    func checkiCloudStatus() async throws {
        try await container.accountStatus()
    }
    
    func save(_ post: ScheduledPost) async throws {
        let record = try createRecord(from: post)
        try await privateDatabase.save(record)
    }
    
    func delete(_ post: ScheduledPost) async throws {
        let recordID = CKRecord.ID(recordName: post.id.uuidString)
        try await privateDatabase.deleteRecord(withID: recordID)
    }
    
    func fetchAllPosts() async throws -> [ScheduledPost] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "lastModified", ascending: false)]
        
        let result = try await privateDatabase.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        return try records.compactMap { try createPost(from: $0) }
    }
    
    func syncPosts(_ posts: [ScheduledPost]) async throws {
        // Fetch existing records
        let existingPosts = try await fetchAllPosts()
        let existingIds = Set(existingPosts.map { $0.id })
        let newIds = Set(posts.map { $0.id })
        
        // Delete records that don't exist locally
        let idsToDelete = existingIds.subtracting(newIds)
        for id in idsToDelete {
            let recordID = CKRecord.ID(recordName: id.uuidString)
            try await privateDatabase.deleteRecord(withID: recordID)
        }
        
        // Save or update local records
        for post in posts {
            let record = try createRecord(from: post)
            try await privateDatabase.save(record)
        }
    }
    
    // MARK: - Private Methods
    
    private func createRecord(from post: ScheduledPost) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: post.id.uuidString)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        // Save image assets
        let imageAssets = try post.imageIds.enumerated().map { index, imageId -> CKAsset in
            guard let image = loadImage(withId: imageId),
                  let imageURL = saveImageTemporarily(image, withName: "\(post.id)-\(index).jpg")
            else {
                throw CloudKitError.invalidRecord
            }
            return CKAsset(fileURL: imageURL)
        }
        
        record["imageAssets"] = imageAssets
        record["caption"] = post.caption
        record["hashtags"] = post.hashtags
        record["scheduledDate"] = post.scheduledDate
        record["notificationId"] = post.notificationId
        record["isDraft"] = post.isDraft
        record["lastModified"] = post.lastModified
        record["status"] = post.status.rawValue
        
        return record
    }
    
    private func createPost(from record: CKRecord) throws -> ScheduledPost {
        guard let assets = record["imageAssets"] as? [CKAsset],
              let caption = record["caption"] as? String,
              let hashtags = record["hashtags"] as? [String],
              let scheduledDate = record["scheduledDate"] as? Date,
              let notificationId = record["notificationId"] as? String,
              let isDraft = record["isDraft"] as? Bool,
              let lastModified = record["lastModified"] as? Date,
              let statusRaw = record["status"] as? String,
              let status = ScheduledPost.PostStatus(rawValue: statusRaw)
        else {
            throw CloudKitError.invalidRecord
        }
        
        // Save images and get their IDs
        let imageIds = try assets.enumerated().map { index, asset -> String in
            guard let imageData = try? Data(contentsOf: asset.fileURL),
                  let image = UIImage(data: imageData)
            else {
                throw CloudKitError.invalidRecord
            }
            
            let imageId = "\(record.recordID.recordName)-\(index)"
            try saveImage(image, withId: imageId)
            return imageId
        }
        
        return ScheduledPost(
            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
            imageIds: imageIds,
            caption: caption,
            hashtags: hashtags,
            scheduledDate: scheduledDate,
            notificationId: notificationId,
            isDraft: isDraft,
            lastModified: lastModified,
            status: status
        )
    }
    
    private func saveImageTemporarily(_ image: UIImage, withName name: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(name)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        try? data.write(to: fileURL)
        return fileURL
    }
    
    private func loadImage(withId id: String) -> UIImage? {
        // Implementation will be provided by ImageStorageService
        return nil
    }
    
    private func saveImage(_ image: UIImage, withId id: String) throws {
        // Implementation will be provided by ImageStorageService
    }
}
