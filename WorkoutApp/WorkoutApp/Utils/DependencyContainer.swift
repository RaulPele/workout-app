//
//  DependencyContainer.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation

// MARK: - Protocol
protocol DependencyContainerProtocol {
    var workoutRepository: any WorkoutSessionRepository { get }
    var healthKitManager: HealthKitManager { get }
    var watchCommunicator: any WatchCommunicatorProtocol { get }
    var exerciseRepository: any ExerciseRepositoryProtocol { get }
    var workoutTemplateRepository: any WorkoutRepository { get }
}

// MARK: - Live Implementation
struct DependencyContainer: DependencyContainerProtocol {
    let workoutRepository: any WorkoutSessionRepository
    let healthKitManager: HealthKitManager
    let watchCommunicator: any WatchCommunicatorProtocol
    let exerciseRepository: any ExerciseRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository

    @MainActor static func live() -> DependencyContainer {
        let healthKitManager = HealthKitManager()
        let workoutRepository = WorkoutSessionAPIRepository(healthKitManager: healthKitManager)
        let exerciseRepository = ExerciseRepository()
        let workoutTemplateRepository = WorkoutLocalRepository()
        let watchCommunicator = WatchCommunicator(
            workoutRepository: workoutTemplateRepository,
            workoutSessionRepository: workoutRepository
        )

        return DependencyContainer(
            workoutRepository: workoutRepository,
            healthKitManager: healthKitManager,
            watchCommunicator: watchCommunicator,
            exerciseRepository: exerciseRepository,
            workoutTemplateRepository: workoutTemplateRepository
        )
    }
}

// MARK: - Mocked Implementation
struct MockedDependencyContainer: DependencyContainerProtocol {
    let workoutRepository: any WorkoutSessionRepository
    let healthKitManager: HealthKitManager
    let watchCommunicator: any WatchCommunicatorProtocol
    let exerciseRepository: any ExerciseRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository

    init() {
        let workoutTemplateRepository = MockedWorkoutRepository()
        self.workoutRepository = MockedWorkoutSessionRepository()
        self.workoutTemplateRepository = workoutTemplateRepository
        self.exerciseRepository = MockedExerciseRepository()
        self.healthKitManager = HealthKitManager()
        self.watchCommunicator = MockedWatchCommunicator()
    }
}
