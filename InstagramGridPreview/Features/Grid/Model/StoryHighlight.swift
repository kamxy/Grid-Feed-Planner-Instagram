import Foundation
import UIKit

struct StoryHighlight: Identifiable {
    let id: UUID
    let title: String
    let image: UIImage
    let isAdd: Bool
    
    init(id: UUID = UUID(), title: String, image: UIImage, isAdd: Bool = false) {
        self.id = id
        self.title = title
        self.image = image
        self.isAdd = isAdd
    }
    
    static let addNew = StoryHighlight(title: "New", image: UIImage(), isAdd: true)
} 