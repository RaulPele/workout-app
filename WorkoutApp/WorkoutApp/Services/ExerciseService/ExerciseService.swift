//
//  ExerciseService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 18.06.2023.
//

import Foundation

protocol ExerciseServiceProtocol {
    func getAll() async throws -> [Exercise]
    @discardableResult func save(exercise: Exercise) async throws -> Exercise
}

class ExerciseService: ExerciseServiceProtocol {
    
    private let exerciseRepository: any ExerciseRepositoryProtocol
    
    init(exerciseRepository: any ExerciseRepositoryProtocol) {
        self.exerciseRepository = exerciseRepository
    }
    
    func getAll() async throws -> [Exercise] {
        return try await exerciseRepository.getAll()
    }
    
    func save(exercise: Exercise) async throws -> Exercise {
        return try await exerciseRepository.save(entity: exercise)
    }
}
