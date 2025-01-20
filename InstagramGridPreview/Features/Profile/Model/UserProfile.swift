import UIKit

struct UserProfile: Codable {
    var username: String
    var profileImageData: Data?
    
    var profileImage: UIImage? {
        guard let data = profileImageData else { return nil }
        return UIImage(data: data)
    }
    
    init(username: String = "", profileImage: UIImage? = nil) {
        self.username = username
        self.profileImageData = profileImage?.jpegData(compressionQuality: 0.8)
    }
} 