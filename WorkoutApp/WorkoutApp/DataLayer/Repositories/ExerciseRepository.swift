//
//  ExerciseRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 18.06.2023.
//

import Foundation

protocol ExerciseRepositoryProtocol: Repository where T == Exercise {
    
}

@MainActor
class ExerciseRepository: ExerciseRepositoryProtocol {
    
    private let localDataSource = SwiftDataDataSource<Exercise>()
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "ExerciseRepository"
    )
    
    func getAll() async throws -> [Exercise] {
        logger.debug("Fetching all exercises")
        do {
            let exercises = try await localDataSource.fetchAll()
            logger.info("Successfully fetched \(exercises.count) exercises")
            return exercises
        } catch {
            logger.error("Failed to fetch exercises: \(error.localizedDescription)")
            throw error
        }
    }
    
    func save(entity: Exercise) async throws -> Exercise {
        logger.debug("Saving exercise: \(entity.name) (ID: \(entity.id))")
        do {
            try await localDataSource.save(entity: entity)
            logger.info("Successfully saved exercise: \(entity.name) (ID: \(entity.id))")
            return entity
        } catch {
            logger.error("Failed to save exercise: \(entity.name) (ID: \(entity.id)), error: \(error.localizedDescription)")
            throw error
        }
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
extension Exercise: SwiftDataConvertible {
    
    var dto: ExerciseDTO {
        return ExerciseDTO(id: id, name: name, numberOfSets: numberOfSets, setData: setData, restBetweenSets: restBetweenSets)
    }
}

