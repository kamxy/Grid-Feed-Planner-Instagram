import SwiftUI

enum TabSection: String, CaseIterable {
    case grid = "Grid"
    case reels = "Reels"
    
    var icon: String {
        switch self {
        case .grid: return "square.grid.3x3"
        case .reels: return "video.fill"
        }
    }
}

struct TabContentView: View {
    @State private var selectedTab: TabSection = .grid
    @State private var highlights: [StoryHighlight] = [
        StoryHighlight.addNew,
        StoryHighlight(title: "Travel", image: UIImage(systemName: "photo")!),
        StoryHighlight(title: "Food", image: UIImage(systemName: "photo")!),
        StoryHighlight(title: "Nature", image: UIImage(systemName: "photo")!)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Story Highlights
            StoryHighlightView(highlights: highlights) { highlight in
                if highlight.isAdd {
                    // Handle add new highlight
                } else {
                    // Handle view highlight
                }
            }
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(TabSection.allCases, id: \.self) { tab in
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24))
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == tab ? .primary : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(selectedTab == tab ? Color.primary : Color.clear)
                                .frame(height: 1)
                        }
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal)
            
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

// MARK: - Preview
struct TabContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabContentView()
    }
} 