//
//  HomeView.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 10.09.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var selectedImages: [UIImage] = []
    @State private var selectedTab = 0

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var itemWidth: CGFloat {
        (UIScreen.main.bounds.width) / 3 // Adjust for padding and spacing
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    TabBar(selectedTab: $selectedTab)

                    TabView(selection: $selectedTab) {
                        PhotosView(viewModel: viewModel)
                            .tag(0)

                        ReelsView().tag(1)
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }

                HStack {
                    if !viewModel.selectedImages.isEmpty {
                        Button {
                            viewModel.deleteImages()
                        } label: {
                            Image(systemName: "trash").font(.title2).bold().foregroundColor(.red)
                        }.frame(width: 60, height: 60).background(.white).clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).shadow(radius: 5)
                            // 2
                            .padding(.leading, 30).padding(.bottom, 10).sheet(isPresented: $viewModel.isGallerySheetPresented, onDismiss: {
                                viewModel.fetchImages()
                            }) {
                                GalleryView(isPresented: $viewModel.isGallerySheetPresented)
                            }
                    }
                    Spacer()
                    Button {
                        viewModel.isGallerySheetPresented.toggle()
                    } label: {
                        Image(systemName: "photo.badge.plus.fill").font(.title2).bold().foregroundColor(.black)
                    }.frame(width: 60, height: 60).background(.white).clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).shadow(radius: 5)
                        // 2
                        .padding(.trailing, 30).padding(.bottom, 10).sheet(isPresented: $viewModel.isGallerySheetPresented, onDismiss: {
                            viewModel.fetchImages()
                        }) {
                            GalleryView(isPresented: $viewModel.isGallerySheetPresented)
                        }
                }

            }.navigationTitle("Instagram Grid Preview")
        }
    }
}

#Preview {
    HomeView()
}

struct TabBar: View {
    private let tabs: [String] = ["photo", "video"]
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, item in
                TabButton(selectedTab: $selectedTab, image: item, tag: index)
            }
        }
    }
}

struct TabButton: View {
    @Binding var selectedTab: Int
    let image: String
    let tag: Int

    var body: some View {
        Button(action: {
            selectedTab = tag
        }, label: {
            Image(systemName: image).frame(maxWidth: .infinity, maxHeight: 60).foregroundColor(selectedTab == tag ? .blue : .gray)
        })
    }
}
