//
//  OnboardingView.swift
//  InstagramGridPreview
//
//  Created by Mehmet Kamay on 28.09.2024.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentTab = 0
    @ObservedObject var viewModel: OnboardingViewModel


    var body: some View {
        VStack(alignment: .center) {
            Image("onboardingBg").resizable().frame(maxHeight:  .infinity).scaledToFit()
            Text("welcomeTı ").bold().font(.largeTitle).padding(.top,20).foregroundColor(.black)
            Text("Grid: Feed Planner Instagram").bold().font(.title).foregroundStyle(LinearGradient(
                colors: [.purple, .pink, .orange, .blue],
                startPoint: .leading,
                endPoint: .trailing
            ))
            Text("planAndDesign").multilineTextAlignment(.center).padding(.top,1).font(.headline).bold().foregroundColor(.gray)
            Spacer()
            Button(action: {
                
                viewModel.isOnboardingDone = true

            }, label: {
                Text("continue").foregroundStyle(.gray).font(.title2).bold().paddingAll()
            }).frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/).background(.white).cornerRadius(10).shadow(radius: 4).paddingAll()
            Spacer()
            
        }.ignoresSafeArea()
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
}
