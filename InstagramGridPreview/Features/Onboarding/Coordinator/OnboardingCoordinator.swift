import SwiftUI

final class OnboardingCoordinator: ObservableObject {
    static let shared = OnboardingCoordinator()
    
    @ObservedObject private var onboardingService = OnboardingService.shared
    @ObservedObject private var gestureGuideService = GestureGuideService.shared
    private let appReviewService = AppReviewService.shared
    
    private init() {}
    
    func startFirstLaunchExperience() {
        // Show onboarding if not completed
        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            onboardingService.showOnboarding = true
        }
        
        // Schedule initial tips
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showInitialTips()
        }
    }
    
    private func showInitialTips() {
        // Show grid management tip first
        onboardingService.showNextTip()
        
        // Schedule gesture guide for grid reordering
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.gestureGuideService.showGuideForFeature(.gridReorder)
        }
    }
    
    func onboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onboardingService.completeOnboarding()
        
        // Request app review after onboarding
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.appReviewService.requestReview()
        }
        
        // Start showing feature-specific guides
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.gestureGuideService.showGuideForFeature(.imageEdit)
        }
    }
    
    func showFeatureGuide(_ feature: GestureFeature) {
        gestureGuideService.showGuideForFeature(feature)
    }
    
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        onboardingService.showOnboarding = true
        gestureGuideService.resetGestureHistory()
    }
} 