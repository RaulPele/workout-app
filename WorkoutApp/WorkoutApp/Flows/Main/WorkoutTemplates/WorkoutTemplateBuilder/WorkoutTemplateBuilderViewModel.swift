//
//  WorkoutTemplateBuilderViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 31.05.2023.
//

import Observation
import SwiftUI
 struct ExerciseIndex: Identifiable {
    let id: Int
}

extension WorkoutTemplateBuilder {
    
    @Observable class ViewModel {
        
        var title: String = "New Workout" //TODO: fix

        var showEditingView: Bool = false
        var showAddExerciseView: Bool = false
        
        var isEditing = false
        var deletingExerciseId: UUID?
        var editingExerciseIndex: ExerciseIndex?
        
        var exercises = [Exercise]()
        
        let exerciseService: any ExerciseServiceProtocol
        let workoutTemplateService: any WorkoutTemplateServiceProtocol
        
        @ObservationIgnored weak var navigationManager: WorkoutTemplatesNavigationManager?
        @ObservationIgnored private var saveTemplateTask: Task<Void, Never>?
        
        private let logger = CustomLogger(subsystem: "WorkoutBuilder", category: String(describing: ViewModel.self))
        
        var selectedExercise: Binding<Exercise>? {
            didSet {
                if selectedExercise != nil {
                    logger.debug("Exercise selected for editing")
                    showEditingView = true
                }
            }
        }
        
        init(exerciseService: any ExerciseServiceProtocol,
             workoutTemplateService: any WorkoutTemplateServiceProtocol) {
            exercises = []
            self.exerciseService = exerciseService
            self.workoutTemplateService = workoutTemplateService
            logger.debug("WorkoutTemplateBuilder ViewModel initialized")
        }
        
        //MARK: - Public Handlers
        func handleOnSaveTapped() {
            logger.info("Save button tapped")
            saveWorkoutTemplate()
            isEditing = false
        }
        
        func handleOnEditTapped() {
            logger.info("Edit button tapped")
            isEditing = true
        }
        
        func handleBackAction() { 
            logger.debug("Back action triggered")
            navigationManager?.pop()
        }
        
        func handleAddExerciseButtonTapped() {
            logger.debug("Add exercise button tapped")
            if !isEditing {
                isEditing = true
            }
            showAddExerciseView = true
        }
        
        //MARK: - Private Methods
        private func saveWorkoutTemplate() {
            //TODO: field validations
            logger.info("Starting to save workout template: \(self.title)")
            saveTemplateTask?.cancel()
            
            saveTemplateTask = Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                let newTemplate = WorkoutTemplate(id: .init(), name: title, exercises: exercises)
                logger.debug("Created template with \(exercises.count) exercises")
                do {
                    try await self.workoutTemplateService.save(entity: newTemplate)
                    logger.info("Successfully saved workout template: \(self.title)")
                } catch {
                    logger.error("Error while saving template: \(error.localizedDescription)")
                }
            }
        }
        
        
    }
}
