import SwiftUI

final class OnboardingCoordinator: ObservableObject {
    static let shared = OnboardingCoordinator()
    @ObservedObject private var subscriptionService = SubscriptionService.shared
    @ObservedObject private var onboardingService = OnboardingService.shared
    @ObservedObject private var gestureGuideService = GestureGuideService.shared
    private let appReviewService = AppReviewService.shared
    
    private init() {}
    
    func startFirstLaunchExperience() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            onboardingService.showOnboarding = true
        }
    }
    
    private func showInitialTips() {
        onboardingService.showNextTip()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.gestureGuideService.showGuideForFeature(.gridReorder)
        }
    }
    
    func onboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onboardingService.completeOnboarding()
        
        // Request app review after onboarding
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.subscriptionService.showPaywallIfNeeded(for: .gridCustomization)
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
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        onboardingService.showOnboarding = true
        gestureGuideService.resetGestureHistory()
    }
}
