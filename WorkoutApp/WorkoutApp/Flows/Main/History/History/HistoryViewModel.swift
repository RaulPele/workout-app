//
//  HistoryViewModel.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Combine
import Foundation
import Observation

// MARK: - HistoryViewModel
@MainActor
@Observable
final class HistoryViewModel {

    // MARK: - Properties
    var loadErrorMessage: String?
    private(set) var sessions: [WorkoutSession] = []
    private(set) var hasLoaded = false

    @ObservationIgnored private let workoutRepository: any WorkoutSessionRepository
    @ObservationIgnored weak var navigationManager: WorkoutSessionsNavigationManager?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var sections: [SessionSection] {
        SessionSection.grouped(sessions)
    }

    var weekSummary: WeekSummary {
        WeekSummary(sessions: sessions)
    }

    var isEmpty: Bool {
        hasLoaded && sessions.isEmpty && loadErrorMessage == nil
    }

    var showsLoadError: Bool {
        sessions.isEmpty && loadErrorMessage != nil
    }

    // MARK: - Initializers
    init(workoutRepository: any WorkoutSessionRepository, navigationManager: WorkoutSessionsNavigationManager) {
        self.workoutRepository = workoutRepository
        self.navigationManager = navigationManager
        subscribeToSessions()
    }

    // MARK: - Public Methods
    func load() async {
        do {
            try await workoutRepository.loadData()
            loadErrorMessage = nil
        } catch {
            loadErrorMessage = "Your sessions couldn't be loaded from Apple Health."
        }
        hasLoaded = true
    }

    func handleSessionTapped(_ session: WorkoutSession) {
        navigationManager?.push(WorkoutRoute(workout: session))
    }

    // MARK: - Private Methods
    private func subscribeToSessions() {
        workoutRepository.entitiesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] sessions in
                self?.sessions = sessions
            }
            .store(in: &cancellables)
    }
}
