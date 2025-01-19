import UIKit

enum ImageStorageError: Error {
    case saveFailed
    case loadFailed
    case deleteFailed
    case directoryCreationFailed
}

final class ImageStorageService {
    static let shared = ImageStorageService()
    
    private let fileManager = FileManager.default
    private let imageDirectory: URL
    
    private init() {
        // Get the Documents directory
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imageDirectory = documentsDirectory.appendingPathComponent("Images", isDirectory: true)
        
        // Create Images directory if it doesn't exist
        try? fileManager.createDirectory(at: imageDirectory,
                                         withIntermediateDirectories: true,
                                         attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
        
        // Add to iCloud backup
        addDirectoryToiCloudBackup()
    }
    
    // MARK: - Public Methods
    
    func saveImage(_ image: UIImage, withId id: String) throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageStorageError.saveFailed
        }
        
        let fileURL = imageDirectory.appendingPathComponent("\(id).jpg")
        try data.write(to: fileURL, options: .atomic)
    }
    
    func loadImage(withId id: String) -> UIImage? {
        let fileURL = imageDirectory.appendingPathComponent("\(id).jpg")
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }
    
    func deleteImage(withId id: String) throws {
        let fileURL = imageDirectory.appendingPathComponent("\(id).jpg")
        try fileManager.removeItem(at: fileURL)
    }
    
    func deleteAllImages() throws {
        let contents = try fileManager.contentsOfDirectory(at: imageDirectory,
                                                           includingPropertiesForKeys: nil,
                                                           options: [])
        for url in contents {
            try fileManager.removeItem(at: url)
        }
    }
    
    // MARK: - Private Methods
    
    private func addDirectoryToiCloudBackup() {
        var mutableURL = imageDirectory
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = false
        try? mutableURL.setResourceValues(resourceValues)
    }
    
    func migrateToiCloud() async throws {
        // Get all image files
        let contents = try fileManager.contentsOfDirectory(at: imageDirectory,
                                                           includingPropertiesForKeys: nil,
                                                           options: [])
        
        // Add each file to iCloud backup
        for url in contents {
            var mutableURL = url
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = false
            try? mutableURL.setResourceValues(resourceValues)
        }
    }
}
