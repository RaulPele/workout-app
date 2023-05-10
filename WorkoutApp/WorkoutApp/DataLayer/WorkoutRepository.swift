//
//  WorkoutRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation
import HealthKit

protocol WorkoutRepository: Repository where T == Workout {
    
}

class WorkoutAPIRepository: WorkoutRepository {
    
    private let workoutService: WorkoutService
    private let healthKitManager = HealthKitManager()
    private let workoutParser: WorkoutParser
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
        self.workoutParser = WorkoutParser(healthKitManager: healthKitManager)
    }
    
    func getAll() async throws -> [Workout] {
        let hkWorkouts = try await healthKitManager.loadWorkouts()
        return try await workoutParser.toModelWorkouts(hkWorkouts)
    }
}


class MockedWorkoutRepository: WorkoutRepository {
    
    private let workoutService: WorkoutService = MockedWorkoutService()
    
    func getAll() async throws -> [Workout] {
        return try await workoutService.getAll()
    }
}
