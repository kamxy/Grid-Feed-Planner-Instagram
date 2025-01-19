import Combine
import SwiftUI

@MainActor
final class GridViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var images: [UIImage?] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies

    private let imageService: ImageServiceProtocol
    private let imageCache = ImageCacheService.shared
    private let processingQueue = DispatchQueue(label: "com.instagramgridpreview.processing",
                                                qos: .userInitiated, attributes: .concurrent)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(imageService: ImageServiceProtocol = ImageService()) {
        self.imageService = imageService
        // Load cached images on init
        loadCachedImages()
    }
    
    // MARK: - Public Methods

    func addImage(_ image: UIImage) async {
        // Process image in background
        await processAndAddImage(image)
    }
    
    func updateImage(_ image: UIImage, at index: Int) {
        guard index < images.count else { return }
        
        // Process and cache updated image
        Task {
            await processAndAddImage(image)
            imageCache.cacheImage(image, forKey: "grid_image_\(index)")
            await MainActor.run {
                images[index] = image
            }
        }
    }
    
    func moveImage(from source: Int, to destination: Int) {
        guard source != destination else { return }
        
        // Update array
        let image = images.remove(at: source)
        images.insert(image, at: destination)
        
        // Update cache keys
        Task.detached {
            // Recache images with new indices
            for (index, image) in await self.images.enumerated() {
                if let image = image {
                    self.imageCache.cacheImage(image, forKey: "grid_image_\(index)")
                }
            }
        }
    }
    
    func removeImage(at index: Int) {
        guard index < images.count else { return }
        
        // Remove from cache
        imageCache.removeImage(forKey: "grid_image_\(index)")
        
        // Remove from array
        images.remove(at: index)
        
        // Update cache keys for remaining images
        Task.detached {
            // Recache images with new indices
            for (index, image) in await self.images.enumerated() {
                if let image = image {
                    await self.imageCache.cacheImage(image, forKey: "grid_image_\(index)")
                }
            }
        }
    }
    
    // MARK: - Private Methods

    private func loadCachedImages() {
        // Load cached images in background
        Task.detached {
            let cachedImages = (0 ..< 100).compactMap { index in
                self.imageCache.retrieveImage(forKey: "grid_image_\(index)")
            }
            await MainActor.run {
                self.images = cachedImages
            }
        }
    }
    
    private func processAndAddImage(_ image: UIImage) async {
        // Process image in background
        let processedImage = await withCheckedContinuation { continuation in
            processingQueue.async {
                // Resize image to reasonable size if needed
                let maxDimension: CGFloat = 1080 // Instagram's max dimension
                let size = image.size
                var newSize = size
                
                if size.width > maxDimension || size.height > maxDimension {
                    let ratio = size.width / size.height
                    if ratio > 1 {
                        newSize = CGSize(width: maxDimension, height: maxDimension / ratio)
                    } else {
                        newSize = CGSize(width: maxDimension * ratio, height: maxDimension)
                    }
                }
                
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                
                let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
                let processedImage = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                }
                
                continuation.resume(returning: processedImage)
            }
        }
        
        // Cache the processed image
        let imageIndex = images.count
        imageCache.cacheImage(processedImage, forKey: "grid_image_\(imageIndex)")
        
        // Update UI on main thread
        await MainActor.run {
            images.append(processedImage)
        }
    }
    
    private func loadImages() {
        Task {
            do {
                isLoading = true
                let loadedImages = try await imageService.loadImages()
                images = Array(repeating: nil, count: 9)
                for (index, image) in loadedImages.enumerated() {
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
