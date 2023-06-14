//
//  WorkoutTemplateService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 18.06.2023.
//

import Foundation

protocol WorkoutTemplateServiceProtocol: Repository where T == WorkoutTemplate {
    
}

class WorkoutTemplateService: WorkoutTemplateServiceProtocol {
    
    private let repository: any WorkoutTemplateRepository
    private let watchCommunicator: WatchCommunicator
    
    init(repository: any WorkoutTemplateRepository, watchCommunicator: WatchCommunicator) {
        self.repository = repository
        self.watchCommunicator = watchCommunicator
    }
    
    func getAll() async throws -> [WorkoutTemplate] {
        return try await repository.getAll()
    }
    
    func save(entity: WorkoutTemplate) async throws -> WorkoutTemplate {
        let entity = try await repository.save(entity: entity)
        let updatedTemplates = try await repository.getAll()
        try watchCommunicator.send(workoutTemplates: updatedTemplates)
        return entity
    }
}

class MockedWorkoutTemplateService: WorkoutTemplateServiceProtocol {
    private let repository = MockedWorkoutTemplateRepository()
    
    func getAll() async throws -> [WorkoutTemplate] {
        return try await repository.getAll()
    }
    
    func save(entity: WorkoutTemplate) async throws -> WorkoutTemplate {
        return try await repository.save(entity: entity)
    }
}
