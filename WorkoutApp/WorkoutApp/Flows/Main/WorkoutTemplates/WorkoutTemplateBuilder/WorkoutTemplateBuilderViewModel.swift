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

        //MARK: - Properties
        var title: String = "New Workout" //TODO: fix

        var showEditingView: Bool = false
        var showAddExerciseView: Bool = false

        var isEditing = false
        var deletingExerciseId: UUID?
        var editingExerciseIndex: ExerciseIndex?

        var exercises = [Exercise]()

        let exerciseRepository: any ExerciseRepositoryProtocol
        let exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol
        let workoutTemplateRepository: any WorkoutRepository

        var workout: Workout?

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

        //MARK: - Initializers
        init(exerciseRepository: any ExerciseRepositoryProtocol,
             exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol,
             workoutTemplateRepository: any WorkoutRepository,
             navigationManager: WorkoutTemplatesNavigationManager,
             workout: Workout? = nil) {
            self.exerciseRepository = exerciseRepository
            self.exerciseDefinitionRepository = exerciseDefinitionRepository
            self.workoutTemplateRepository = workoutTemplateRepository
            self.navigationManager = navigationManager
            self.workout = workout
            if let workout {
                title = workout.name
                exercises = workout.exercises
                isEditing = true
                logger.debug("WorkoutTemplateBuilder ViewModel initialized for workout: \(workout.name)")
            } else {
                logger.debug("WorkoutTemplateBuilder ViewModel initialized for new workout")
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

        // MARK: - Reorder
        func moveExercise(from sourceIndex: Int, to destinationIndex: Int) {
            withAnimation(.spring(duration: 0.3)) {
                exercises.move(
                    fromOffsets: IndexSet(integer: sourceIndex),
                    toOffset: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex
                )
            }
        }

        //MARK: - Private Methods
        private func saveWorkoutTemplate() {
            //TODO: field validations
            logger.info("Starting to save workout template: \(self.title)")
            saveTemplateTask?.cancel()

            saveTemplateTask = Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                let id = self.workout?.id ?? UUID()
                let template = Workout(id: id, name: title, exercises: exercises)
                logger.debug("\(self.workout != nil ? "Updating" : "Creating") template with \(exercises.count) exercises")
                do {
                    try await self.workoutTemplateRepository.save(entity: template)
                    logger.info("Successfully saved workout template: \(self.title)")
                } catch {
                    logger.error("Error while saving template: \(error.localizedDescription)")
                }
            }
        }
    }
}
