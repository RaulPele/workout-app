//
//  WorkoutTemplateDetailViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Combine
import Foundation
import Observation

// MARK: - WorkoutTemplateDetailViewModel
@MainActor
@Observable
final class WorkoutTemplateDetailViewModel {

    // MARK: - Properties
    var isEditorPresented = false
    var isConfirmingDeletion = false
    var errorMessage: String?
    private(set) var workout: Workout?
    private(set) var hasLoaded = false

    let workoutId: UUID

    @ObservationIgnored private var allWorkouts: [Workout] = []
    @ObservationIgnored private let workoutRepository: any WorkoutRepository
    @ObservationIgnored weak var navigationManager: WorkoutTemplatesNavigationManager?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers
    init(
        workoutId: UUID,
        workoutRepository: any WorkoutRepository,
        navigationManager: WorkoutTemplatesNavigationManager
    ) {
        self.workoutId = workoutId
        self.workoutRepository = workoutRepository
        self.navigationManager = navigationManager
        subscribeToWorkouts()
    }

    // MARK: - Event Handlers
    func handleEditTapped() {
        isEditorPresented = true
    }

    func handleDuplicateTapped() {
        guard let workout else { return }
        let copy = workout.duplicate(existingNames: allWorkouts.map(\.name))
        Task {
            do {
                try await workoutRepository.save(entity: copy)
                navigationManager?.pop()
            } catch {
                errorMessage = "\(workout.name) couldn't be duplicated. Try again."
            }
        }
    }

    func handleDeleteTapped() {
        isConfirmingDeletion = true
    }

    func confirmDeletion() {
        guard let workout else { return }
        Task {
            do {
                try await workoutRepository.delete(entity: workout)
                navigationManager?.pop()
            } catch {
                errorMessage = "\(workout.name) couldn't be deleted. Try again."
            }
        }
    }

    // MARK: - Private Methods
    private func subscribeToWorkouts() {
        workoutRepository.entitiesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] workouts in
                guard let self else { return }
                allWorkouts = workouts
                workout = workouts.first { $0.id == self.workoutId }
                hasLoaded = true
            }
            .store(in: &cancellables)
    }
}
