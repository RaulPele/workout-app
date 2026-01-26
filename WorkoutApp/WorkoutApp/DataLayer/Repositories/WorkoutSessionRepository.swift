//
//  WorkoutRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation
import HealthKit

protocol WorkoutSessionRepository: Repository where T == WorkoutSession {
    
}

class WorkoutSessionAPIRepository: WorkoutSessionRepository {
    
    private let workoutService: WorkoutSessionService
    private let healthKitManager: HealthKitManager
    
    init(workoutService: WorkoutSessionService,
         healthKitManager: HealthKitManager) {
        self.workoutService = workoutService
        self.healthKitManager = healthKitManager
    }
    
    func getAll() async throws -> [WorkoutSession] {
        let hkWorkouts = try await healthKitManager.loadWorkouts()
        
        let workouts = hkWorkouts.compactMap { hkWorkout in
            let workout: WorkoutSession? = try? FileIOManager.read(forId: hkWorkout.uuid, fromDirectory: .workoutSessions)
            return workout
        }
        
        return workouts
    }
    
    func save(entity: WorkoutSession) async throws -> WorkoutSession {
        try FileIOManager.write(entity: entity, toDirectory: .workoutSessions)
        return entity
    }
    
    //TODO: implement delete
}


class MockedWorkoutSessionRepository: WorkoutSessionRepository {
    
    func save(entity: WorkoutSession) async throws -> WorkoutSession {
        
        return entity
    }
    
    
    private let workoutService: WorkoutSessionService = MockedWorkoutSessionService()
    
    func getAll() async throws -> [WorkoutSession] {
        return try await workoutService.getAll()
    }
}

class MockedWorkoutSessionEmptyRepository: WorkoutSessionRepository {
    func save(entity: WorkoutSession) async throws -> WorkoutSession {
        return entity
    }
    
    func getAll() async throws -> [WorkoutSession] {
        return []
    }
}
