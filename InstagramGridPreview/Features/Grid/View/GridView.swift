import PhotosUI
import SwiftUI

struct GridView: View {
    @StateObject private var viewModel = GridViewModel()
    @StateObject private var profileService = UserProfileService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
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
    @State private var gridOptions = GridExportService.ExportOptions()
    @State private var showingProfileEdit = false
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(gridItemSize), spacing: gridSpacing), count: gridColumns)
    }
    
    private var gridItemSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = gridSpacing * CGFloat(gridColumns - 1)
        let availableWidth = screenWidth - totalSpacing - (gridSpacing * 2)
        return availableWidth / CGFloat(gridColumns)
    }
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let exportService = GridExportService()
    private let appReviewService = AppReviewService.shared
    
    var body: some View {
        GeometryReader { _ in
            NavigationStack {
                ZStack {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Profile Header
                            GridProfileHeaderView(
                                username: profileService.profile.username,
                                profileImage: profileService.profile.profileImage
                            )
                            .onTapGesture {
                                showingProfileEdit = true
                            }
                            
                            if viewModel.images.isEmpty && !isLoading {
                                VStack(spacing: 20) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("grid.noPhotos.message".localized)
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text("grid.noPhotos.description".localized)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.vertical, 100)
                            } else {
                                LazyVGrid(columns: columns, spacing: gridSpacing) {
                                    ForEach(viewModel.images.indices, id: \.self) { index in
                                        if let image = viewModel.images[index] {
                                            GridItemCell(
                                                image: image,
                                                isSelected: selectedIndices.contains(index),
                                                isEditMode: isEditMode,
                                                isDragged: draggedItem == index,
                                                size: gridItemSize,
                                                onTap: {
                                                    handleImageTap(at: index, image: image)
                                                }
                                            )
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
                                        }
                                    }
                                }
                                .padding(gridSpacing)
                                .animation(.default, value: viewModel.images)
                            }
                        }
                    }
                    
                    if isLoading {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                    // Floating Action Button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            PhotosPicker(selection: $selectedItem,
                                         matching: .images)
                            {
                                Image(systemName: "plus")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.appPink)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                    .scaleEffect(isEditMode ? 0 : 1)
                                    .rotationEffect(isEditMode ? .degrees(-90) : .degrees(0))
                                    .opacity(isEditMode ? 0 : 1)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isEditMode)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, isEditMode ? 0 : 20)
                        }
                    }
                }
                .navigationTitle("grid.title".localized)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            if !isEditMode {
                                Button {
                                    showingExportOptions = true
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.appPink)
                                }
                                .disabled(viewModel.images.isEmpty)
                                
                                Button {
                                    if subscriptionService.canAccessGridCustomization() {
                                        showingGridSettings = true
                                    } else {
                                        subscriptionService.showPaywallIfNeeded(for: .gridCustomization)
                                    }
                                } label: {
                                    Image(systemName: "square.grid.3x3")
                                        .foregroundColor(.appPink)
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
                                Text(isEditMode ? "alert.cancel".localized : "grid.edit".localized)
                                    .foregroundColor(isEditMode ? .red : .appPink)
                            }
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
                                Text(selectedIndices.isEmpty ? "grid.selectAll".localized : "grid.deselectAll".localized)
                                    .foregroundColor(selectedIndices.isEmpty ? .appPink : .red)
                            }
                        }
                        
                        if !selectedIndices.isEmpty {
                            ToolbarItem(placement: .bottomBar) {
                                HStack {
                                    Button(role: .destructive) {
                                        deleteSelectedImages()
                                    } label: {
                                        Label("grid.deleteSelected".localized, systemImage: "trash")
                                            .foregroundColor(.red)
                                    }
                                    
                                    if selectedIndices.count == 1 {
                                        Spacer()
                                        Button {
                                            if let index = selectedIndices.first,
                                               let image = viewModel.images[index]
                                            {
                                                selectedImage = SelectedImage(index: index, image: image)
                                            }
                                        } label: {
                                            Label("grid.edit".localized, systemImage: "slider.horizontal.3")
                                                .foregroundColor(.appPink)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .confirmationDialog("export.grid".localized, isPresented: $showingExportOptions) {
                    Button("export.saveToPhotos".localized) {
                        exportGrid { image in
                            exportService.saveToPhotos(image) { error in
                                if let error = error {
                                    errorMessage = error.localizedDescription
                                    showingError = true
                                }
                            }
                        }
                    }
                    
                    Button("export.copyToClipboard".localized) {
                        exportGrid { image in
                            exportService.copyToClipboard(image)
                        }
                    }
                    
                    Button("export.shareToInstagram".localized) {
                        exportGrid { image in
                            exportedImage = image
                            showingShareSheet = true
                        }
                    }
                    
                    Button("alert.cancel".localized, role: .cancel) {}
                }
                .sheet(item: $selectedImage, onDismiss: {
                    selectedImage = nil
                    selectedIndices.removeAll()
                    isEditMode = false
                }) { selected in
                    ImageEditorView(image: selected.image) { editedImage in
                        Task {
                            viewModel.updateImage(editedImage, at: selected.id)
                            selectedImage = nil
                            selectedIndices.removeAll()
                            isEditMode = false
                        }
                    }
                }
                .sheet(isPresented: $showingGridSettings) {
                    GridSettingsView(
                        gridColumns: $gridColumns,
                        gridSpacing: $gridSpacing,
                        onApply: { options in
                            gridOptions = options
                        },
                        previewImages: viewModel.images.compactMap { $0 }
                    )
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let image = exportedImage {
                        ShareSheet(items: [image])
                    }
                }
                .alert("export.failed".localized, isPresented: $showingError) {
                    Button("alert.ok".localized) {}
                } message: {
                    Text(errorMessage)
                }
                .onChange(of: selectedItem) { newItem in
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
                                appReviewService.incrementSignificantActions()
                            } else {
                                errorMessage = "export.failed".localized
                            }
                        } catch {
                            errorMessage = "export.failed".localized
                        }
                        isLoading = false
                    }
                }
                .sheet(isPresented: $showingProfileEdit) {
                    ProfileEditView(
                        username: profileService.profile.username,
                        profileImage: profileService.profile.profileImage,
                        onSave: { username, image in
                            if !username.isEmpty {
                                profileService.updateUsername(username)
                            }
                            profileService.updateProfileImage(image)
                        }
                    )
                }
                .sheet(isPresented: $subscriptionService.showingPaywall) {
                    PaywallView()
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
            isEditMode = false
            isLoading = false
        }
    }
    
    private func exportGrid(completion: @escaping (UIImage) -> Void) {
        do {
            let exportedImage = try exportService.exportGrid(
                images: viewModel.images.compactMap { $0 },
                columns: gridColumns,
                options: gridOptions
            )
            completion(exportedImage)
            appReviewService.incrementSignificantActions()
        } catch {
            errorMessage = "export.failed".localized
            showingError = true
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: Int
    @Binding var draggedItem: Int?
    let viewModel: GridViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = draggedItem else { return false }
        viewModel.moveImage(from: draggedItem, to: item)
        self.draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
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
