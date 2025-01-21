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
}

struct TabContentView: View {
    @State private var selectedTab: TabSection = .grid
    @StateObject private var storyHighlightViewModel = StoryHighlightViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Story Highlights
            StoryHighlightView()
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(TabSection.allCases, id: \.self) { tab in
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == tab ? .primary : .gray)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            selectedTab = tab
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
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

#Preview {
    TabContentView()
}
