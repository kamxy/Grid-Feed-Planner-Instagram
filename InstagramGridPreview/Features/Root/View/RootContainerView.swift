import SwiftUI

struct RootContainerView: View {
    @StateObject private var onboardingCoordinator = OnboardingCoordinator.shared
    @ObservedObject private var onboardingService = OnboardingService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    var body: some View {
        NavigationStack {
            TabContentView()
                .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await subscriptionService.checkPremiumStatus()
        }
        .onAppear {
            onboardingCoordinator.startFirstLaunchExperience()
        }
    }
}

#Preview {
    NavigationView {
        RootContainerView()
    }
}
