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
    @StateObject var viewModel = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            if viewModel.isOnboardingDone {
                HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                OnboardingView(viewModel: viewModel)
            }
        }
    }
}
