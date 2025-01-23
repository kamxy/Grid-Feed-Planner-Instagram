import RevenueCat
import RevenueCatUI
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var offering: Offering?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let offering = offering {
                ScrollView(.vertical) {
                    Image("paywallBg").resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }.disabled(true).paywallFooter(offering: offering, condensed: true, purchaseCompleted: { customerInfo in
                    subscriptionService.updateSubscriptionStatus(with: customerInfo)
                    dismiss()
                }, restoreCompleted: { customerInfo in
                    // Update subscription status after restore
                    subscriptionService.updateSubscriptionStatus(with: customerInfo)
                    dismiss()
                })

            } else if isLoading {
                ProgressView()
            } else {
                Text("Failed to load subscription options")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            do {
                // Load offerings
                let offerings = try await Purchases.shared.offerings()
                self.offering = offerings.current

                // Load available packages
                if let packages = offerings.current?.availablePackages {
                    await subscriptionService.loadOfferings()
                }

                isLoading = false
            } catch {
                print("Error fetching offerings: \(error)")
                isLoading = false
            }
        }
        .onAppear {
            // Check subscription status on appear
            Task {
                do {
                    let customerInfo = try await Purchases.shared.customerInfo()
                    subscriptionService.updateSubscriptionStatus(with: customerInfo)
                } catch {
                    print("Error fetching customer info: \(error)")
                }
            }
        }
    }
}

#Preview {
    PaywallView()
}
