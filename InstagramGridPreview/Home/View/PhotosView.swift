//
//  GridView.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 10.09.2024.
//

import SwiftUI

struct PhotosView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var draggedItem: OrderedImageEntity?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems, spacing: 1) {
                ForEach($viewModel.gridImages) { image in
                    SelectableImageItem(image: image, viewModel: viewModel)
                }
            }
        }
    }

    struct SelectableImageItem: View {
        @Binding var image: SelectableImage
        @StateObject var viewModel: HomeViewModel
        var itemWidth: CGFloat {
            (UIScreen.main.bounds.width) / 3
        }

        var body: some View {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image.image).resizable()
                    .scaledToFill()
                    .frame(width: itemWidth, height: itemWidth)
                    .clipped().onTapGesture {
                        image.isSelected.toggle()
                        if image.isSelected {
                            viewModel.selectedImages.append(image)
                        } else {
                            viewModel.selectedImages.removeAll { $0.id == image.id }
                        }
                    }
                if image.isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Circle())
                        .padding(8)
                }
                if image.isSelected {
                    Rectangle().foregroundColor(.white).opacity(0.3)
                }
            }
        }
    }
}

struct ImageItem: View {
    let image: UIImage
    var itemWidth: CGFloat {
        (UIScreen.main.bounds.width) / 3
    }

    var body: some View {
        Image(uiImage: image).resizable()
            .scaledToFill()
            .frame(width: itemWidth, height: itemWidth)
            .clipped()
    }
}

#Preview {
    PhotosView(viewModel: HomeViewModel())
}
