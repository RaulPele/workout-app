//
// HomeViewController.swift
// WorkoutApp
//
// Created by Raul Pele on 02.05.2023.
//
//

import Foundation
import UIKit
import SwiftUI

extension Home {
    
    class ViewController: UIHostingController<ContentView> {
        
        let viewModel: ViewModel
        
        init(workoutRepository: any WorkoutRepository,
             healthKitManager: HealthKitManager) {
            viewModel = ViewModel(workoutRepository: workoutRepository, healthKitManager: healthKitManager)
            super.init(rootView: .init(viewModel: viewModel))
            setupNavigation()
        }
        
        @objc required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupNavigation() {
            viewModel.onWorkoutTapped = { [weak self] selectedWorkout in
                let vc = WorkoutDetails.ViewController(workout: selectedWorkout)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
}
