//
//  InstagramGridPreviewApp.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 10.09.2024.
//

import SwiftUI

@main
struct InstagramGridPreviewApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
