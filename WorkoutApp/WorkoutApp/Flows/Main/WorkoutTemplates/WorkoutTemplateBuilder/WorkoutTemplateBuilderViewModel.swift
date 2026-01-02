//
//  WorkoutTemplateBuilderViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import Observation
import SwiftUI

extension WorkoutTemplateBuilder {
    
    @Observable class ViewModel {
        
        var title: String = "New Workout" //TODO: fix
        var reps: String = ""
        var sets: String = ""
        var restTime: String = ""
        var seconds: String = ""
        var minutes: String = ""
        
        var showEditingView: Bool = false
        var showAddExerciseView: Bool = false
        
        var exercises = [Exercise]()
        
        let exerciseService: any ExerciseServiceProtocol
        let workoutTemplateService: any WorkoutTemplateServiceProtocol
        
        @ObservationIgnored weak var navigationManager: WorkoutTemplatesNavigationManager?
        
        @ObservationIgnored private var saveTemplateTask: Task<Void, Never>?
        
        var selectedExercise: Binding<Exercise>? {
            didSet {
                if selectedExercise != nil {
                    showEditingView = true
                }
            }
        }
        
        init(exerciseService: any ExerciseServiceProtocol,
             workoutTemplateService: any WorkoutTemplateServiceProtocol) {
            exercises = []
            self.exerciseService = exerciseService
            self.workoutTemplateService = workoutTemplateService
        }
        
        var fieldsAreValid: Bool {
            return !(title.isEmpty || reps.isEmpty || sets.isEmpty || restTime.isEmpty || seconds.isEmpty || minutes.isEmpty)
        }
        
        //MARK: - Public Handlers
        func handleOnSaveTapped() {
            saveWorkoutTemplate()
        }
        
        func handleBackAction() {
            navigationManager?.pop()
        }
        
        func handleAddExerciseButtonTapped() {
            showAddExerciseView = true
        }
        
        //MARK: - Private Methods
        private func saveWorkoutTemplate() {
            //TODO: field validations
            saveTemplateTask?.cancel()
            
            saveTemplateTask = Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                let newTemplate = WorkoutTemplate(id: .init(), name: title, exercises: exercises)
                do {
                    try await self.workoutTemplateService.save(entity: newTemplate)
                    await MainActor.run {
                        self.navigationManager?.pop()
                    }
                } catch {
                    print("Error while saving template: \(error.localizedDescription)")
                }
            }
        }
        
        
    }
}
