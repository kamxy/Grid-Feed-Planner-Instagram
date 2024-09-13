//
//  SelectableImage.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 10.09.2024.
//

import Foundation
import SwiftUI

struct SelectableImage: Identifiable {
    let id: UUID
    let image: UIImage
    var isSelected: Bool = false
    var order: Int32?
}
