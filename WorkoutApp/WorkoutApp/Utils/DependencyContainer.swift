//
//  DependencyContainer.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.04.2023.
//

import Foundation

class DependencyContainer {
    let authenticationService: AuthenticationServiceProtocol
    let workoutRepository: any WorkoutSessionRepository
    let workoutService: WorkoutSessionService
    let healthKitManager: HealthKitManager
    let watchCommunicator: WatchCommunicator
    let exerciseService: any ExerciseServiceProtocol
    let workoutTemplateService: any WorkoutServiceProtocol
    
    init(authenticationService: AuthenticationServiceProtocol,
         workoutService: WorkoutSessionService,
         workoutRepository: any WorkoutSessionRepository,
         healthKitManager: HealthKitManager,
         exerciseService: any ExerciseServiceProtocol,
         workoutTemplateService: any WorkoutServiceProtocol,
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
                   workoutService: MockedWorkoutSessionService(),
                   workoutRepository: MockedWorkoutSessionRepository(),
                   healthKitManager: HealthKitManager(),
                   exerciseService: MockedExerciseService(),
                   workoutTemplateService: MockedWorkoutService(),
                   watchCommunicator: WatchCommunicator()
        )
    }
}
