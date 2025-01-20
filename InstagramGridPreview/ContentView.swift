//
//  ContentView.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 19.01.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GridView()
                .tabItem {
                    Label("grid.title".localized, systemImage: "square.grid.3x3")
                }

            SettingsView()
                .tabItem {
                    Label("settings.title".localized, systemImage: "gear")
                }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
