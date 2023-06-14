//
//  WorkoutDetailsViewController.swift
//  WorkoutApp
//
//  Created by Raul Pele on 04.05.2023.
//

import Foundation
import SwiftUI

extension WorkoutDetails {
    
    class ViewController: UIHostingController<ContentView> {
        
        let viewModel: ViewModel
        
        init(workout: Workout) {
            self.viewModel = .init(workout: workout)
            super.init(rootView: ContentView(viewModel: viewModel))
            setupNavigation()
            self.view.backgroundColor = UIColor(Color.background)
        }
        
        //TODO: find out what this does
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupNavigation() {
            viewModel.onBack = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
    }
}
