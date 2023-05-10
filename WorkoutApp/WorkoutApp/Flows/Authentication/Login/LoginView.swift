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
            VStack {
                //TODO: change the way the placeholders are created
                RoundedTextField(text: $viewModel.email,
                                 placeHolderText: "Enter your email...",
                                 keyboardType: .emailAddress,
                                 textContentType: .emailAddress)
                RoundedTextField(text: $viewModel.password,
                                 placeHolderText: "Password",
                                 textContentType: .password)
                
                
                Buttons.Filled(
                    title: "Continue",
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.handleContinueButtonTapped()
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
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
