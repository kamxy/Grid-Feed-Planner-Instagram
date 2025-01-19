import UIKit

struct SelectedImage: Identifiable {
    let id: Int
    let image: UIImage
    
    init(index: Int, image: UIImage) {
        self.id = index
        self.image = image
    }
} 