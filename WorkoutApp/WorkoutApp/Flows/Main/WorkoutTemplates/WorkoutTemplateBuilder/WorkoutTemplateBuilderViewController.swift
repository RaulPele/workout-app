//
//  WorkoutTemplateBuilderViewController.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.06.2023.
//

import Foundation
import SwiftUI

extension WorkoutTemplateBuilder {
    
    class ViewController: UIHostingController<ContentView> {
        
        let viewModel: ViewModel
        
        init(exerciseService: any ExerciseServiceProtocol,
             workoutTemplateService: any WorkoutTemplateServiceProtocol) {
            viewModel = ViewModel(exerciseService: exerciseService, workoutTemplateService: workoutTemplateService)
            super.init(rootView: ContentView(viewModel: viewModel))
            setupNavigation()
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupNavigation() {
            viewModel.onBack = { [weak self] in
                self?.navigateBack()
            }
        }
        
        func navigateBack() {
            navigationController?.popViewController(animated: true)
        }
    }
}
