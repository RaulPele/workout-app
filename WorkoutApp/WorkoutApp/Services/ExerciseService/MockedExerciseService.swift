//
//  MockedExerciseService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 18.06.2023.
//

import Foundation

class MockedExerciseService: ExerciseServiceProtocol {
    let exerciseRepository = MockedExerciseRepository()
    
    func getAll() async throws -> [Exercise] {
        return try await exerciseRepository.getAll()
    }
    
    func save(exercise: Exercise) async throws -> Exercise {
        try await exerciseRepository.save(entity: exercise)
        return exercise
    }
}
