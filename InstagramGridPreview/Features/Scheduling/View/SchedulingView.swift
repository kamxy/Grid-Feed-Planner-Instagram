import PhotosUI
import SwiftUI

struct SchedulingView: View {
    @StateObject private var viewModel = SchedulingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingDatePicker = false
    @State private var showingHashtagInput = false
    @State private var newHashtag = ""
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Schedule").tag(0)
                    Text("Drafts (\(viewModel.drafts.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    // Schedule Tab
                    ScheduleFormView(
                        selectedImages: $selectedImages,
                        showingImagePicker: $showingImagePicker,
                        caption: $viewModel.caption,
                        hashtags: $viewModel.hashtags,
                        selectedDate: $viewModel.selectedDate,
                        showingDatePicker: $showingDatePicker,
                        showingHashtagInput: $showingHashtagInput,
                        newHashtag: $newHashtag,
                        onSchedule: {
                            Task {
                                await viewModel.schedulePost(images: selectedImages)
                                dismiss()
                            }
                        },
                        onSaveDraft: {
                            Task {
                                await viewModel.saveDraft(images: selectedImages)
                                dismiss()
                            }
                        }
                    )
                    .tag(0)
                    
                    // Drafts Tab
                    DraftsListView(
                        drafts: viewModel.drafts,
                        onDelete: { draft in
                            Task {
                                await viewModel.deletePost(draft)
                            }
                        },
                        onSchedule: { draft in
                            Task {
                                await viewModel.convertDraftToScheduled(draft)
                                dismiss()
                            }
                        }
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(selectedTab == 0 ? "Schedule Post" : "Drafts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.3))
                }
            }
        }
    }
}

// MARK: - Schedule Form View

private struct ScheduleFormView: View {
    @Binding var selectedImages: [UIImage]
    @Binding var showingImagePicker: Bool
    @Binding var caption: String
    @Binding var hashtags: [String]
    @Binding var selectedDate: Date
    @Binding var showingDatePicker: Bool
    @Binding var showingHashtagInput: Bool
    @Binding var newHashtag: String
    
    let onSchedule: () -> Void
    let onSaveDraft: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    Button {
                                        selectedImages.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Circle().fill(.black.opacity(0.7)))
                                    }
                                    .padding(4),
                                    alignment: .topTrailing
                                )
                        }
                        
                        Button {
                            showingImagePicker = true
                        } label: {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.title2)
                                Text("Add Photo")
                                    .font(.caption)
                            }
                            .frame(width: 100, height: 100)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
                
                // Caption
                VStack(alignment: .leading) {
                    Text("Caption")
                        .font(.headline)
                    TextEditor(text: $caption)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Hashtags
                VStack(alignment: .leading) {
                    Text("Hashtags")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(hashtags, id: \.self) { hashtag in
                                HStack {
                                    Text("#\(hashtag)")
                                    Button {
                                        hashtags.removeAll { $0 == hashtag }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(16)
                            }
                            
                            Button {
                                showingHashtagInput = true
                            } label: {
                                Image(systemName: "plus")
                                    .padding(8)
                                    .background(Color.secondary.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Date Selection
                VStack {
                    Button {
                        showingDatePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text(selectedDate.formatted(date: .long, time: .shortened))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: onSchedule) {
                        Text("Schedule Post")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onSaveDraft) {
                        Text("Save as Draft")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                DatePicker("Select Date", selection: $selectedDate, in: Date()...)
                    .datePickerStyle(.graphical)
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingDatePicker = false
                            }
                        }
                    }
            }
        }
        .alert("Add Hashtag", isPresented: $showingHashtagInput) {
            TextField("Hashtag", text: $newHashtag)
            Button("Add") {
                if !newHashtag.isEmpty {
                    hashtags.append(newHashtag)
                    newHashtag = ""
                }
            }
            Button("Cancel", role: .cancel) {
                newHashtag = ""
            }
        }
    }
}

// MARK: - Drafts List View

private struct DraftsListView: View {
    let drafts: [ScheduledPost]
    let onDelete: (ScheduledPost) -> Void
    let onSchedule: (ScheduledPost) -> Void
    
    var body: some View {
        List {
            ForEach(drafts) { draft in
                DraftCell(draft: draft, onDelete: onDelete, onSchedule: onSchedule)
            }
        }
        .listStyle(.plain)
    }
}

private struct DraftCell: View {
    let draft: ScheduledPost
    let onDelete: (ScheduledPost) -> Void
    let onSchedule: (ScheduledPost) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(draft.caption)
                .lineLimit(2)
            
            if !draft.hashtags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(draft.hashtags, id: \.self) { hashtag in
                            Text("#\(hashtag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            HStack {
                Text("Last modified: \(draft.lastModified.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    onSchedule(draft)
                } label: {
                    Text("Schedule")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete(draft)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}
