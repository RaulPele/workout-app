//
//  WorkoutTemplateBuilderViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import Foundation
import SwiftUI

extension WorkoutTemplateBuilder {
    
    class ViewModel: ObservableObject {
        
        @Published var title: String = ""
        @Published var reps: String = ""
        @Published var sets: String = ""
        @Published var restTime: String = ""
        @Published var seconds: String = ""
        @Published var minutes: String = ""
        
        @Published var showEditingView: Bool = false
        @Published var showAddExerciseView: Bool = false
        
        @Published var exercises = [Exercise]()
        
        let exerciseService: any ExerciseServiceProtocol
        let workoutTemplateService: any WorkoutTemplateServiceProtocol
        
        var onBack: (() -> Void)? = nil
        
        private var saveTemplateTask: Task<Void, Never>?
        
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
            onBack?()
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
                        self.onBack?()
                    }
                } catch {
                    print("Error while saving template: \(error.localizedDescription)")
                }
            }
        }
        
        
    }
}
