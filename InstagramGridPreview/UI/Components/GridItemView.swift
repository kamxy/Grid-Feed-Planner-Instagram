import SwiftUI

struct GridItemView: View {
    let image: UIImage
    var onTap: (() -> Void)?
    var onDelete: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.width)
                .clipped()
                .onTapGesture {
                    onTap?()
                }
                .contextMenu {
                    if let onDelete = onDelete {
                        Button(role: .destructive, action: onDelete) {
                            Label("alert.delete".localized, systemImage: "trash")
                        }
                    }
                }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("grid.image".localized)
        .accessibilityAddTraits(.isImage)
    }
}

struct AddPhotoButton: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.2)
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Add Photo")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview
struct GridItemView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            GridItemView(image: UIImage(systemName: "photo")!)
            AddPhotoButton()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 