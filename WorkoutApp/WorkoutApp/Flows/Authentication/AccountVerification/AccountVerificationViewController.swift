//
//  AccountVerificationViewController.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation
import SwiftUI

extension AccountVerification {
    
    class ViewController: UIHostingController<ContentView> {
        
        let viewModel: ViewModel
        
        init(authenticationService: AuthenticationServiceProtocol) {
            self.viewModel = .init(authenticationService: authenticationService)
            super.init(rootView: ContentView(viewModel: viewModel))
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
