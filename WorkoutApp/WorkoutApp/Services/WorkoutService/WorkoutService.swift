//
//  WorkoutTemplateService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 18.06.2023.
//

import Foundation

protocol WorkoutServiceProtocol: Repository where T == Workout {
    
}

class WorkoutService: WorkoutServiceProtocol {
    
    private let repository: any WorkoutRepository
    private let watchCommunicator: WatchCommunicator
    
    init(repository: any WorkoutRepository, watchCommunicator: WatchCommunicator) {
        self.repository = repository
        self.watchCommunicator = watchCommunicator
    }
    
    func getAll() async throws -> [Workout] {
        return try await repository.getAll()
    }
    
    func save(entity: Workout) async throws -> Workout {
        let entity = try await repository.save(entity: entity)
        let updatedTemplates = try await repository.getAll()
        try watchCommunicator.send(workoutTemplates: updatedTemplates)
        return entity
    }
}

class MockedWorkoutService: WorkoutServiceProtocol {
    private let repository = MockedWorkoutRepository()
    
    func getAll() async throws -> [Workout] {
        return try await repository.getAll()
    }
    
    func save(entity: Workout) async throws -> Workout {
        return try await repository.save(entity: entity)
    }
}

