//
//  HealthKitAuthorizationView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 10.05.2023.
//

import SwiftUI

struct HealthKitAuthorization {
    
    struct ContentView: View {
        
        let viewModel: ViewModel
        @Environment(\.scenePhase) private var scenePhase
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack {
                Spacer()
                messageView
                Spacer()
                authorizationButtonView
                    .padding(.bottom, 40)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.background)
            .onAppear {
                viewModel.checkAuthorizationStatus()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.checkAuthorizationStatus()
                }
            }
        }
        
        private var messageView: some View {
            VStack(spacing: 20) {
                Text("\(Constants.appName) doesn't have permission to access your workout data")
                
                Text("Please give permission in order to keep using the app.")
            }
            .foregroundStyle(Color.onBackground)
            .font(.heading3)
            .multilineTextAlignment(.center)
        }
        
        private var authorizationButtonView: some View {
            Buttons.Filled(
                title: "Authorize",
                backgroundColor: .white,
                foregroundColor: .red,
                fontSize: 15,
                isLoading: viewModel.isLoading
            ) {
                viewModel.authorize()
            }
            .frame(maxWidth: 300)
        }
    }
}

#Preview {
    HealthKitAuthorization.ContentView(viewModel: .init(healthKitManager: .init()))
}
