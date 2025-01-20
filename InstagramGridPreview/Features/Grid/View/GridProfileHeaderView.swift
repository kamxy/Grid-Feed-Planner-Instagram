import SwiftUI

struct GridProfileHeaderView: View {
    let username: String
    let profileImage: UIImage?
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.appPink, lineWidth: 2)).padding(.trailing, 10)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray).padding(.trailing, 10)
            }
            
            // Username
            Text(username.isEmpty ? "User's Grid Preview" : "\(username)'s Grid Preview")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
    }
}
