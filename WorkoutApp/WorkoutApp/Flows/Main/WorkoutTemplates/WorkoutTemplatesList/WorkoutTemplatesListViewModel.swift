//
//  WorkoutTemplatesListViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 29.05.2023.
//

import Combine
import SwiftUI

extension WorkoutTemplatesList {

    @MainActor
    @Observable
    class ViewModel {

        // MARK: - Sheet
        enum Sheet: Identifiable {
            case create
            case edit(Workout)

            var id: String {
                switch self {
                case .create: "create"
                case .edit(let workout): "edit-\(workout.id)"
                }
            }

            var workout: Workout? {
                if case .edit(let workout) = self { return workout }
                return nil
            }
        }

        // MARK: - Properties
        var workouts = [Workout]()
        var activeSheet: Sheet?
        var pendingDeletion: Workout?
        var errorMessage: String?
        private(set) var hasLoaded = false

        @ObservationIgnored private let workoutTemplateRepository: any WorkoutRepository
        @ObservationIgnored weak var navigationManager: WorkoutTemplatesNavigationManager?
        @ObservationIgnored private var cancellables = Set<AnyCancellable>()

        var isEmpty: Bool {
            hasLoaded && workouts.isEmpty
        }

        // MARK: - Initializers
        init(workoutTemplateRepository: any WorkoutRepository,
             navigationManager: WorkoutTemplatesNavigationManager) {
            self.workoutTemplateRepository = workoutTemplateRepository
            self.navigationManager = navigationManager
            subscribeToWorkoutRepository()
        }

        // MARK: - Loading
        func load() async {
            do {
                try await workoutTemplateRepository.loadData()
            } catch {
                errorMessage = "Your workouts couldn't be loaded. Pull to try again."
            }
            hasLoaded = true
        }

        // MARK: - Event Handlers
        func handleAddButtonTapped() {
            activeSheet = .create
        }

        func handleTemplateTapped(_ template: Workout) {
            navigationManager?.push(WorkoutTemplateDetailRoute(workoutId: template.id))
        }

        func handleEditTapped(_ template: Workout) {
            activeSheet = .edit(template)
        }

        func handleDuplicateTapped(_ template: Workout) {
            let copy = template.duplicate(existingNames: workouts.map(\.name))
            Task {
                do {
                    try await workoutTemplateRepository.save(entity: copy)
                } catch {
                    errorMessage = "\(template.name) couldn't be duplicated. Try again."
                }
            }
        }

        func handleDeleteTapped(_ template: Workout) {
            pendingDeletion = template
        }

        func confirmDeletion() {
            guard let template = pendingDeletion else { return }
            pendingDeletion = nil
            Task {
                do {
                    try await workoutTemplateRepository.delete(entity: template)
                } catch {
                    errorMessage = "\(template.name) couldn't be deleted. Try again."
                }
            }
        }

        // MARK: - Private Methods
        private func subscribeToWorkoutRepository() {
            workoutTemplateRepository
                .entitiesPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] workouts in
                    withAnimation(.snappy) {
                        self?.workouts = workouts
                    }
                }
                .store(in: &cancellables)
        }
    }
}
