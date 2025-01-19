import UIKit

enum InstagramShareError: Error {
    case instagramNotInstalled
    case imageExportFailed
    case urlCreationFailed
}

final class InstagramShareService {
    static let shared = InstagramShareService()
    
    private init() {}
    
    func shareToInstagram(_ image: UIImage) throws {
        // Check if Instagram is installed
        guard let instagramURL = URL(string: "instagram://app") else {
            throw InstagramShareError.urlCreationFailed
        }
        
        guard UIApplication.shared.canOpenURL(instagramURL) else {
            throw InstagramShareError.instagramNotInstalled
        }
        
        // Save image to temporary directory
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            throw InstagramShareError.imageExportFailed
        }
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileName = "instagram_share_\(UUID().uuidString).ig"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            
            // Share to Instagram
            let pasteboardItems: [[String: Any]] = [
                ["com.instagram.sharedSticker.stickerImage": fileURL,
                 "com.instagram.sharedSticker.backgroundTopColor": "#636e72",
                 "com.instagram.sharedSticker.backgroundBottomColor": "#b2bec3"]
            ]
            
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate:
                    Date().addingTimeInterval(300) // 5 minutes expiration
            ]
            
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            
            UIApplication.shared.open(instagramURL, options: [:]) { success in
                // Clean up temporary file
                try? fileManager.removeItem(at: fileURL)
            }
        } catch {
            throw InstagramShareError.imageExportFailed
        }
    }
    
    func isInstagramInstalled() -> Bool {
        guard let instagramURL = URL(string: "instagram://app") else { return false }
        return UIApplication.shared.canOpenURL(instagramURL)
    }
} 