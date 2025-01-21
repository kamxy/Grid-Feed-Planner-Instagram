import SwiftUI

struct StoryHighlightView: View {
    let highlights: [StoryHighlight]
    let onTapHighlight: (StoryHighlight) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(highlights) { highlight in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(width: 65, height: 65)
                            
                            if highlight.isAdd {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.appPink)
                            } else {
                                Image(uiImage: highlight.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            }
                        }
                        .onTapGesture {
                            onTapHighlight(highlight)
                        }
                        
                        Text(highlight.title)
                            .font(.caption)
                            .lineLimit(1)
                            .frame(maxWidth: 65)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Preview
struct StoryHighlightView_Previews: PreviewProvider {
    static var previews: some View {
        StoryHighlightView(
            highlights: [
                StoryHighlight.addNew,
                StoryHighlight(title: "Travel", image: UIImage(systemName: "photo")!),
                StoryHighlight(title: "Food", image: UIImage(systemName: "photo")!),
                StoryHighlight(title: "Nature", image: UIImage(systemName: "photo")!)
            ],
            onTapHighlight: { _ in }
        )
    }
} 