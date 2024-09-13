//
//  Extension.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 13.09.2024.
//

import Foundation
import SwiftUI

extension View {
    func paddingVertical(_ value: CGFloat = 16) -> some View {
        self.padding(.top, value).padding(.bottom, value)
    }

    func paddingHorizontal(_ value: CGFloat = 16) -> some View {
        self.padding(.leading, value).padding(.trailing, value)
    }

    func paddingAll(_ value: CGFloat = 16) -> some View {
        self.padding(.leading, value).padding(.trailing, value).padding(.top, value).padding(.bottom, value)
    }
    
    func shadow(_ value: CGFloat = 5) -> some View {
        self.shadow(radius: value)
    }
}
