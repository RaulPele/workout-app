//
//  WorkoutTemplateRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation
import Combine

//@MainActor
protocol WorkoutRepository: Repository where T == Workout {
    
}

class WorkoutLocalRepository: WorkoutRepository {

    private let localDataSource = SwiftDataDataSource<Workout>()
    private let manager = SwiftDataManager.shared
    private let workoutsSubject = CurrentValueSubject<[Workout], Never>([])

    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "WorkoutRepository"
    )

    var entitiesPublisher: AnyPublisher<[Workout], Never> {
        workoutsSubject.eraseToAnyPublisher()
    }

    func save(entity: Workout) async throws {
        logger.debug("Saving workout: \(entity.name) (ID: \(entity.id))")
        do {
            // Fetch existing workout by ID to update in place
            let entityId = entity.id
            let predicate = #Predicate<WorkoutDTO> { $0.id == entityId }
            let existing: [WorkoutDTO] = try await manager.fetch(predicate: predicate)
            if let existingDTO = existing.first {
                existingDTO.name = entity.name
                existingDTO.exercises = entity.exercises
                try await manager.saveContext()
            } else {
                try await localDataSource.save(entity: entity)
            }
            logger.info("Successfully saved workout: \(entity.name) (ID: \(entity.id))")
            try await loadData()
        } catch {
            logger.error("Failed to save workout: \(entity.name) (ID: \(entity.id)), error: \(error.localizedDescription)")
        }
    }
    
    func delete(entity: Workout) async throws {
        logger.debug("Deleting workout: \(entity.name) (ID: \(entity.id))")
        try await localDataSource.delete(entity: entity)
        logger.info("Successfully deleted workout: \(entity.name) (ID: \(entity.id))")
    }
    
    func loadData() async throws {
        logger.info("Loading workouts")
        let workouts = try await localDataSource.fetchAll()
        workoutsSubject.send(workouts)
    }
}

extension Workout: SwiftDataConvertible {
    
    var dto: WorkoutDTO {
        WorkoutDTO(from: self)
    }
    
}

class MockedWorkoutRepository: WorkoutRepository {
    
    func loadData() async throws {
        workoutsSubject.send(templates)
    }

    private var templates = [Workout.mockedWorkoutTemplate, .mockedWorkoutTemplate2()]

    // Reactive publishers
    private let workoutsSubject = CurrentValueSubject<[Workout], Never>([])

    var entitiesPublisher: AnyPublisher<[Workout], Never> {
        workoutsSubject.eraseToAnyPublisher()
    }

    func save(entity: Workout) async throws {
        templates.append(entity)
        workoutsSubject.send(templates)
    }
    
    func delete(entity: Workout) async throws {
        templates.removeAll { $0.id == entity.id }
        workoutsSubject.send(templates)
    }
}
