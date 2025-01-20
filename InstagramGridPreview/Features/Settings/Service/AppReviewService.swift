import StoreKit

final class AppReviewService {
    static let shared = AppReviewService()
    
    private let defaults = UserDefaults.standard
    private let lastReviewRequestKey = "last_review_request_date"
    private let significantActionsKey = "significant_actions_count"
    
    private init() {}
    
    func incrementSignificantActions() {
        let count = defaults.integer(forKey: significantActionsKey)
        defaults.set(count + 1, forKey: significantActionsKey)
        
        // Check if we should request a review
        if shouldRequestReview() {
            requestReview()
        }
    }
    
    func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        SKStoreReviewController.requestReview(in: scene)
        defaults.set(Date(), forKey: lastReviewRequestKey)
        defaults.set(0, forKey: significantActionsKey) // Reset counter
    }
    
    private func shouldRequestReview() -> Bool {
        // Get the last review request date
        let lastRequest = defaults.object(forKey: lastReviewRequestKey) as? Date
        
        // If we've never requested or it's been more than 60 days
        let daysSinceLastRequest = Calendar.current.dateComponents([.day], 
            from: lastRequest ?? .distantPast, 
            to: Date()).day ?? 0
            
        let significantActions = defaults.integer(forKey: significantActionsKey)
        
        // Request review if:
        // 1. User has performed at least 5 significant actions AND
        // 2. Either we've never requested a review OR it's been more than 60 days
        return significantActions >= 5 && daysSinceLastRequest > 60
    }
} 