//
//  WorkoutTemplatesListViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import SwiftUI

extension WorkoutTemplatesList {
   
    class ViewModel: ObservableObject {
        
        //MARK: - Properties
        @Published var workoutTemplates = [WorkoutTemplate.mockedWorkoutTemplate2(), .mockedWorkoutTemplate2(), .mockedWorkoutTemplate2(), .mockedWorkoutTemplate2(), .mockedWorkoutTemplate2()]
        
        var navigateToTemplateBuilder: (() -> Void)? = nil
        
        //MARK: - Event handlers
        func handleAddButtonTapped() {
            navigateToTemplateBuilder?()
        }
        
    }
}

