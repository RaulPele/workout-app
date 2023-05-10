//
//  AccountVerificationView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import SwiftUI

struct AccountVerification {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                VStack {
                    //TODO: change the way the placeholders are created
                    RoundedTextField(text: $viewModel.email,
                                     placeHolderText: "Enter your email...",
                                     keyboardType: .emailAddress,
                                     textContentType: .emailAddress)
                    
                    
                    Buttons.Filled(
                        title: "Continue",
                        isLoading: viewModel.isLoading
                    ) {
                        viewModel.handleContinueButtonTapped()
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

#if DEBUG
struct AccountVerification_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            AccountVerification.ContentView(viewModel: .init(authenticationService: MockedAuthenticationService()))
                .previewDevice(device)
                .previewDisplayName(device.rawValue)
        }
    }
}
#endif
