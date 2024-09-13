//
//  GalleryView.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 10.09.2024.
//

import SwiftUI

struct GalleryView: View {
    @Binding var isPresented: Bool
    @StateObject var viewModel = GalleryViewModel()
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                Button(action: {
                    isPresented.toggle()

                }, label: {
                    Text("Dismiss")
                }).padding()
                Text("Select images for your Grid").padding().bold()
                ScrollView {
                    if viewModel.galleryImages.isEmpty {
                        ProgressView().controlSize(.large)
                    } else {
                        LazyVGrid(columns: gridItems, spacing: 1) {
                            ForEach($viewModel.galleryImages) { image in
                                SelectableImageItem(image: image, viewModel: viewModel)
                            }
                        }
                    }
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    viewModel.insertNewItemsAsFirst()
                    isPresented.toggle()
                }, label: {
                    if !viewModel.selectedImages.isEmpty {
                        Image(systemName: "checkmark").foregroundColor(.black).frame(minHeight: 60).padding(20).background(.white).clipShape(Circle()).shadow(radius: 6).padding(.trailing, 16)
                    }
                })
            }
        }.sheet(isPresented: $viewModel.isImagePickerPresented, onDismiss: {}) {
            ImagePicker(selectedImages: $viewModel.imagesFromGallery).onDisappear {
                viewModel.saveImages()
            }
        }
    }

    struct SelectableImageItem: View {
        @Binding var image: SelectableImage
        @StateObject var viewModel: GalleryViewModel
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
                            print("append")
                        } else {
                            viewModel.selectedImages.removeAll { $0.id == image.id }
                            print("remove")
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
