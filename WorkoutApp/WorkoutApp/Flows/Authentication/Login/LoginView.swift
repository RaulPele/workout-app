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
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                VStack {
                    //TODO: change the way the placeholders are created
                    RoundedTextField(text: $viewModel.email,
                                     placeHolderText: "Enter your email...",
                                     keyboardType: .emailAddress,
                                     textContentType: .emailAddress)
                    
                    
                    Buttons.Filled(title: "Continue") {
                        
                    }
                }
                .padding(.horizontal, 24)

            }
            
        }
    }
}

#if DEBUG
struct Login_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            Login.ContentView(viewModel: .init())
                .previewDevice(device)
                .previewDisplayName(device.rawValue)
        }
    }
}
#endif
