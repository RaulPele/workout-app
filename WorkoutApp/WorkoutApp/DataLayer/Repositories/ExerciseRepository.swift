//
//  ExerciseRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 18.06.2023.
//

import Foundation

protocol ExerciseRepositoryProtocol: Repository where T == Exercise {
    
}

class ExerciseRepository: ExerciseRepositoryProtocol {
    
    func getAll() async throws -> [Exercise] {
        try FileIOManager.readAll(from: .exercises)
    }
    
    func save(entity: Exercise) async throws -> Exercise {
        try FileIOManager.write(entity: entity, toDirectory: .exercises)
        return entity
    }
}

class MockedExerciseRepository: ExerciseRepositoryProtocol {
    
    var exercises = [Exercise]()
    
    func getAll() async throws -> [Exercise] {
        return exercises
    }
    
    func save(entity: Exercise) async throws -> Exercise {
//        try FileIOManager.write(entity: entity, toDirectory: .exercises)
        exercises.append(entity)
        return entity
    }
}
