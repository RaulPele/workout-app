//
//  OnboardingView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import SwiftUI

extension OnboardingView {
    
    class ViewModel: ObservableObject {
        
        var onFinishedOnboarding: (() -> Void)?
        
        func handleFinishButtonTapped() {
            onFinishedOnboarding?()
        }
    }
}

struct OnboardingView: View {
    
    enum Tab {
        case welcomeView
        case startASessionView
        case sessionDetailsView
        case buildTemplatesView
    }
    
    @ObservedObject var viewModel: ViewModel
    
    @State private var selection: Tab = .welcomeView
    
    var body: some View {
        TabView(selection: $selection) {
            WelcomeView()
                .tag(Tab.welcomeView)

            StartASessionView()
                .tag(Tab.startASessionView)
            
            SeeSessionDetailsView()
                .tag(Tab.sessionDetailsView)
            
            BuildTemplatesView()
                .tag(Tab.buildTemplatesView)
                .overlay(alignment: .bottom) {
                    finishButtonView
                        .padding(.bottom, 70)
                }

        }
        .tabViewStyle(.page)
        .background(Color.background)
    }
    
    private var finishButtonView: some View {
        Buttons.Filled(
            title: "Continue",
            backgroundColor: .primaryColor,
            foregroundColor: .onPrimary
        ) {
            viewModel.handleFinishButtonTapped()
        }
        .frame(maxWidth: 200)
    }
}

#if DEBUG
struct OnboardingCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(previewDevices) { device in
            OnboardingView(viewModel: .init())
                .preview(device)
        }
    }
}
#endif
