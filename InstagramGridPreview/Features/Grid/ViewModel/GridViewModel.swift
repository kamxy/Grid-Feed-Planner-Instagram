import SwiftUI
import Combine

@MainActor
final class GridViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var images: [UIImage?] = Array(repeating: nil, count: 9)
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let imageService: ImageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(imageService: ImageServiceProtocol = ImageService()) {
        self.imageService = imageService
        loadImages()
    }
    
    // MARK: - Public Methods
    func addImage(_ image: UIImage) {
        guard let emptyIndex = images.firstIndex(where: { $0 == nil }) else { return }
        images[emptyIndex] = image
        saveImages()
    }
    
    func updateImage(_ image: UIImage, at index: Int) {
        guard index < images.count else { return }
        images[index] = image
        saveImages()
    }
    
    func moveImage(from source: Int, to destination: Int) {
        guard source != destination,
              source < images.count,
              destination < images.count else { return }
        
        let sourceImage = images[source]
        images[source] = images[destination]
        images[destination] = sourceImage
        
        saveImages()
    }
    
    func removeImage(at index: Int) {
        guard index < images.count else { return }
        images[index] = nil
        saveImages()
    }
    
    // MARK: - Private Methods
    private func saveImages() {
        Task {
            do {
                isLoading = true
                try await imageService.saveImages(images.compactMap { $0 })
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func loadImages() {
        Task {
            do {
                isLoading = true
                let loadedImages = try await imageService.loadImages()
                images = Array(repeating: nil, count: 9)
                loadedImages.enumerated().forEach { index, image in
                    if index < 9 {
                        images[index] = image
                    }
                }
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
} 