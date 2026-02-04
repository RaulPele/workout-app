//
//  DependencyContainer.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation

class DependencyContainer {
    let workoutRepository: any WorkoutSessionRepository
    let healthKitManager: HealthKitManager
    let watchCommunicator: WatchCommunicator
    let exerciseRepository: any ExerciseRepositoryProtocol
    let workoutTemplateRepository: any WorkoutRepository

    init(workoutRepository: any WorkoutSessionRepository,
         workoutTemplateRepository: any WorkoutRepository,
         exerciseRepository: any ExerciseRepositoryProtocol,
         healthKitManager: HealthKitManager,
         watchCommunicator: WatchCommunicator
    ) {
        self.workoutRepository = workoutRepository
        self.workoutTemplateRepository = workoutTemplateRepository
        self.exerciseRepository = exerciseRepository
        self.healthKitManager = healthKitManager
        self.watchCommunicator = watchCommunicator
    }
}

class MockedDependencyContainer: DependencyContainer {
    init() {
        let workoutTemplateRepository = MockedWorkoutRepository()
        super.init(
            workoutRepository: MockedWorkoutSessionRepository(),
            workoutTemplateRepository: workoutTemplateRepository,
            exerciseRepository: MockedExerciseRepository(),
            healthKitManager: HealthKitManager(),
            watchCommunicator: WatchCommunicator(workoutRepository: workoutTemplateRepository)
        )
    }
}
