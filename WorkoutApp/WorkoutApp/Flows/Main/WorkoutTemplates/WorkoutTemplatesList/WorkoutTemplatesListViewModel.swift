//
//  WorkoutTemplatesListViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import Combine
import SwiftUI

extension WorkoutTemplatesList {

    @Observable class ViewModel {

        //MARK: - Properties
        var workouts = [Workout]()
        var isLoading = false
        private let workoutTemplateRepository: any WorkoutRepository

        @ObservationIgnored weak var navigationManager: WorkoutTemplatesNavigationManager?

        private var loadTask: Task<Void, Never>?
        
        private var cancellables = Set<AnyCancellable>()

        //MARK: - Initializers
        init(workoutTemplateRepository: any WorkoutRepository) {
            self.workoutTemplateRepository = workoutTemplateRepository
            subscribeToWorkoutRepository()
            loadTemplates()
        }

        //MARK: - Private Methods
        private func subscribeToWorkoutRepository() {
            workoutTemplateRepository
                .entitiesPublisher
                .sink { [weak self] workouts in
                    self?.workouts = workouts
                }
                .store(in: &cancellables)
        }
        
        private func loadTemplates() {
            loadTask?.cancel()
            isLoading = true
            loadTask = Task { @MainActor [weak self] in
                defer { self?.isLoading = false }
                do {
                    try await self?.workoutTemplateRepository.loadData()
                } catch {
                    print("Error while loading templates: \(error.localizedDescription)")
                }
            }
        }

        private func currentTemplatesFromPublisher() async -> [Workout] {
            await withCheckedContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = workoutTemplateRepository.entitiesPublisher
                    .first()
                    .sink { value in
                        continuation.resume(returning: value)
                        cancellable = nil
                    }
            }
        }

        //MARK: - Event handlers
        func handleAddButtonTapped() {
            navigationManager?.push(WorkoutTemplateBuilderRoute())
        }

        func handleTemplateTapped(_ template: Workout) {
            navigationManager?.push(WorkoutTemplateBuilderRoute(workout: template))
        }

        func handleOnAppear() {
            loadTemplates()
        }
    }
}
