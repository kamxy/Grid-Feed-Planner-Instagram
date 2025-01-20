import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username: String
    @State private var profileImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    let onSave: (String, UIImage?) -> Void
    
    init(username: String, profileImage: UIImage?, onSave: @escaping (String, UIImage?) -> Void) {
        _username = State(initialValue: username)
        _profileImage = State(initialValue: profileImage)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.appPink, lineWidth: 2))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                            
                            PhotosPicker(selection: $selectedItem,
                                       matching: .images)
                            {
                                Text("Change Photo")
                                    .foregroundColor(.appPink)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section("Username") {
                    TextField("Enter username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(username, profileImage)
                        dismiss()
                    }
                    .foregroundColor(.appPink)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        profileImage = image
                    }
                }
            }
        }
    }
} 