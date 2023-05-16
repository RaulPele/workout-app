//
//  WorkoutTemplateRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation

protocol WorkoutTemplateRepository: Repository where T == WorkoutTemplate {
    
}

class WorkoutTemplateLocalRepository: WorkoutTemplateRepository {
    
    func getAll() async throws -> [WorkoutTemplate] {
        return try FileIOManager.readAll(from: .workoutTemplates)
    }
    
    func save(entity: WorkoutTemplate) async throws -> WorkoutTemplate {
        try FileIOManager.write(entity: entity, toDirectory: .workoutTemplates)
        return entity
    }
    
    
}
