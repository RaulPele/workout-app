//
//  WorkoutRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation

protocol WorkoutRepository: Repository where T == Workout {
    
}

class WorkoutAPIRepository: WorkoutRepository {
    
    private let workoutService: WorkoutService
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }
    
    func getAll() async throws -> [Workout] {
        return try await workoutService.getAll()
    }
}


class MockedWorkoutRepository: WorkoutRepository {
    
    private let workoutService: WorkoutService = MockedWorkoutService()
    
    func getAll() async throws -> [Workout] {
        return try await workoutService.getAll()
    }
}
