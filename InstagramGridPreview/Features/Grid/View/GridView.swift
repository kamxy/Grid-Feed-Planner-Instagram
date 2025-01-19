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
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var exportedImage: UIImage?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var animateSelection = false
    @State private var isLoading = false
    @State private var gridSpacing: CGFloat = 1
    @State private var gridColumns = 3
    @State private var showingGridSettings = false
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: gridColumns)
    }
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let exportService = GridExportService()
    
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
                        if !isEditMode {
                            Button {
                                showingExportOptions = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .disabled(viewModel.images.isEmpty)
                            
                            Button {
                                showingGridSettings = true
                            } label: {
                                Image(systemName: "square.grid.3x3")
                            }
                        }
                        
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
            .confirmationDialog("Export Grid", isPresented: $showingExportOptions) {
                Button("Save to Photos") {
                    exportGrid { image in
                        exportService.saveToPhotos(image) { error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                                showingError = true
                            }
                        }
                    }
                }
                
                Button("Copy to Clipboard") {
                    exportGrid { image in
                        exportService.copyToClipboard(image)
                    }
                }
                
                Button("Share...") {
                    exportGrid { image in
                        exportedImage = image
                        showingShareSheet = true
                    }
                }
                
                Button("Cancel", role: .cancel) {}
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
            .sheet(isPresented: $showingGridSettings) {
                NavigationStack {
                    Form {
                        Section("Grid Layout") {
                            Picker("Columns", selection: $gridColumns) {
                                Text("3 x 3").tag(3)
                                Text("4 x 4").tag(4)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Section("Grid Spacing") {
                            Slider(value: $gridSpacing, in: 0...10, step: 1) {
                                Text("Spacing")
                            } minimumValueLabel: {
                                Text("0")
                            } maximumValueLabel: {
                                Text("10")
                            }
                        }
                    }
                    .navigationTitle("Grid Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingGridSettings = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = exportedImage {
                    ShareSheet(items: [image])
                }
            }
            .alert("Export Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    isLoading = true
                    do {
                        if let data = try await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await viewModel.addImage(image)
                            errorMessage = ""
                        } else {
                            errorMessage = "Failed to load image"
                        }
                    } catch {
                        errorMessage = "Error loading image: \(error.localizedDescription)"
                    }
                    isLoading = false
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
    
    private func exportGrid(completion: @escaping (UIImage) -> Void) {
        do {
            let options = GridExportService.ExportOptions(
                spacing: gridSpacing,
                backgroundColor: .white,
                borderWidth: 0,
                padding: 0
            )
            
            let exportedImage = try exportService.exportGrid(
                images: viewModel.images.compactMap { $0 },
                columns: gridColumns,
                options: options
            )
            
            completion(exportedImage)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
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

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}
