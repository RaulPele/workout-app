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
        let workoutTemplateService: any WorkoutServiceProtocol
        
        var templateId: UUID?
        
        @ObservationIgnored weak var navigationManager: WorkoutTemplatesNavigationManager?
        @ObservationIgnored private var saveTemplateTask: Task<Void, Never>?
        @ObservationIgnored private var loadTemplateTask: Task<Void, Never>?
        
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
             workoutTemplateService: any WorkoutServiceProtocol,
             templateId: UUID? = nil) {
            exercises = []
            self.exerciseService = exerciseService
            self.workoutTemplateService = workoutTemplateService
            self.templateId = templateId
            logger.debug("WorkoutTemplateBuilder ViewModel initialized with templateId: \(templateId?.uuidString ?? "nil")")
            
            if let templateId {
                loadTemplate(templateId: templateId)

            }
        }
        
        //MARK: - Public Handlers
        @MainActor
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
        private func loadTemplate(templateId: UUID) {
            loadTemplateTask?.cancel()
            loadTemplateTask = Task { @MainActor [weak self] in
                guard let self else { return } //TODO: this creates a strong reference
                do {
                    let allTemplates = try await self.workoutTemplateService.getAll()
                    if let template = allTemplates.first(where: { $0.id == templateId }) {
                        self.title = template.name
                        self.exercises = template.exercises
                        self.isEditing = true
                        self.logger.info("Loaded template: \(template.name) with \(template.exercises.count) exercises")
                    } else {
                        self.logger.error("Template with id \(templateId) not found")
                    }
                } catch {
                    self.logger.error("Error while loading template: \(error.localizedDescription)")
                }
            }
        }
        
        private func saveWorkoutTemplate() {
            //TODO: field validations
            logger.info("Starting to save workout template: \(self.title)")
            saveTemplateTask?.cancel()
            
            saveTemplateTask = Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                let templateId = self.templateId ?? UUID()
                let template = Workout(id: templateId, name: title, exercises: exercises)
                logger.debug("\(self.templateId != nil ? "Updating" : "Creating") template with \(exercises.count) exercises")
                do {
                    try await self.workoutTemplateService.save(entity: template)
                    logger.info("Successfully saved workout template: \(self.title)")
                } catch {
                    logger.error("Error while saving template: \(error.localizedDescription)")
                }
            }
        }
        
        
    }
}
