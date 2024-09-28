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

    var itemWidth: CGFloat {
        (UIScreen.main.bounds.width) / 3
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    HStack {
                        Image("appIcon").resizable()
                            .scaledToFill().frame(width: 50, height: 50).paddingAll()
                        Text("Grid: ").font(.title).bold() + Text("Preview Your Profile").bold().font(.title3)
                    }
//                    TabBar(selectedTab: $selectedTab)
                    BodyView(selectedTab: $selectedTab, viewModel: viewModel)
                }
                BottomView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    HomeView()
}

struct TabBar: View {
    private let tabs: [String] = ["photo" /* , "video" */ ]
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
            Image(systemName: image).frame(maxWidth: .infinity, maxHeight: 60).foregroundColor(selectedTab == tag ? .black : .gray)
        })
    }
}

struct BottomView: View {
    @StateObject var viewModel: HomeViewModel
    var body: some View {
        HStack {
            if !viewModel.selectedImages.isEmpty {
                FloatingButton(action: {
                    viewModel.deleteImages()
                }, image: "trash", color: .red)
            }

            Spacer()

            Spacer()
            if viewModel.onChanged {
                Button(action: {
                    viewModel.reoder()
                    viewModel.setOnChange(false)
                }, label: {
                    Text("Save Order").font(.title3).foregroundStyle(.black).paddingAll()
                }).background(.white)
                    .cornerRadius(20).shadow().paddingAll()
            } else {
                FloatingButton(action: {
                    viewModel.isGallerySheetPresented.toggle()
                }, image: "photo.badge.plus.fill", color: .black).sheet(isPresented: $viewModel.isGallerySheetPresented, onDismiss: {
                    viewModel.fetchImages()
                }) {
                    GalleryView(isPresented: $viewModel.isGallerySheetPresented)
                }
            }
        }
    }
}

struct BodyView: View {
    @Binding var selectedTab: Int
    @StateObject var viewModel: HomeViewModel
    var body: some View {
        TabView(selection: $selectedTab) {
            PhotosView(viewModel: viewModel)
                .tag(0)

//            ReelsView().tag(1)
        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

struct FloatingButton: View {
    var action: () -> Void
    var image: String?
    var text: String?
    var color: Color
    var body: some View {
        Button {
            action()
        } label: {
            if let text {
                Text(text)
            } else {}
            Image(systemName: image!).font(.title2).bold().foregroundColor(color)

        }.frame(width: 60, height: 60).background(.white).clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).shadow()
            // 2
            .paddingAll()
    }
}
