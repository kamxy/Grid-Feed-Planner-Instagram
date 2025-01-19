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
    @State private var isEditMode = false
    @State private var animateSelection = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    if viewModel.images.isEmpty && !isLoading {
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No Images")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Tap + to add your first image")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 100)
                    } else {
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(viewModel.images.indices, id: \.self) { index in
                                if let image = viewModel.images[index] {
                                    Button(action: {
                                        handleImageTap(at: index, image: image)
                                    }) {
                                        ZStack(alignment: .topTrailing) {
                                            GridItemView(image: image)
                                                .opacity(draggedItem == index ? 0.5 : 1.0)
                                                .onDrag {
                                                    if !isEditMode {
                                                        draggedItem = index
                                                        return NSItemProvider(object: "\(index)" as NSString)
                                                    }
                                                    return NSItemProvider()
                                                }
                                                .onDrop(of: [.text], delegate: !isEditMode ? DropViewDelegate(item: index,
                                                                                              draggedItem: $draggedItem,
                                                                                              viewModel: viewModel) : NoOpDropDelegate())
                                                .scaleEffect(selectedIndices.contains(index) ? 0.95 : 1.0)
                                                .animation(.spring(response: 0.3), value: selectedIndices.contains(index))
                                            
                                            if isEditMode {
                                                Image(systemName: selectedIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                                                    .font(.title2)
                                                    .foregroundColor(selectedIndices.contains(index) ? .blue : .white)
                                                    .background(Circle().fill(Color.white.opacity(0.8)))
                                                    .padding(4)
                                                    .zIndex(1)
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .contentShape(Rectangle())
                                } else {
                                  }
                            }
                            
                            PhotosPicker(selection: $selectedItem,
                                       matching: .images)
                            {
                                AddPhotoButton()
                            }
                        }
                        .padding(1)
                        .animation(.default, value: viewModel.images)
                    }
                }
                
                if isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .navigationTitle("Grid Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                isEditMode.toggle()
                                if !isEditMode {
                                    selectedIndices.removeAll()
                                }
                            }
                        } label: {
                            Text(isEditMode ? "Done" : "Edit")
                        }
                        
                        Button {
                            showingScheduleSheet = true
                        } label: {
                            Image(systemName: "calendar.badge.plus")
                        }
                        .opacity(isEditMode ? 0 : 1)
                        .animation(.easeInOut, value: isEditMode)
                    }
                }
                
                if isEditMode {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if selectedIndices.isEmpty {
                            Text("Select Items")
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(selectedIndices.count) Selected")
                                .bold()
                        }
                    }
                }
                
                if !selectedIndices.isEmpty && isEditMode {
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
                isEditMode = false
            }) { selected in
                ImageEditorView(image: selected.image) { editedImage in
                    viewModel.updateImage(editedImage, at: selected.id)
                }
            }
            .sheet(isPresented: $showingScheduleSheet) {
                CalendarView()
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    isLoading = true
                    do {
                        if let data = try await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await viewModel.addImage(image)
                            errorMessage = nil
                        } else {
                            errorMessage = "Failed to load image"
                        }
                    } catch {
                        errorMessage = "Error loading image: \(error.localizedDescription)"
                    }
                    isLoading = false
                }
            }
            .alert("Error", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func handleImageTap(at index: Int, image: UIImage) {
        if isEditMode {
            hapticFeedback.impactOccurred()
            withAnimation(.spring(response: 0.3)) {
                if selectedIndices.contains(index) {
                    selectedIndices.remove(index)
                } else {
                    selectedIndices.insert(index)
                }
            }
        } else {
            selectedImage = SelectedImage(index: index, image: image)
        }
    }
    
    private func deleteSelectedImages() {
        withAnimation {
            isLoading = true
            // Sort indices in descending order to avoid index shifting issues
            let sortedIndices = selectedIndices.sorted(by: >)
            for index in sortedIndices {
                viewModel.removeImage(at: index)
            }
            selectedIndices.removeAll()
            isLoading = false
        }
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

struct NoOpDropDelegate: DropDelegate {
    func performDrop(info: DropInfo) -> Bool { false }
}

// MARK: - Preview

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}
