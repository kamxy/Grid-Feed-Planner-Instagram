import PhotosUI
import SwiftUI

struct GridView: View {
    @StateObject private var viewModel = GridViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var draggedItem: Int?
    @State private var selectedImage: SelectedImage?
    @State private var selectedIndices: Set<Int> = []
    @State private var showingActionSheet = false
    @State private var showingScheduleSheet = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(viewModel.images.indices, id: \.self) { index in
                        if let image = viewModel.images[index] {
                            ZStack(alignment: .topTrailing) {
                                GridItemView(image: image)
                                    .onTapGesture {
                                        handleImageTap(at: index, image: image)
                                    }
                                    .opacity(draggedItem == index ? 0.5 : 1.0)
                                    .onDrag {
                                        draggedItem = index
                                        return NSItemProvider(object: "\(index)" as NSString)
                                    }
                                    .onDrop(of: [.text], delegate: DropViewDelegate(item: index,
                                                                                  draggedItem: $draggedItem,
                                                                                  viewModel: viewModel))
                                
                                if selectedIndices.contains(index) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .background(Circle().fill(Color.white))
                                        .padding(4)
                                }
                            }
                        } else {
                            Color.gray.opacity(0.2)
                                .onDrop(of: [.text], delegate: DropViewDelegate(item: index,
                                                                              draggedItem: $draggedItem,
                                                                              viewModel: viewModel))
                        }
                    }
                    
                    PhotosPicker(selection: $selectedItem,
                               matching: .images)
                    {
                        AddPhotoButton()
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data)
                            {
                                await viewModel.addImage(image)
                            }
                        }
                    }
                }
                .padding(1)
                .animation(.default, value: viewModel.images)
            }
            .navigationTitle("Grid Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingScheduleSheet = true
                    } label: {
                        Image(systemName: "calendar.badge.plus")
                    }
                }
                
                if !selectedIndices.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(role: .destructive) {
                                deleteSelectedImages()
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            
                            if selectedIndices.count == 1 {
                                Spacer()
                                Button {
                                    if let index = selectedIndices.first,
                                       let image = viewModel.images[index] {
                                        selectedImage = SelectedImage(index: index, image: image)
                                    }
                                } label: {
                                    Label("Edit", systemImage: "slider.horizontal.3")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .sheet(item: $selectedImage, onDismiss: { 
                selectedImage = nil
                selectedIndices.removeAll()
            }) { selected in
                ImageEditorView(image: selected.image) { editedImage in
                    viewModel.updateImage(editedImage, at: selected.id)
                }
            }
            .sheet(isPresented: $showingScheduleSheet) {
                CalendarView()
            }
        }
    }
    
    private func handleImageTap(at index: Int, image: UIImage) {
        if selectedIndices.isEmpty {
            // First selection, show edit options
            selectedImage = SelectedImage(index: index, image: image)
        } else {
            // Toggle selection in multi-select mode
            if selectedIndices.contains(index) {
                selectedIndices.remove(index)
            } else {
                selectedIndices.insert(index)
            }
        }
    }
    
    private func deleteSelectedImages() {
        // Sort indices in descending order to avoid index shifting issues
        let sortedIndices = selectedIndices.sorted(by: >)
        for index in sortedIndices {
            viewModel.removeImage(at: index)
        }
        selectedIndices.removeAll()
    }
}

struct DropViewDelegate: DropDelegate {
    let item: Int
    @Binding var draggedItem: Int?
    let viewModel: GridViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem else { return false }
        viewModel.moveImage(from: draggedItem, to: item)
        self.draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem,
              draggedItem != item else { return }
        viewModel.moveImage(from: draggedItem, to: item)
        self.draggedItem = item
    }
}

// MARK: - Preview

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}
