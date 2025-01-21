import SwiftUI
import PhotosUI

struct StoryHighlightView: View {
    @StateObject private var viewModel = StoryHighlightViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingTitleAlert = false
    @State private var newHighlightTitle = ""
    @State private var tempImage: UIImage?
    @State private var showingPhotoPicker = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Add New Button
                PhotosPicker(selection: $selectedItem,
                           matching: .images,
                           photoLibrary: .shared()) {
                    StoryHighlightCell(highlight: .addNew)
                }
                
                // Existing Highlights
                ForEach(viewModel.highlights) { highlight in
                    StoryHighlightCell(highlight: highlight)
                        .onTapGesture {
                            // Handle tap on existing highlight
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                if let index = viewModel.highlights.firstIndex(where: { $0.id == highlight.id }) {
                                    Task {
                                        await viewModel.removeHighlight(at: index)
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                // Edit highlight
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .onChange(of: selectedItem) { newItem in
            if let newItem {
                handleSelectedItem(newItem)
            }
        }
        .alert("Add Story Highlight", isPresented: $showingTitleAlert) {
            TextField("Title", text: $newHighlightTitle)
            Button("Cancel", role: .cancel) {
                tempImage = nil
                newHighlightTitle = ""
            }
            Button("Add") {
                if let image = tempImage {
                    Task {
                        await viewModel.addHighlight(title: newHighlightTitle, image: image)
                        tempImage = nil
                        newHighlightTitle = ""
                    }
                }
            }
        }
    }
    
    private func handleSelectedItem(_ item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                tempImage = image
                showingTitleAlert = true
            }
            selectedItem = nil
        }
    }
}

struct StoryHighlightCell: View {
    let highlight: StoryHighlight
    private let size: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: size, height: size)
                
                if highlight.isAdd {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.appPink)
                } else {
                    Image(uiImage: highlight.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size - 4, height: size - 4)
                        .clipShape(Circle())
                }
            }
            
            Text(highlight.title)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
}

#Preview {
    StoryHighlightView()
} 