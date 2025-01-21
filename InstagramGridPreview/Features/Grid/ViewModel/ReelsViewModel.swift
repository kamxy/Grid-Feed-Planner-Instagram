import SwiftUI
import CoreData

@MainActor
final class ReelsViewModel: ObservableObject {
    @Published private(set) var images: [UIImage?] = []
    private let reelsImageService = ReelsImageService()
    
    init() {
        Task {
            do {
                images = try await reelsImageService.loadReelsImages()
            } catch {
                print("Error loading reel images: \(error)")
            }
        }
    }
    
    func addImage(_ image: UIImage) async {
        images.append(image)
        do {
            try await reelsImageService.saveReelsImages(images)
        } catch {
            print("Error saving reel images: \(error)")
        }
    }
    
    func removeImage(at index: Int) {
        guard index < images.count else { return }
        images.remove(at: index)
        
        Task {
            do {
                try await reelsImageService.saveReelsImages(images)
            } catch {
                print("Error saving reel images after removal: \(error)")
            }
        }
    }
    
    func moveImage(from source: Int, to destination: Int) {
        guard source < images.count, destination < images.count else { return }
        let image = images.remove(at: source)
        images.insert(image, at: destination)
        
        Task {
            do {
                try await reelsImageService.saveReelsImages(images)
            } catch {
                print("Error saving reel images after reorder: \(error)")
            }
        }
    }
    
    func updateImage(_ image: UIImage, at index: Int) {
        guard index < images.count else { return }
        images[index] = image
        
        Task {
            do {
                try await reelsImageService.saveReelsImages(images)
            } catch {
                print("Error saving reel images after update: \(error)")
            }
        }
    }
} 