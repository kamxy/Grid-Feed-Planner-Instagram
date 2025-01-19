import Foundation

protocol PostServiceProtocol {
    func savePost(_ post: ScheduledPost) async throws
    func loadPosts() async throws -> [ScheduledPost]
    func deletePost(_ post: ScheduledPost) async throws
    func updatePost(_ post: ScheduledPost) async throws
}

final class PostService: PostServiceProtocol {
    private let fileManager: FileManager
    private let postsURL: URL
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.postsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("scheduled_posts.json")
    }
    
    func savePost(_ post: ScheduledPost) async throws {
        var posts = try await loadPosts()
        posts.append(post)
        try await savePosts(posts)
    }
    
    func loadPosts() async throws -> [ScheduledPost] {
        guard fileManager.fileExists(atPath: postsURL.path) else { return [] }
        
        let data = try Data(contentsOf: postsURL)
        let posts = try JSONDecoder().decode([ScheduledPost].self, from: data)
        return posts.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    func deletePost(_ post: ScheduledPost) async throws {
        var posts = try await loadPosts()
        posts.removeAll { $0.id == post.id }
        try await savePosts(posts)
    }
    
    func updatePost(_ post: ScheduledPost) async throws {
        var posts = try await loadPosts()
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = post
            try await savePosts(posts)
        }
    }
    
    private func savePosts(_ posts: [ScheduledPost]) async throws {
        let data = try JSONEncoder().encode(posts)
        try data.write(to: postsURL)
    }
} 