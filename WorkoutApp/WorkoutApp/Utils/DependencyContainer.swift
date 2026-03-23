//
//  DependencyContainer.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation
import SwiftUI

// MARK: - Protocol
protocol DependencyContainerProtocol {
    var workoutRepository: any WorkoutSessionRepository { get }
    var healthKitManager: any HealthKitManagerProtocol { get }
    var watchCommunicator: any WatchCommunicatorProtocol { get }
    var exerciseRepository: any ExerciseRepositoryProtocol { get }
    var workoutTemplateRepository: any WorkoutRepository { get }
    var exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol { get }
}

// MARK: - Live Implementation
struct DependencyContainer: DependencyContainerProtocol {

    let workoutRepository: any WorkoutSessionRepository
    let healthKitManager: any HealthKitManagerProtocol
    let watchCommunicator: any WatchCommunicatorProtocol
    let exerciseRepository: any ExerciseRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository
    let exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol

    static func live() -> DependencyContainer {
        let healthKitManager = HealthKitManager()
        let workoutRepository = WorkoutSessionAPIRepository(healthKitManager: healthKitManager)
        let exerciseRepository = ExerciseRepository()
        let workoutTemplateRepository = WorkoutLocalRepository()
        let watchCommunicator = WatchCommunicator(
            workoutRepository: workoutTemplateRepository,
            workoutSessionRepository: workoutRepository
        )
        let apiClient = APIClient(baseURL: Constants.apiBaseURL)
        let exerciseDefinitionRepository = ExerciseDefinitionRepository(apiClient: apiClient)

        return DependencyContainer(
            workoutRepository: workoutRepository,
            healthKitManager: healthKitManager,
            watchCommunicator: watchCommunicator,
            exerciseRepository: exerciseRepository,
            workoutTemplateRepository: workoutTemplateRepository,
            exerciseDefinitionRepository: exerciseDefinitionRepository
        )
    }
}

// MARK: - Environment Key
private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: any DependencyContainerProtocol = MockedDependencyContainer()
}

extension EnvironmentValues {
    var dependencyContainer: any DependencyContainerProtocol {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

// MARK: - Mocked Implementation
struct MockedDependencyContainer: DependencyContainerProtocol {
    let workoutRepository: any WorkoutSessionRepository
    let healthKitManager: any HealthKitManagerProtocol
    let watchCommunicator: any WatchCommunicatorProtocol
    let exerciseRepository: any ExerciseRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository
    let exerciseDefinitionRepository: any ExerciseDefinitionRepositoryProtocol

    init() {
        let workoutTemplateRepository = MockedWorkoutRepository()
        self.workoutRepository = MockedWorkoutSessionRepository()
        self.workoutTemplateRepository = workoutTemplateRepository
        self.exerciseRepository = MockedExerciseRepository()
        self.healthKitManager = MockedHealthKitManager()
        self.watchCommunicator = MockedWatchCommunicator()
        self.exerciseDefinitionRepository = MockedExerciseDefinitionRepository()
    }
}
