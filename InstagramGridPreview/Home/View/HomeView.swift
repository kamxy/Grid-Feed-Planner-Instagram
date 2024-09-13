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
                VStack {
                    TabBar(selectedTab: $selectedTab)
                    BodyView(selectedTab: $selectedTab, viewModel: viewModel)
                }
                BottomView(viewModel: viewModel)

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

struct BodyView: View {
    @Binding var selectedTab: Int
    @StateObject var viewModel: HomeViewModel
    var body: some View {
        TabView(selection: $selectedTab) {
            PhotosView(viewModel: viewModel)
                .tag(0)

            ReelsView().tag(1)
        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

struct FloatingButton: View {
    var action: () -> Void
    var image: String
    var color: Color
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: image).font(.title2).bold().foregroundColor(color)
        }.frame(width: 60, height: 60).background(.white).clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/).shadow()
            // 2
            .paddingAll()
    }
}
