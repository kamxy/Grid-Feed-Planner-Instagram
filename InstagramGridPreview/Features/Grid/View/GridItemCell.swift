import SwiftUI

struct GridItemCell: View {
    let image: UIImage
    let isSelected: Bool
    let isEditMode: Bool
    let isDragged: Bool
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
                    .opacity(isDragged ? 0.5 : 1.0)
                    .scaleEffect(isSelected ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
                
                if isEditMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .appPink : .white)
                        .background(Circle().fill(Color.white.opacity(0.8)))
                        .padding(4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
} 