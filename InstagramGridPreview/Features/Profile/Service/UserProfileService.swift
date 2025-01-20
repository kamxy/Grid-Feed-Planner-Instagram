import Foundation
import SwiftUI

@MainActor
final class UserProfileService: ObservableObject {
    static let shared = UserProfileService()
    
    @Published private(set) var profile: UserProfile
    
    private let defaults = UserDefaults.standard
    private let profileKey = "user_profile"
    
    private init() {
        if let data = defaults.data(forKey: profileKey),
           let savedProfile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = savedProfile
        } else {
            profile = UserProfile()
        }
    }
    
    func updateUsername(_ username: String) {
        profile = UserProfile(username: username, profileImage: profile.profileImage)
        saveProfile()
    }
    
    func updateProfileImage(_ image: UIImage?) {
        profile = UserProfile(username: profile.username, profileImage: image)
        saveProfile()
    }
    
    private func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: profileKey)
        }
    }
} 