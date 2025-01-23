import RevenueCat
import SwiftUI

enum SubscriptionFeature: String {
    case unlimitedPhotos = "unlimited_photos"
    case scheduling
    case gridCustomization = "grid_customization"
    case iCloudSync = "icloud_sync"
    case unlimitedReels
    case unlimitedStories
    case imageEditing
    
    var title: String {
        switch self {
        case .unlimitedPhotos: return "Unlimited Photos"
        case .scheduling: return "Post Scheduling"
        case .gridCustomization: return "Grid Customization"
        case .iCloudSync: return "iCloud Sync"
        case .unlimitedReels: return "Unlimited Reels"
        case .unlimitedStories: return "Unlimited Stories"
        case .imageEditing: return "Image Editing"
        }
    }
    
    var description: String {
        switch self {
        case .unlimitedPhotos: return "Preview unlimited photos in your grid"
        case .scheduling: return "Schedule your posts for the perfect timing"
        case .gridCustomization: return "Customize grid layout with different styles"
        case .iCloudSync: return "Sync your data across all devices"
        case .unlimitedReels: return "Unlimited Reels"
        case .unlimitedStories: return "Unlimited Stories"
        case .imageEditing: return "Image Editing"
        }
    }
    
    var icon: String {
        switch self {
        case .unlimitedPhotos: return "photo.stack"
        case .scheduling: return "calendar"
        case .gridCustomization: return "square.grid.3x3"
        case .iCloudSync: return "icloud"
        case .unlimitedReels: return "Unlimited Reels"
        case .unlimitedStories: return "Unlimited Stories"
        case .imageEditing: return "Image Editing"
        }
    }
}

@MainActor
final class SubscriptionService: NSObject, ObservableObject {
    static let shared = SubscriptionService()
    
    @Published private(set) var isPremium = false
    @Published var showingPaywall = false
    @Published private(set) var products: [Package] = []
    @Published private(set) var currentSubscription: String?
    
    private let defaults = UserDefaults.standard
    private let freePhotoLimit = 3
    
    override private init() {
        super.init()
        configureRevenueCat()
        observeCustomerInfo()
    }
    
    private func configureRevenueCat() {
        Purchases.configure(
            with: Configuration.Builder(withAPIKey: AppConfig.revenueCatAPIKey)
                .with(usesStoreKit2IfAvailable: true)
                .build()
        )
        Purchases.shared.delegate = self
        
        // Enable debug logs in development
        #if DEBUG
        Purchases.logLevel = .debug
        AppConfig.validateConfiguration()
        #endif
    }
    
    private func observeCustomerInfo() {
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                updateSubscriptionStatus(with: customerInfo)
            }
        }
    }
    
    func updateSubscriptionStatus(with customerInfo: CustomerInfo) {
        isPremium = !customerInfo.entitlements.active.isEmpty
        currentSubscription = customerInfo.entitlements.active.keys.first
        
        // Save premium status to UserDefaults for persistence
        defaults.set(isPremium, forKey: "isPremium")
        defaults.set(currentSubscription, forKey: "currentSubscription")
    }
    
    func updateWithMannualy() {
        isPremium = true
    }
    
    func checkPremiumStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateSubscriptionStatus(with: customerInfo)
        } catch {
            // Fallback to cached status
            isPremium = defaults.bool(forKey: "isPremium")
            currentSubscription = defaults.string(forKey: "currentSubscription")
            print("Error fetching premium status: \(error)")
        }
    }
    
    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            if let packages = offerings.current?.availablePackages {
                products = packages
            }
        } catch {
            print("Error loading offerings: \(error)")
        }
    }
    
    func purchase(_ package: Package) async throws {
        let purchaseResult = try await Purchases.shared.purchase(package: package)
        updateSubscriptionStatus(with: purchaseResult.customerInfo)
    }
    
    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        updateSubscriptionStatus(with: customerInfo)
    }
    
    // Feature access checks
    func canAddMorePhotos(currentCount: Int) -> Bool {
        return isPremium || currentCount < freePhotoLimit
    }
    
    func canAccessScheduling() -> Bool {
        return isPremium
    }
    
    func canAccessGridCustomization() -> Bool {
        return isPremium
    }
    
    func canAccessICloudSync() -> Bool {
        return isPremium
    }
    
    func showPaywallIfNeeded(for feature: SubscriptionFeature) {
        switch feature {
        case .unlimitedPhotos, .scheduling, .gridCustomization, .iCloudSync, .unlimitedReels, .unlimitedStories, .imageEditing:
            if !isPremium {
                showingPaywall = true
            }
        }
    }
}

extension SubscriptionService: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        updateSubscriptionStatus(with: customerInfo)
    }
}
