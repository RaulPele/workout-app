//
// HomeViewModel.swift
// WorkoutApp
//
// Created by Raul Pele on 02.05.2023.
//

import Combine
import Foundation
import SwiftUI

extension Home {

    @Observable class ViewModel {

        var workouts: [WorkoutSession] = []
        var isLoading = false

        private let workoutRepository: any WorkoutSessionRepository
        private let healthKitManager: HealthKitManager
        @ObservationIgnored weak var navigationManager: WorkoutSessionsNavigationManager?
        @ObservationIgnored private var cancellables = Set<AnyCancellable>()
        @ObservationIgnored private var loadTask: Task<Void, Never>?

        init(workoutRepository: any WorkoutSessionRepository,
             healthKitManager: HealthKitManager) {
            self.workoutRepository = workoutRepository
            self.healthKitManager = healthKitManager
            subscribeToWorkoutSessions()
            loadWorkouts()
        }

        func handleOnAppear() {
            loadWorkouts()
        }

        private func subscribeToWorkoutSessions() {
            workoutRepository
                .entitiesPublisher
                .sink { [weak self] sessions in
                    self?.workouts = sessions
                }
                .store(in: &cancellables)
        }

        private func loadWorkouts() {
            loadTask?.cancel()
            isLoading = true
            loadTask = Task { @MainActor [weak self] in
                defer { self?.isLoading = false }
                do {
                    try await self?.workoutRepository.loadData()
                } catch {
                    print("Error while loading workouts: \(error.localizedDescription)")
                }
            }
        }

        func handleWorkoutTapped(for session: WorkoutSession) {
            navigationManager?.push(WorkoutRoute(workout: session))
        }
    }
}
