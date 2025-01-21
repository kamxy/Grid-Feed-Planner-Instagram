import PhotosUI
import SwiftUI

struct ReelsView: View {
    @StateObject private var viewModel = ReelsViewModel()
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var draggedItem: Int?
    @State private var selectedImage: SelectedImage?
    @State private var selectedIndices: Set<Int> = []
    @State private var isEditMode = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ReelsContentView(
            viewModel: viewModel,
            isLoading: isLoading,
            isEditMode: isEditMode,
            selectedIndices: selectedIndices,
            draggedItem: draggedItem,
            onImageTap: handleImageTap,
            onDragStarted: { index in
                if !isEditMode {
                    draggedItem = index
                    return NSItemProvider(object: "\(index)" as NSString)
                }
                return NSItemProvider()
            }
        )
        .overlay(loadingOverlay)
        .overlay(addButton, alignment: .bottomTrailing)
        .toolbar { toolbarContent }
        .onChange(of: selectedItem, perform: handleSelectedItem)
        .alert("Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .sheet(item: $selectedImage) { selected in
            ImageEditorView(image: selected.image) { editedImage in
                Task {
                    viewModel.updateImage(editedImage, at: selected.id)
                    selectedImage = nil
                    selectedIndices.removeAll()
                    isEditMode = false
                }
            }
        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                )
        }
    }
    
    @ViewBuilder
    private var addButton: some View {
        if !isEditMode {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.appPink)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isEditMode.toggle()
                    if !isEditMode {
                        selectedIndices.removeAll()
                    }
                }
            } label: {
                Text(isEditMode ? "Cancel" : "Edit")
                    .foregroundColor(isEditMode ? .red : .appPink)
            }
        }
        
        if isEditMode {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        if selectedIndices.count == viewModel.images.count {
                            selectedIndices.removeAll()
                        } else {
                            selectedIndices = Set(viewModel.images.indices)
                        }
                    }
                } label: {
                    Text(selectedIndices.isEmpty ? "Select All" : "Deselect All")
                        .foregroundColor(selectedIndices.isEmpty ? .appPink : .red)
                }
            }
            
            if !selectedIndices.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        deleteSelectedImages()
                    } label: {
                        Label("Delete Selected", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func handleSelectedItem(_ newItem: PhotosPickerItem?) {
        Task {
            if !subscriptionService.canAddMorePhotos(currentCount: viewModel.images.count) {
                subscriptionService.showPaywallIfNeeded(for: .unlimitedPhotos)
                selectedItem = nil
                return
            }
            
            isLoading = true
            do {
                if let data = try await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data)
                {
                    await viewModel.addImage(image)
                    errorMessage = ""
                } else {
                    errorMessage = "Failed to load image"
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
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
            let sortedIndices = selectedIndices.sorted(by: >)
            for index in sortedIndices {
                viewModel.removeImage(at: index)
            }
            selectedIndices.removeAll()
            isEditMode = false
            isLoading = false
        }
    }
}

struct ReelsContentView: View {
    let viewModel: ReelsViewModel
    let isLoading: Bool
    let isEditMode: Bool
    let selectedIndices: Set<Int>
    let draggedItem: Int?
    let onImageTap: (Int, UIImage) -> Void
    let onDragStarted: (Int) -> NSItemProvider
    
    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        ZStack {
            if viewModel.images.isEmpty && !isLoading {
                EmptyReelsView()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(viewModel.images.indices, id: \.self) { index in
                            if let image = viewModel.images[index] {
                                ReelItemCell(
                                    image: image,
                                    isSelected: selectedIndices.contains(index),
                                    isEditMode: isEditMode,
                                    isDragged: draggedItem == index,
                                    onTap: { onImageTap(index, image) }
                                )
                                .onDrag { onDragStarted(index) }
                                .onDrop(of: [.text], delegate: !isEditMode ? ReelsDropViewDelegate(item: index,
                                                                                          draggedItem: .constant(draggedItem),
                                                                                          viewModel: viewModel) : NoOpDropDelegate())
                            }
                        }
                    }
                }
            }
        }
    }
}

struct EmptyReelsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Reels")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Tap + to add photos to your reels")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ReelItemCell: View {
    let image: UIImage
    let isSelected: Bool
    let isEditMode: Bool
    let isDragged: Bool
    let onTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: onTap) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width)
                        .frame(height: geometry.size.width * (16/9))
                        .clipped()
                        .opacity(isDragged ? 0.5 : 1.0)
                        .scaleEffect(isSelected ? 0.98 : 1.0)
                        .animation(.spring(response: 0.3), value: isSelected)
                    
                    if isEditMode {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(isSelected ? .appPink : .white)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                            .padding(8)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
        }
        .aspectRatio(9/16, contentMode: .fit)
    }
}

struct ReelsDropViewDelegate: DropDelegate {
    let item: Int
    @Binding var draggedItem: Int?
    let viewModel: ReelsViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem else { return false }
        
        if draggedItem != item {
            let from = draggedItem
            let to = item
            
            viewModel.moveImage(from: from, to: to)
        }
        
        self.draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else { return }
        
        if draggedItem != item {
            let from = draggedItem
            let to = item
            
            if from != to {
                viewModel.moveImage(from: from, to: to)
                self.draggedItem = item
            }
        }
    }
}

// MARK: - Preview
struct ReelsView_Previews: PreviewProvider {
    static var previews: some View {
        ReelsView()
    }
}
