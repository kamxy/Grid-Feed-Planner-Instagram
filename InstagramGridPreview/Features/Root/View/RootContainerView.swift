import SwiftUI

struct RootContainerView: View {
    @StateObject private var onboardingCoordinator = OnboardingCoordinator.shared
    @ObservedObject private var onboardingService = OnboardingService.shared

    var body: some View {
        ZStack {
            // Main App Content
            ContentView()
                .quickTip()
                .gestureGuide()
                // Onboarding Sheet
                .sheet(isPresented: $onboardingService.showOnboarding) {
                    OnboardingView()
                        .interactiveDismissDisabled()
                }
        }
        .onAppear {
            onboardingCoordinator.startFirstLaunchExperience()
        }
        // Add Settings button to show/reset onboarding (for testing)
        /*  .toolbar {
             #if DEBUG
             ToolbarItem(placement: .navigationBarTrailing) {
                 Button(action: {
                     onboardingCoordinator.resetOnboarding()
                 }) {
                     Image(systemName: "arrow.counterclockwise")
                 }
             }
             #endif
         } */
    }
}

#Preview {
    NavigationView {
        RootContainerView()
    }
}
