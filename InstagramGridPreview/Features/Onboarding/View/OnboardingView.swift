import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var onboardingService = OnboardingService.shared
    @ObservedObject private var onboardingCoordinator = OnboardingCoordinator.shared
    @Environment(\.dismiss) private var dismiss
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to Instagram Grid Preview",
            description: "Plan and perfect your Instagram feed with our powerful grid preview and editing tools.",
            icon: "square.grid.3x3.fill"
        ),
        OnboardingPage(
            title: "Edit & Arrange",
            description: "Edit photos individually or in bulk. Drag and drop to find the perfect arrangement for your feed.",
            icon: "slider.horizontal.3"
        ),
        OnboardingPage(
            title: "Export & Share",
            description: "Export your grid, save to Photos, or share directly to Instagram with optimized settings.",
            icon: "square.and.arrow.up.fill"
        )
    ]
    
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(systemName: pages[index].icon)
                                .font(.system(size: 80))
                                .foregroundColor(.appPink)
                            
                            Text(pages[index].title)
                                .font(.title)
                                .bold()
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[index].description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onboardingCoordinator.onboardingCompleted()
                        dismiss()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appPink)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

private struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
}
