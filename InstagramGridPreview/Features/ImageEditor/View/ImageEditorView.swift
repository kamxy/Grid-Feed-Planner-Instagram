import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ImageEditorView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var editedImage: UIImage?
    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1
    @State private var selectedFilter: ImageFilter = .none
    @State private var filterIntensity: Double = 1
    
    private let context = CIContext()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image Preview
                GeometryReader { geometry in
                    ScrollView {
                        if let editedImage = editedImage {
                            Image(uiImage: editedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width)
                        } else {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width)
                        }
                    }
                }
                
                // Editing Controls
                VStack(spacing: 16) {
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ImageFilter.allCases) { filter in
                                FilterButton(
                                    filter: filter,
                                    isSelected: selectedFilter == filter,
                                    isPremium: false
                                ) {
                                    selectedFilter = filter
                                    applyEdits()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Adjustments
                    VStack(spacing: 12) {
                        // Brightness
                        HStack {
                            Image(systemName: "sun.max")
                            Slider(value: $brightness, in: -0.5...0.5) { _ in
                                applyEdits()
                            }
                        }
                        
                        // Contrast
                        HStack {
                            Image(systemName: "circle.lefthalf.filled")
                            Slider(value: $contrast, in: 0.5...1.5) { _ in
                                applyEdits()
                            }
                        }
                        
                        // Saturation
                        HStack {
                            Image(systemName: "paintpalette")
                            Slider(value: $saturation, in: 0...2) { _ in
                                applyEdits()
                            }
                        }
                        
                        if !subscriptionService.isPremium {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Upgrade to save your edits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .onTapGesture {
                                subscriptionService.showPaywallIfNeeded(for: .imageEditing)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Edit Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if subscriptionService.isPremium {
                            if let editedImage = editedImage {
                                onSave(editedImage)
                            } else {
                                onSave(image)
                            }
                            dismiss()
                        } else {
                            dismiss()
                            subscriptionService.showPaywallIfNeeded(for: .imageEditing)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if !subscriptionService.isPremium {
                                Image(systemName: "crown.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                            }
                            Text("Save")
                        }
                    }
                }
            }
        }
    }
    
    private func applyEdits() {
        guard let ciImage = CIImage(image: image) else { return }
        
        var currentImage = ciImage
        
        // Apply basic adjustments
        if brightness != 0 || contrast != 1 || saturation != 1 {
            let filter = CIFilter.colorControls()
            filter.inputImage = currentImage
            filter.brightness = Float(brightness)
            filter.contrast = Float(contrast)
            filter.saturation = Float(saturation)
            if let outputImage = filter.outputImage {
                currentImage = outputImage
            }
        }
        
        // Apply selected filter
        if selectedFilter != .none {
            if let filterOutput = selectedFilter.apply(to: currentImage, intensity: filterIntensity) {
                currentImage = filterOutput
            }
        }
        
        // Convert back to UIImage
        if let cgImage = context.createCGImage(currentImage, from: currentImage.extent) {
            editedImage = UIImage(cgImage: cgImage)
        }
    }
}

enum ImageFilter: String, CaseIterable, Identifiable {
    case none = "Original"
    case mono = "Mono"
    case vibrant = "Vibrant"
    case noir = "Noir"
    case fade = "Fade"
    case chrome = "Chrome"
    case process = "Process"
    case transfer = "Transfer"
    case instant = "Instant"
    
    var id: String { rawValue }
    
    func apply(to image: CIImage, intensity: Double = 1.0) -> CIImage? {
        switch self {
        case .none:
            return image
        case .mono:
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = image
            return filter.outputImage
        case .vibrant:
            let filter = CIFilter.vibrance()
            filter.inputImage = image
            return filter.outputImage
        case .noir:
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = image
            return filter.outputImage
        case .fade:
            let filter = CIFilter.colorControls()
            filter.inputImage = image
            filter.saturation = 0.7
            filter.brightness = 0.1
            return filter.outputImage
        case .chrome:
            let filter = CIFilter.photoEffectChrome()
            filter.inputImage = image
            return filter.outputImage
        case .process:
            let filter = CIFilter.photoEffectProcess()
            filter.inputImage = image
            return filter.outputImage
        case .transfer:
            let filter = CIFilter.photoEffectTransfer()
            filter.inputImage = image
            return filter.outputImage
        case .instant:
            let filter = CIFilter.photoEffectInstant()
            filter.inputImage = image
            return filter.outputImage
        }
    }
}

struct FilterButton: View {
    let filter: ImageFilter
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Text(filter.rawValue)
                        .font(.caption)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(isSelected ? Color.appPink : Color.gray.opacity(0.1))
                        .foregroundColor(isSelected ? .white : .primary)
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    ImageEditorView(image: UIImage(systemName: "photo")!) { _ in }
}
