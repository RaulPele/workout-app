//
//  WorkoutTemplateRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation

protocol WorkoutRepository: Repository where T == Workout {
    
}

@MainActor //I dont like this
class WorkoutLocalRepository: WorkoutRepository {
    
    private let localDataSource = SwiftDataDataSource<Workout>()
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "WorkoutRepository"
    )
    
    func getAll() async throws -> [Workout] {
        logger.debug("Fetching all workouts")
        do {
            let workouts = try await localDataSource.fetchAll()
            logger.info("Successfully fetched \(workouts.count) workouts")
            return workouts
        } catch {
            logger.error("Failed to fetch workouts: \(error.localizedDescription)")
            throw error
        }
    }
    
    func save(entity: Workout) async throws -> Workout {
        logger.debug("Saving workout: \(entity.name) (ID: \(entity.id))")
        do {
            try await localDataSource.save(entity: entity)
            logger.info("Successfully saved workout: \(entity.name) (ID: \(entity.id))")
            return entity
        } catch {
            logger.error("Failed to save workout: \(entity.name) (ID: \(entity.id)), error: \(error.localizedDescription)")
            throw error
        }
    }
    

}

extension Workout: SwiftDataConvertible {
    
    var dto: WorkoutDTO {
        WorkoutDTO(from: self)
    }
    
}

class MockedWorkoutRepository: WorkoutRepository {
    
    private var templates = [Workout]()
    
    func getAll() async throws -> [Workout] {
        return templates
    }
    
    func save(entity: Workout) async throws -> Workout {
        templates.append(entity)
        return entity
    }
}
