import SwiftUI

@main
struct InstagramGridPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                RootContainerView()
                    .task {
                        await SubscriptionService.shared.checkPremiumStatus()
                    }
            }
        }
    }
}
