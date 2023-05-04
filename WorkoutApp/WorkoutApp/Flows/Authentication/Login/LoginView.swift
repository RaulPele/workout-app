//
// LoginView.swift
// WorkoutApp
//
// Created by Raul Pele on 08.04.2023.
//
//

import Foundation
import SwiftUI

struct Login {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            ZStack {
                Color.background
                
                VStack {
                    //TODO: change the way the placeholders are created
                    RoundedTextField(text: $viewModel.email,
                                     placeHolderText: "Enter your email...",
                                     keyboardType: .emailAddress,
                                     textContentType: .emailAddress)
                    RoundedTextField(text: $viewModel.password,
                                     placeHolderText: "Password",
                                     textContentType: .password)
                    
                    Buttons.Filled(title: "Continue") {
                        viewModel.handleContinueButtonTapped()
                    }
                }
                .padding(.horizontal, 24)
            }
            .onAppear {
                viewModel.testAPI()
            }
            
        }
    }
}

#if DEBUG
struct Login_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            Login.ContentView(viewModel: .init(authenticationService: MockedAuthenticationService()))
                .previewDevice(device)
                .previewDisplayName(device.rawValue)
        }
    }
}
#endif
