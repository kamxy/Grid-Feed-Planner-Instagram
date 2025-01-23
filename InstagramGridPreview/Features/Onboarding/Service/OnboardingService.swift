import SwiftUI

struct OnboardingTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let feature: OnboardingFeature
}

enum OnboardingFeature: String {
    case gridManagement
    case imageEditing
    case export
    case instagram
    case scheduling
}

final class OnboardingService: ObservableObject {
    static let shared = OnboardingService()
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("lastShownTipDate") private var lastShownTipDate: Double = 0
    @AppStorage("shownTips") private var shownTipsData: Data = Data()
    
    @Published var currentTip: OnboardingTip?
    @Published var showOnboarding = false
    
    private let tips: [OnboardingTip] = [
        OnboardingTip(
            title: "Grid Management",
            description: "Add photos by tapping +, rearrange with drag & drop, or select multiple images to edit them together.",
            icon: "square.grid.3x3",
            feature: .gridManagement
        ),
        OnboardingTip(
            title: "Image Editing",
            description: "Tap any image to edit. Apply filters, adjust brightness & contrast, or crop to perfect your grid.",
            icon: "wand.and.stars",
            feature: .imageEditing
        ),
        OnboardingTip(
            title: "Export Options",
            description: "Export your grid as a single image, save to Photos, or copy to clipboard for sharing.",
            icon: "square.and.arrow.up",
            feature: .export
        ),
        OnboardingTip(
            title: "Instagram Integration",
            description: "Share directly to Instagram with optimized image quality and proper dimensions.",
            icon: "camera",
            feature: .instagram
        ),
        OnboardingTip(
            title: "Post Scheduling",
            description: "Plan your posts with the calendar view and get reminders when it's time to post.",
            icon: "calendar",
            feature: .scheduling
        )
    ]
    
    private init() {
        if !hasCompletedOnboarding {
            showOnboarding = true
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        showOnboarding = false
    }
    
    func showNextTip() {
        guard shouldShowTip() else { return }
        
        var shownTips: Set<String> = []
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: shownTipsData) {
            shownTips = decoded
        }
        
        let availableTips = tips.filter { !shownTips.contains($0.feature.rawValue) }
        if let tip = availableTips.randomElement() {
            currentTip = tip
            shownTips.insert(tip.feature.rawValue)
            if let encoded = try? JSONEncoder().encode(shownTips) {
                shownTipsData = encoded
            }
            lastShownTipDate = Date().timeIntervalSince1970
        }
    }
    
    private func shouldShowTip() -> Bool {
        let lastShown = Date(timeIntervalSince1970: lastShownTipDate)
        let timeSinceLastTip = Date().timeIntervalSince(lastShown)
        return timeSinceLastTip >= 24 * 3600 // Show max one tip per day
    }
    
    func dismissCurrentTip() {
        currentTip = nil
    }
} 