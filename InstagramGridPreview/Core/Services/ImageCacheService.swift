import UIKit

final class ImageCacheService {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL
    
    private init() {
        // Set up disk cache directory
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheDirectory = cacheDirectory.appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
        
        // Configure memory cache
        cache.countLimit = 100 // Maximum number of images in memory
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB limit
        
        // Add cleanup notification observers
        NotificationCenter.default.addObserver(self,
            selector: #selector(cleanupCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        // Memory cache
        cache.setObject(image, forKey: key as NSString)
        
        // Disk cache
        let fileURL = diskCacheDirectory.appendingPathComponent(key)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    func retrieveImage(forKey key: String) -> UIImage? {
        // Check memory cache first
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // Check disk cache
        let fileURL = diskCacheDirectory.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            // Add back to memory cache
            cache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        let fileURL = diskCacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    @objc private func cleanupCache() {
        cache.removeAllObjects()
    }
    
    func clearAllCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheDirectory)
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }
} 