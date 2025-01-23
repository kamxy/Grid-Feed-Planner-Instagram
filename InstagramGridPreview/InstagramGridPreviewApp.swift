import SwiftUI

@main
struct InstagramGridPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            RootContainerView()
                .task {
                    await SubscriptionService.shared.checkPremiumStatus()
                }
        }
    }
}
