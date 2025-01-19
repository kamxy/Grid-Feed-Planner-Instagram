import UIKit

// MARK: - ImageServiceProtocol
protocol ImageServiceProtocol {
    func saveImages(_ images: [UIImage?]) async throws
    func loadImages() async throws -> [UIImage?]
    func saveImage(_ image: UIImage, withName name: String) async throws
    func loadImage(named name: String) async throws -> UIImage?
}

// MARK: - ImageService
final class ImageService: ImageServiceProtocol {
    private let fileManager: FileManager
    private let documentsPath: URL
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveImages(_ images: [UIImage?]) async throws {
        // Clear existing images
        let existingFiles = try fileManager.contentsOfDirectory(
            at: documentsPath,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
        for file in existingFiles where file.lastPathComponent.hasPrefix("grid_image_") {
            try fileManager.removeItem(at: file)
        }
        
        // Save new images with index in filename
        for (index, image) in images.enumerated() {
            if let image = image {
                try await saveImage(image, withName: "grid_image_\(String(format: "%02d", index))")
            }
        }
    }
    
    func loadImages() async throws -> [UIImage?] {
        var images = Array(repeating: nil as UIImage?, count: 9)
        let fileURLs = try fileManager.contentsOfDirectory(
            at: documentsPath,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
        
        for fileURL in fileURLs where fileURL.lastPathComponent.hasPrefix("grid_image_") {
            if let indexStr = fileURL.lastPathComponent.split(separator: "_").last,
               let index = Int(indexStr),
               index < images.count,
               let image = try await loadImage(named: fileURL.lastPathComponent) {
                images[index] = image
            }
        }
        
        return images
    }
    
    func saveImage(_ image: UIImage, withName name: String) async throws {
        let imageURL = documentsPath.appendingPathComponent(name)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageError.compressionFailed
        }
        try data.write(to: imageURL)
    }
    
    func loadImage(named name: String) async throws -> UIImage? {
        let imageURL = documentsPath.appendingPathComponent(name)
        let data = try Data(contentsOf: imageURL)
        guard let image = UIImage(data: data) else {
            throw ImageError.loadFailed
        }
        return image
    }
}

// MARK: - ImageError
enum ImageError: LocalizedError {
    case compressionFailed
    case loadFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .loadFailed:
            return "Failed to load image"
        case .saveFailed:
            return "Failed to save image"
        }
    }
} 