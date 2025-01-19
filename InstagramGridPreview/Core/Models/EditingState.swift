import Foundation
import SwiftUI

enum EditingState: Identifiable {
    case image(index: Int, image: UIImage)

    var id: Int {
        switch self {
        case .image(let index, _):
            return index
        }
    }
}
