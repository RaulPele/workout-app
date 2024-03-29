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
    private let healthKitManager: HealthKitManager
    
    init(workoutService: WorkoutService,
         healthKitManager: HealthKitManager) {
        self.workoutService = workoutService
        self.healthKitManager = healthKitManager
    }
    
    func getAll() async throws -> [Workout] {
        let hkWorkouts = try await healthKitManager.loadWorkouts()
        
        let workouts = hkWorkouts.compactMap { hkWorkout in
            let workout: Workout? = try? FileIOManager.read(forId: hkWorkout.uuid, fromDirectory: .workoutSessions)
            return workout
        }
        
        return workouts
    }
    
    func save(entity: Workout) async throws -> Workout {
        try FileIOManager.write(entity: entity, toDirectory: .workoutSessions)
        return entity
    }
    
    //TODO: implement delete
}


class MockedWorkoutRepository: WorkoutRepository {
    
    func save(entity: Workout) async throws -> Workout {
        
        return entity
    }
    
    
    private let workoutService: WorkoutService = MockedWorkoutService()
    
    func getAll() async throws -> [Workout] {
        return try await workoutService.getAll()
    }
}

class MockedWorkoutEmptyRepository: WorkoutRepository {
    func save(entity: Workout) async throws -> Workout {
        return entity
    }
    
    func getAll() async throws -> [Workout] {
        return []
    }
}
