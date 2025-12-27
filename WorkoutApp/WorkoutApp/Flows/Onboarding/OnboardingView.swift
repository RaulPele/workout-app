//
//  OnboardingView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.06.2023.
//

import SwiftUI

struct OnboardingView: View {
    
    enum Tab {
        case welcomeView
        case startASessionView
        case sessionDetailsView
        case buildTemplatesView
    }
    
    @State private var selection: Tab = .welcomeView
    private let onFinishedOnboarding: () -> Void
    
    init(onFinishedOnboarding: @escaping () -> Void) {
        self.onFinishedOnboarding = onFinishedOnboarding
    }
    
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
        .background(Color.red)
    }
    
    private var finishButtonView: some View {
        Buttons.Filled(
            title: "Continue",
            backgroundColor: .primaryColor,
            foregroundColor: .onPrimary
        ) {
            onFinishedOnboarding()
        }
        .frame(maxWidth: 200)
    }
}

#Preview {
    OnboardingView(onFinishedOnboarding: {})
}
