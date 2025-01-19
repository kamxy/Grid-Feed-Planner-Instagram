import SwiftUI

struct ScheduledPostRow: View {
    let post: ScheduledPost
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: post.scheduledDate)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let uiImage = UIImage(data: post.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.caption)
                    .lineLimit(2)
                    .font(.subheadline)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !post.hashtags.isEmpty {
                    Text(post.hashtags.joined(separator: " "))
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if post.isPublished {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Scheduled post for \(formattedDate)")
        .accessibilityHint(post.isPublished ? "Published" : "Not published yet")
    }
}

// MARK: - Preview
struct ScheduledPostRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ScheduledPostRow(post: ScheduledPost(
                image: UIImage(systemName: "photo")?.pngData() ?? Data(),
                caption: "Sample post caption",
                scheduledDate: Date(),
                hashtags: ["#swiftui", "#ios"],
                isPublished: false
            ))
            
            ScheduledPostRow(post: ScheduledPost(
                image: UIImage(systemName: "photo")?.pngData() ?? Data(),
                caption: "Published post",
                scheduledDate: Date().addingTimeInterval(3600),
                hashtags: ["#swift"],
                isPublished: true
            ))
        }
    }
} 