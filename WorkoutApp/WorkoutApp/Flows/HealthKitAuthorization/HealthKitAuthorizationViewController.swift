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
        
        private let viewModel: ContentView.ViewModel
        private let onFinished: () -> Void
        
        init(healthKitManager: HealthKitManager, onFinished: @escaping () -> Void) {
            viewModel = .init(healthKitManager: healthKitManager)
            self.onFinished = onFinished
            super.init(rootView: HealthKitAuthorization.ContentView(viewModel: viewModel))
            setupNavigation()
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupNavigation() {
            viewModel.onFinished = onFinished
        }
    }
}
