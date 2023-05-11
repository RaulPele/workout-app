//
//  HealthKitAuthorizationViewController.swift
//  WorkoutApp
//
//  Created by Raul Pele on 10.05.2023.
//

import Foundation
import SwiftUI

extension HealthKitAuthorization {
    
    class ViewController: UIHostingController<ContentView> {
        
        let viewModel: ContentView.ViewModel
        
        init(healthKitManager: HealthKitManager) {
            viewModel = .init(healthKitManager: healthKitManager)
            super.init(rootView: HealthKitAuthorization.ContentView(viewModel: viewModel))
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
