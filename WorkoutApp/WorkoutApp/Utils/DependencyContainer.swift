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
    
    init(authenticationService: AuthenticationServiceProtocol,
         workoutService: WorkoutService,
         workoutRepository: any WorkoutRepository,
         healthKitManager: HealthKitManager) {
        self.authenticationService = authenticationService
        self.workoutService = workoutService
        self.workoutRepository = workoutRepository
        self.healthKitManager = healthKitManager
        
    }
}

class MockedDependencyContainer: DependencyContainer {
    init() {
        super.init(authenticationService: MockedAuthenticationService(),
                   workoutService: MockedWorkoutService(),
                   workoutRepository: MockedWorkoutRepository(),
                   healthKitManager: HealthKitManager()
        )
    }
}
