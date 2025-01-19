import SwiftUI
import PhotosUI

struct NewPostView: View {
    let date: Date
    let onSave: (ScheduledPost) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var caption = ""
    @State private var hashtags = ""
    @State private var scheduledDate: Date
    
    init(date: Date, onSave: @escaping (ScheduledPost) -> Void) {
        self.date = date
        self.onSave = onSave
        _scheduledDate = State(initialValue: date)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    
                    PhotosPicker(selection: $selectedItem,
                               matching: .images) {
                        Label(selectedImage == nil ? "Select Image" : "Change Image",
                              systemImage: "photo")
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                    }
                }
                
                Section("Caption") {
                    TextEditor(text: $caption)
                        .frame(height: 100)
                }
                
                Section("Hashtags") {
                    TextField("Add hashtags separated by spaces", text: $hashtags)
                }
                
                Section("Schedule") {
                    DatePicker("Post at", selection: $scheduledDate)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePost()
                    }
                    .disabled(selectedImage == nil)
                }
            }
        }
    }
    
    private func savePost() {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }
        
        let hashtags = self.hashtags
            .split(separator: " ")
            .map(String.init)
            .filter { $0.hasPrefix("#") }
        
        let post = ScheduledPost(
            image: imageData,
            caption: caption,
            scheduledDate: scheduledDate,
            hashtags: hashtags
        )
        
        onSave(post)
        dismiss()
    }
}

// MARK: - Preview
struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(date: Date()) { _ in }
    }
} 