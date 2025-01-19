import SwiftUI

struct ImageEditorView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var selectedFilter: ImageFilter = .none
    @State private var adjustment = ImageAdjustment()
    @State private var editedImage: UIImage
    @State private var selectedTab: EditingTab = .filters
    
    init(image: UIImage, onSave: @escaping (UIImage) -> Void) {
        self.image = image
        self.onSave = onSave
        _editedImage = State(initialValue: image)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ImagePreviewView(
                    image: editedImage,
                    scale: $scale,
                    lastScale: $lastScale,
                    offset: $offset,
                    lastOffset: $lastOffset
                )
                
                EditingControlsView(
                    selectedTab: $selectedTab,
                    selectedFilter: $selectedFilter,
                    adjustment: $adjustment,
                    originalImage: image,
                    onFilterChange: applyEdits,
                    onAdjustmentChange: applyEdits
                )
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
                    Button("Save") {
                        onSave(editedImage)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func applyEdits() {
        let filteredImage = selectedFilter.apply(to: image)
        editedImage = adjustment.apply(to: filteredImage)
    }
}

// MARK: - Image Preview View
struct ImagePreviewView: View {
    let image: UIImage
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    
    var body: some View {
        GeometryReader { _ in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            },
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                            }
                    )
                )
        }
    }
}

// MARK: - Editing Controls View
struct EditingControlsView: View {
    @Binding var selectedTab: EditingTab
    @Binding var selectedFilter: ImageFilter
    @Binding var adjustment: ImageAdjustment
    let originalImage: UIImage
    let onFilterChange: () -> Void
    let onAdjustmentChange: () -> Void
    
    var body: some View {
        VStack {
            Picker("Edit Mode", selection: $selectedTab) {
                ForEach(EditingTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            TabView(selection: $selectedTab) {
                FiltersView(
                    image: originalImage,
                    selectedFilter: $selectedFilter,
                    onFilterChange: onFilterChange
                )
                .tag(EditingTab.filters)
                
                AdjustmentsView(
                    adjustment: $adjustment,
                    onAdjustmentChange: onAdjustmentChange
                )
                .tag(EditingTab.adjustments)
            }
            .frame(height: 150)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Filters View
struct FiltersView: View {
    let image: UIImage
    @Binding var selectedFilter: ImageFilter
    let onFilterChange: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(ImageFilter.allCases) { filter in
                    FilterThumbnail(
                        image: image,
                        filter: filter,
                        isSelected: filter == selectedFilter
                    )
                    .onTapGesture {
                        selectedFilter = filter
                        onFilterChange()
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Adjustments View
struct AdjustmentsView: View {
    @Binding var adjustment: ImageAdjustment
    let onAdjustmentChange: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            AdjustmentSlider(
                value: $adjustment.brightness,
                range: ImageAdjustment.ranges["brightness"]!,
                label: "Brightness"
            )
            
            AdjustmentSlider(
                value: $adjustment.contrast,
                range: ImageAdjustment.ranges["contrast"]!,
                label: "Contrast"
            )
            
            AdjustmentSlider(
                value: $adjustment.saturation,
                range: ImageAdjustment.ranges["saturation"]!,
                label: "Saturation"
            )
        }
        .padding()
        .onChange(of: adjustment) { _ in
            onAdjustmentChange()
        }
    }
}

// MARK: - Supporting Views

struct FilterThumbnail: View {
    let image: UIImage
    let filter: ImageFilter
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(uiImage: filter.apply(to: image))
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
            
            Text(filter.rawValue)
                .font(.caption)
                .foregroundColor(isSelected ? .accentColor : .primary)
        }
    }
}

struct AdjustmentSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Slider(value: $value, in: range)
                Text(String(format: "%.1f", value))
                    .font(.caption)
                    .frame(width: 35)
            }
        }
    }
}

// MARK: - Supporting Types

enum EditingTab: String, CaseIterable, Identifiable {
    case filters = "Filters"
    case adjustments = "Adjust"
    
    var id: String { rawValue }
}

// MARK: - Preview

struct ImageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageEditorView(image: UIImage(systemName: "photo")!) { _ in }
    }
}
