//
//  WorkoutTemplatesListViewController.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import Foundation
import SwiftUI

extension WorkoutTemplatesList {
    
    class ViewController: UIHostingController<ContentView> {
        
        private let viewModel: ViewModel
        private let exerciseService: any ExerciseServiceProtocol
        private let workoutTemplateService: any WorkoutTemplateServiceProtocol
        
        init(exerciseService: any ExerciseServiceProtocol,
             workoutTemplateService: any WorkoutTemplateServiceProtocol) {
            self.exerciseService = exerciseService
            self.workoutTemplateService = workoutTemplateService
            self.viewModel = ViewModel(workoutTemplateService: workoutTemplateService)
            super.init(rootView: ContentView(viewModel: viewModel))
            setupNavigation()
        }
        
        private func setupNavigation() {
            viewModel.navigateToTemplateBuilder =  { [weak self] in
                self?.navigateToTemplateBuilder()
            }
        }
        
        private func navigateToTemplateBuilder() {
            let vc = WorkoutTemplateBuilder.ViewController(
                exerciseService: exerciseService,
                workoutTemplateService: workoutTemplateService
            )
            navigationController?.pushViewController(vc, animated: true)
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
}
