import PhotosUI
import SwiftUI

enum TabSection: String, CaseIterable {
    case grid = "Grid"
    case reels = "Reels"
    
    var icon: String {
        switch self {
        case .grid: return "square.grid.3x3"
        case .reels: return "play.rectangle"
        }
    }
    
    var requiresPremium: Bool {
        switch self {
        case .grid: return false
        case .reels: return true
        }
    }
}

struct TabContentView: View {
    @State private var selectedTab: TabSection = .grid
    @StateObject private var storyHighlightViewModel = StoryHighlightViewModel()
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Story Highlights
            StoryHighlightView()
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(TabSection.allCases, id: \.self) { tab in
                    VStack(spacing: 4) {
                        ZStack {
                            Image(systemName: tab.icon)
                                .font(.title3)
                            
                            if tab.requiresPremium && !subscriptionService.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 16, height: 16)
                                    )
                                    .offset(x: 12, y: -12)
                            }
                        }
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == tab ? .primary : .gray)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if tab.requiresPremium && !subscriptionService.isPremium {
                            subscriptionService.showPaywallIfNeeded(for: .unlimitedReels)
                        } else {
                            withAnimation(.easeInOut) {
                                selectedTab = tab
                            }
                        }
                    }.onLongPressGesture {
                        if tab == .grid {
                            subscriptionService.updateWithMannualy()
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                GridView()
                    .tag(TabSection.grid)
                
                ReelsView()
                    .tag(TabSection.reels)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)).onChange(of: selectedTab) { _ in
                if !subscriptionService.isPremium && selectedTab == .reels {
                    withAnimation {
                        selectedTab = .grid
                    }
                    subscriptionService.showPaywallIfNeeded(for: .unlimitedReels)
                }
            }
        }
    }
}

#Preview {
    TabContentView()
}
