import SwiftUI

struct StoryHighlight: Identifiable {
    let id: UUID
    var title: String
    var image: UIImage
    var isAdd: Bool
    
    init(id: UUID = UUID(), title: String, image: UIImage, isAdd: Bool = false) {
        self.id = id
        self.title = title
        self.image = image
        self.isAdd = isAdd
    }
    
    static var addNew: StoryHighlight {
        StoryHighlight(title: "New", image: UIImage(systemName: "plus.circle.fill")!, isAdd: true)
    }
} 