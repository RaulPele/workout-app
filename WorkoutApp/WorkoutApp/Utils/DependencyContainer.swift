//
//  DependencyContainer.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation

class DependencyContainer {
    let authenticationService: AuthenticationServiceProtocol
    let workoutRepository: any WorkoutRepository
    let workoutService: WorkoutService
    let healthKitManager: HealthKitManager
    let watchCommunicator: WatchCommunicator
    let exerciseService: any ExerciseServiceProtocol
    let workoutTemplateService: any WorkoutTemplateServiceProtocol
    
    init(authenticationService: AuthenticationServiceProtocol,
         workoutService: WorkoutService,
         workoutRepository: any WorkoutRepository,
         healthKitManager: HealthKitManager,
         exerciseService: any ExerciseServiceProtocol,
         workoutTemplateService: any WorkoutTemplateServiceProtocol,
         watchCommunicator: WatchCommunicator
    ) {
        self.authenticationService = authenticationService
        self.workoutService = workoutService
        self.workoutRepository = workoutRepository
        self.healthKitManager = healthKitManager
        self.exerciseService = exerciseService
        self.workoutTemplateService = workoutTemplateService
        self.watchCommunicator = watchCommunicator
        
    }
}

class MockedDependencyContainer: DependencyContainer {
    init() {
        super.init(authenticationService: MockedAuthenticationService(),
                   workoutService: MockedWorkoutService(),
                   workoutRepository: MockedWorkoutRepository(),
                   healthKitManager: HealthKitManager(),
                   exerciseService: MockedExerciseService(),
                   workoutTemplateService: MockedWorkoutTemplateService(),
                   watchCommunicator: WatchCommunicator()
        )
    }
}
