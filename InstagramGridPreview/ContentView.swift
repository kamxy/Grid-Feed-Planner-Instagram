//
//  ContentView.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 19.01.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabContentView()

        /* TabView {

             SettingsView()
                 .tabItem {
                     Label("settings.title".localized, systemImage: "gear")
                 }
         }*/
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
