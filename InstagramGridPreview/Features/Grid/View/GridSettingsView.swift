import SwiftUI

struct GridSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var gridColumns: Int
    @Binding var gridSpacing: CGFloat
    @State private var backgroundColor: Color = .white
    @State private var borderWidth: CGFloat = 0
    @State private var borderColor: Color = .black
    @State private var padding: CGFloat = 0
    @State private var showPreview = false
    
    let onApply: (GridExportService.ExportOptions) -> Void
    let previewImages: [UIImage]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("settings.gridLayout".localized) {
                    Picker("settings.columns".localized, selection: $gridColumns) {
                        Text("3 x 3").tag(3)
                        Text("4 x 4").tag(4)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("settings.gridSpacing".localized) {
                    Slider(value: $gridSpacing, in: 0...10, step: 1) {
                        Text("settings.spacing".localized)
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("10")
                    }
                }
                
                Section("settings.gridStyle".localized) {
                    ColorPicker("settings.backgroundColor".localized, selection: $backgroundColor)
                    
                    VStack(alignment: .leading) {
                        Text("settings.borderWidth".localized)
                        Slider(value: $borderWidth, in: 0...5, step: 0.5)
                    }
                    
                    if borderWidth > 0 {
                        ColorPicker("settings.borderColor".localized, selection: $borderColor)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("settings.padding".localized)
                        Slider(value: $padding, in: 0...20, step: 1)
                    }
                }
                
                Section {
                    Button("settings.previewGrid".localized) {
                        showPreview = true
                    }
                }
            }
            .navigationTitle("settings.gridSettings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("alert.cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("settings.apply".localized) {
                        let options = GridExportService.ExportOptions(
                            spacing: gridSpacing,
                            backgroundColor: UIColor(backgroundColor),
                            borderWidth: borderWidth,
                            borderColor: UIColor(borderColor),
                            padding: padding
                        )
                        onApply(options)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPreview) {
                NavigationStack {
                    GridPreviewView(
                        images: previewImages,
                        columns: gridColumns,
                        spacing: gridSpacing,
                        backgroundColor: backgroundColor,
                        borderWidth: borderWidth,
                        borderColor: borderColor,
                        padding: padding
                    )
                    .navigationTitle("settings.gridPreview".localized)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("alert.done".localized) {
                                showPreview = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

struct GridPreviewView: View {
    let images: [UIImage]
    let columns: Int
    let spacing: CGFloat
    let backgroundColor: Color
    let borderWidth: CGFloat
    let borderColor: Color
    let padding: CGFloat
    
    private let gridItems: [GridItem]
    
    init(images: [UIImage], columns: Int, spacing: CGFloat, backgroundColor: Color, borderWidth: CGFloat, borderColor: Color, padding: CGFloat) {
        self.images = images
        self.columns = columns
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.padding = padding
        self.gridItems = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems, spacing: spacing) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(Rectangle())
                        .overlay(
                            Rectangle()
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                }
            }
            .padding(padding)
        }
        .background(backgroundColor)
    }
} 