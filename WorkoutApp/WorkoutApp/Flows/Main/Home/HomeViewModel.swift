//
// HomeViewModel.swift
// WorkoutApp
//
// Created by Raul Pele on 02.05.2023.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Workout Session Group
struct WorkoutSessionGroup: Identifiable {
    let id: String
    let title: String
    let sessions: [WorkoutSession]
}

extension Home {

    @Observable class ViewModel {

        // MARK: - Properties
        var workouts: [WorkoutSession] = []
        var isLoading = false

        private let workoutRepository: any WorkoutSessionRepository
        private let healthKitManager: any HealthKitManagerProtocol
        @ObservationIgnored weak var navigationManager: WorkoutSessionsNavigationManager?
        @ObservationIgnored private var cancellables = Set<AnyCancellable>()
        @ObservationIgnored private var loadTask: Task<Void, Never>?

        var groupedWorkouts: [WorkoutSessionGroup] {
            let calendar = Calendar.current
            let now = Date.now

            var today: [WorkoutSession] = []
            var yesterday: [WorkoutSession] = []
            var thisWeek: [WorkoutSession] = []
            var thisMonth: [WorkoutSession] = []
            var earlier: [WorkoutSession] = []

            let sorted = workouts.sorted { ($0.endDate ?? .distantPast) > ($1.endDate ?? .distantPast) }

            for session in sorted {
                let date = session.endDate ?? .distantPast
                if calendar.isDateInToday(date) {
                    today.append(session)
                } else if calendar.isDateInYesterday(date) {
                    yesterday.append(session)
                } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
                    thisWeek.append(session)
                } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
                    thisMonth.append(session)
                } else {
                    earlier.append(session)
                }
            }

            return [
                WorkoutSessionGroup(id: "today", title: "Today", sessions: today),
                WorkoutSessionGroup(id: "yesterday", title: "Yesterday", sessions: yesterday),
                WorkoutSessionGroup(id: "thisWeek", title: "This Week", sessions: thisWeek),
                WorkoutSessionGroup(id: "thisMonth", title: "This Month", sessions: thisMonth),
                WorkoutSessionGroup(id: "earlier", title: "Earlier", sessions: earlier),
            ].filter { !$0.sessions.isEmpty }
        }

        // MARK: - Initializer
        init(workoutRepository: any WorkoutSessionRepository,
             healthKitManager: any HealthKitManagerProtocol,
             navigationManager: WorkoutSessionsNavigationManager) {
            self.workoutRepository = workoutRepository
            self.healthKitManager = healthKitManager
            self.navigationManager = navigationManager
            subscribeToWorkoutSessions()
            loadWorkouts()
        }

        // MARK: - Public Methods
        func refreshWorkouts() async {
            do {
                try await workoutRepository.loadData()
            } catch {
                print("Error while loading workouts: \(error.localizedDescription)")
            }
        }

        func handleWorkoutTapped(for session: WorkoutSession) {
            navigationManager?.push(WorkoutRoute(workout: session))
        }

        // MARK: - Private Methods
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
    }
}
