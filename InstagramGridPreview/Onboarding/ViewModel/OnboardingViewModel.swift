import SwiftUI

// View Model to handle the UserDefaults logic
class OnboardingViewModel: ObservableObject {
    @Published var isOnboardingDone: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingDone, forKey: "isOnboardingDone")
        }
    }

    init() {
        // Load the state from UserDefaults when the app starts
        self.isOnboardingDone = UserDefaults.standard.bool(forKey: "isOnboardingDone")
    }
}
