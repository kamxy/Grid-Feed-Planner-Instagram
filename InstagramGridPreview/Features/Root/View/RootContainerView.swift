import SwiftUI

struct RootContainerView: View {
    @StateObject private var onboardingCoordinator = OnboardingCoordinator.shared
    @ObservedObject private var onboardingService = OnboardingService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    var body: some View {
        TabView {
            GridView()
                .tabItem {
                    Image(systemName: "square.grid.3x3")
                    Text("Grid")
                }
            
            SchedulingView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedule")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .task {
            await subscriptionService.checkPremiumStatus()
        }
        .sheet(isPresented: $subscriptionService.showingPaywall) {
            PaywallView()
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
