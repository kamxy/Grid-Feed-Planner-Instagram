import SwiftUI

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var scheduledPosts: [ScheduledPost] = []
    @Published var isAddingNewPost = false
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private let postService: PostServiceProtocol
    
    init(postService: PostServiceProtocol = PostService()) {
        self.postService = postService
        loadPosts()
    }
    
    func addPost(_ post: ScheduledPost) {
        Task {
            do {
                isLoading = true
                try await postService.savePost(post)
                await loadPosts()
                isLoading = false
                isAddingNewPost = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func deletePost(at offsets: IndexSet) {
        Task {
            do {
                isLoading = true
                for index in offsets {
                    try await postService.deletePost(scheduledPosts[index])
                }
                await loadPosts()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func loadPosts() {
        Task {
            do {
                isLoading = true
                scheduledPosts = try await postService.loadPosts()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
} 