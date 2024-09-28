import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = OnboardingViewModel()

    var body: some View {
        if viewModel.isOnboardingDone {
            HomeView()
        } else {
            OnboardingView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
