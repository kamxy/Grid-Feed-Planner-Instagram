import SwiftUI

enum ImageFilter: String, CaseIterable {
    case none = "Original"
    case mono = "B&W"
    case sepia = "Sepia"
    case vibrant = "Vibrant"
    case fade = "Fade"
}

struct EditHistory {
    var image: UIImage
    var brightness: Double
    var contrast: Double
    var filter: ImageFilter
    var cropRect: CGRect?
}

struct ImageEditorView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var editedImage: UIImage
    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var selectedFilter: ImageFilter = .none
    @State private var isCropping: Bool = false
    @State private var cropRect: CGRect?
    @State private var history: [EditHistory] = []
    @State private var historyIndex: Int = -1
    @State private var selectedTab: Int = 0
    @StateObject private var subscriptionService = SubscriptionService.shared

    init(image: UIImage, onSave: @escaping (UIImage) -> Void) {
        self.image = image
        self.onSave = onSave
        _editedImage = State(initialValue: image)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        Image(uiImage: editedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width)
                            .brightness(brightness)
                            .contrast(contrast)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .overlay(
                                Group {
                                    if isCropping {
                                        CropOverlay(cropRect: $cropRect)
                                    }
                                }
                            )
                    }
                    
                    TabView(selection: $selectedTab) {
                        // Adjustments Tab
                        VStack(spacing: 20) {
                            VStack {
                                Text("Brightness")
                                Slider(value: $brightness, in: -1...1) { _ in
                                    addToHistory()
                                }.foregroundStyle(Color.appPink)
                            }
                            
                            VStack {
                                Text("Contrast")
                                Slider(value: $contrast, in: 0.5...1.5) { _ in
                                    addToHistory()
                                }
                            }
                        }
                        .padding()
                        .tabItem {
                            Label("Adjust", systemImage: "slider.horizontal.3")
                        }
                        .tag(0)
                        
                        // Filters Tab
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(ImageFilter.allCases, id: \.self) { filter in
                                    VStack {
                                        let filteredImage = applyFilter(filter, to: image)
                                        Image(uiImage: filteredImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(filter == selectedFilter ? Color.blue : Color.clear, lineWidth: 2)
                                            )
                                        Text(filter.rawValue)
                                            .font(.caption)
                                    }
                                    .onTapGesture {
                                        selectedFilter = filter
                                        editedImage = applyFilter(filter, to: editedImage)
                                        addToHistory()
                                    }
                                }
                            }
                            .padding()
                        }
                        .tabItem {
                            Label("Filters", systemImage: "camera.filters")
                        }
                        .tag(1)
                    }
                    .background(.ultraThinMaterial)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }.foregroundStyle(Color.appPink)
                        
                        if !history.isEmpty {
                            Button {
                                undo()
                            } label: {
                                Image(systemName: "arrow.uturn.backward")
                            }.foregroundStyle(Color.appPink)
                                .disabled(historyIndex <= 0)
                            
                            Button {
                                redo()
                            } label: {
                                Image(systemName: "arrow.uturn.forward")
                            }.foregroundStyle(Color.appPink)
                                .disabled(historyIndex >= history.count - 1)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            isCropping.toggle()
                        } label: {
                            Image(systemName: isCropping ? "checkmark" : "crop")
                        }.foregroundStyle(Color.appPink)
                        
                        Button("Save") {
                            if subscriptionService.isPremium {
                                if let editedImage = applyEdits() {
                                    onSave(editedImage)
                                    dismiss()
                                }
                            } else {
                                subscriptionService.showPaywallIfNeeded(for: .imageEditing)
                            }
                        }.foregroundStyle(Color.appPink)
                    }
                }
            }
        }
    }
    
    private func addToHistory() {
        // Remove any redo history if we're not at the end
        if historyIndex < history.count - 1 {
            history.removeSubrange((historyIndex + 1)...)
        }
        
        // Add current state to history
        let currentState = EditHistory(
            image: editedImage,
            brightness: brightness,
            contrast: contrast,
            filter: selectedFilter,
            cropRect: cropRect
        )
        history.append(currentState)
        historyIndex = history.count - 1
    }
    
    private func undo() {
        guard historyIndex > 0 else { return }
        historyIndex -= 1
        applyHistoryState(history[historyIndex])
    }
    
    private func redo() {
        guard historyIndex < history.count - 1 else { return }
        historyIndex += 1
        applyHistoryState(history[historyIndex])
    }
    
    private func applyHistoryState(_ state: EditHistory) {
        editedImage = state.image
        brightness = state.brightness
        contrast = state.contrast
        selectedFilter = state.filter
        cropRect = state.cropRect
    }
    
    private func applyFilter(_ filter: ImageFilter, to image: UIImage) -> UIImage {
        let context = CIContext()
        
        // Convert UIImage to optional CIImage
        let ciImage = CIImage(image: image)
        guard let inputImage = ciImage else { return image }
        
        switch filter {
        case .none:
            return image

        case .mono:
            guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return image }
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            guard let outputImage = filter.outputImage,
                  let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            else {
                return image
            }
            return UIImage(cgImage: cgImage)
            
        case .sepia:
            guard let filter = CIFilter(name: "CISepiaTone") else { return image }
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            filter.setValue(0.8, forKey: kCIInputIntensityKey)
            guard let outputImage = filter.outputImage,
                  let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            else {
                return image
            }
            return UIImage(cgImage: cgImage)
            
        case .vibrant:
            guard let filter = CIFilter(name: "CIVibrance") else { return image }
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputAmountKey)
            guard let outputImage = filter.outputImage,
                  let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            else {
                return image
            }
            return UIImage(cgImage: cgImage)
            
        case .fade:
            guard let filter = CIFilter(name: "CIPhotoEffectFade") else { return image }
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            guard let outputImage = filter.outputImage,
                  let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            else {
                return image
            }
            return UIImage(cgImage: cgImage)
        }
    }
    
    private func applyEdits() -> UIImage? {
        let context = CIContext()
        
        // Convert UIImage to optional CIImage
        let ciImage = CIImage(image: editedImage)
        guard let currentImage = ciImage else { return nil }
        
        var processedImage = currentImage
        
        // Apply adjustments
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(processedImage, forKey: kCIInputImageKey)
            colorControls.setValue(brightness, forKey: kCIInputBrightnessKey)
            colorControls.setValue(contrast, forKey: kCIInputContrastKey)
            
            if let outputImage = colorControls.outputImage {
                processedImage = outputImage
            }
        }
        
        // Apply crop if needed
        if let cropRect = cropRect {
            processedImage = processedImage.cropped(to: cropRect)
        }
        
        // Convert back to UIImage
        guard let outputCGImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
}

struct CropOverlay: View {
    @Binding var cropRect: CGRect?
    
    var body: some View {
        GeometryReader { geometry in
            if let rect = cropRect {
                Path { path in
                    // Draw the outer rectangle
                    path.addRect(CGRect(origin: .zero, size: geometry.size))
                    // Cut out the inner rectangle
                    path.addRect(rect)
                }
                .fill(Color.black.opacity(0.5))
                .allowsHitTesting(false)
                
                // Draw the crop rectangle border
                Rectangle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    cropRect = CGRect(
                        x: value.startLocation.x,
                        y: value.startLocation.y,
                        width: value.translation.width,
                        height: value.translation.height
                    )
                }
        )
    }
}
