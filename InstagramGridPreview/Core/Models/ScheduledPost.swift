import Foundation

struct ScheduledPost: Identifiable, Codable {
    let id: UUID
    var image: Data
    var caption: String
    var scheduledDate: Date
    var hashtags: [String]
    var isPublished: Bool
    
    init(id: UUID = UUID(), image: Data, caption: String, scheduledDate: Date, hashtags: [String] = [], isPublished: Bool = false) {
        self.id = id
        self.image = image
        self.caption = caption
        self.scheduledDate = scheduledDate
        self.hashtags = hashtags
        self.isPublished = isPublished
    }
} 