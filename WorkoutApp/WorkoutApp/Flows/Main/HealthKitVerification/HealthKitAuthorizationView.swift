//
//  HealthKitAuthorizationView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 10.05.2023.
//

import SwiftUI

struct HealthKitAuthorization {
    
    struct ContentView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            VStack() {
                Spacer()
                messageView
                Spacer()
                authorizationButtonView
                    .padding(.bottom, 40)
//                Spacer()
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.background)
        }
        
        private var messageView: some View {
            VStack(spacing: 20) {
                Text("\(Constants.appName) doesn't have permission to access your workout data")
                
                Text("Please give permission in order to keep using the app.")
                
            }
            .foregroundColor(.white)
            .font(.heading3)
            .multilineTextAlignment(.center)
            
        }
        
        private var authorizationButtonView: some View {
            Button {
                viewModel.authorize()
            } label: {
                Text("Authorize")
                    .foregroundColor(.red)
            }
            .buttonStyle(ButtonStyles.Filled(
                foregroundColor: .red,
                backgroundColor: .white,
                fontSize: 15))
            .frame(maxWidth: 300)
        }
    }
}

#if DEBUG
struct HealthKitAuthorizationView_Previews: PreviewProvider {
    
    static let viewModel = HealthKitAuthorization.ContentView.ViewModel(healthKitManager: .init())
    
    static var previews: some View {
        ForEach(previewDevices) { device in
            HealthKitAuthorization.ContentView(viewModel: viewModel)
                .preview(device)
        }
    }
}
#endif
