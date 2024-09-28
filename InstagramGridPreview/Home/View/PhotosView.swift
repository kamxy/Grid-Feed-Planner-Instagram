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
        if(viewModel.gridImages.isEmpty){
            
            VStack{
                Text("Oops! This place is empty.").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(5).padding(.top,40)
                Text("It looks like you haven't added any photos yet. You can add and edit photos here").multilineTextAlignment(.center).font(.title3)
                Image("placeholder").padding(.top,20)
            }
            
        }else{
            ScrollView {
               LazyVGrid(columns: gridItems, spacing: 1) {
                   ReorderableForEach(viewModel.gridImages, active: $viewModel.currentlyDragging) { item in
                       SelectableImageItem(image: item, viewModel: viewModel)
                   } moveAction: {
                       from, to in
                       viewModel.gridImages.move(fromOffsets: from, toOffset: to)
                       viewModel.setOnChange(true)
                   } onEnd: {}
               }
           }
        }
    }

    struct SelectableImageItem: View {
        let image: SelectableImage
        @StateObject var viewModel: HomeViewModel
        var itemWidth: CGFloat {
            (UIScreen.main.bounds.width) / 3
        }

        var body: some View {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image.image).resizable()
                    .scaledToFill()
                    .frame(width: itemWidth, height: itemWidth).clipped().overlay(.white.opacity(viewModel.selectedImages.contains(image) ? 0.3 : 0)).onTapGesture {
                        if !viewModel.selectedImages.contains(image) {
                            viewModel.selectedImages.append(image)
                        } else {
                            viewModel.selectedImages.removeAll { $0.id == image.id }
                        }
                    }

                if viewModel.selectedImages.contains(image) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Circle())
                        .padding(8)
                }
                if viewModel.selectedImages.contains(image) {
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
