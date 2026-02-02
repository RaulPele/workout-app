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

@MainActor
class WorkoutLocalRepository: @MainActor WorkoutRepository {
    
    private let localDataSource = SwiftDataDataSource<Workout>()
    private let workoutsSubject = CurrentValueSubject<[Workout], Never>([])
    
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "WorkoutRepository"
    )
    
    var entitiesPublisher: AnyPublisher<[Workout], Never> {
        workoutsSubject.eraseToAnyPublisher()
    }
    
    init() {

    }
    
    func save(entity: Workout) async throws {
            logger.debug("Saving workout: \(entity.name) (ID: \(entity.id))")
            do {
                try await localDataSource.save(entity: entity)
                logger.info("Successfully saved workout: \(entity.name) (ID: \(entity.id))")
                try await loadData()
            } catch {
                logger.error("Failed to save workout: \(entity.name) (ID: \(entity.id)), error: \(error.localizedDescription)")
            }
    }
    
    func delete(entity: Workout) {
        Task {
            logger.debug("Deleting workout: \(entity.name) (ID: \(entity.id))")
            do {
                try await localDataSource.delete(entity: entity)
                logger.info("Successfully deleted workout: \(entity.name) (ID: \(entity.id))")
//                await emitCurrentState()
            } catch {
                logger.error("Failed to delete workout: \(entity.name) (ID: \(entity.id)), error: \(error.localizedDescription)")
//                errorSubject.send(error)
            }
        }
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
        
    }
    
    
    private var templates = [Workout]()
    
    // Reactive publishers
    private let workoutsSubject = CurrentValueSubject<[Workout], Never>([])
    private let errorSubject = PassthroughSubject<Error, Never>()
    
    var entitiesPublisher: AnyPublisher<[Workout], Never> {
        workoutsSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    func save(entity: Workout) {
        templates.append(entity)
        workoutsSubject.send(templates)
    }
    
    func delete(entity: Workout) {
        templates.removeAll { $0.id == entity.id }
        workoutsSubject.send(templates)
    }
    
    func refresh() {
        workoutsSubject.send(templates)
    }
}
