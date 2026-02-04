//
//  ExerciseRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 18.06.2023.
//

import Combine
import Foundation

protocol ExerciseRepositoryProtocol: Repository where T == Exercise {}

@MainActor
class ExerciseRepository: ExerciseRepositoryProtocol {

    private let localDataSource = SwiftDataDataSource<Exercise>()
    private let exercisesSubject = CurrentValueSubject<[Exercise], Never>([])
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "ExerciseRepository"
    )

    var entitiesPublisher: AnyPublisher<[Exercise], Never> {
        exercisesSubject.eraseToAnyPublisher()
    }

    func loadData() async throws {
        logger.debug("Fetching all exercises")
        do {
            let exercises = try await localDataSource.fetchAll()
            logger.info("Successfully fetched \(exercises.count) exercises")
            exercisesSubject.send(exercises)
        } catch {
            logger.error("Failed to fetch exercises: \(error.localizedDescription)")
            throw error
        }
    }

    func save(entity: Exercise) async throws {
        logger.debug("Saving exercise: \(entity.name) (ID: \(entity.id))")
        do {
            try await localDataSource.save(entity: entity)
            logger.info("Successfully saved exercise: \(entity.name) (ID: \(entity.id))")
            try await loadData()
        } catch {
            logger.error("Failed to save exercise: \(entity.name) (ID: \(entity.id)), error: \(error.localizedDescription)")
            throw error
        }
    }
}

class MockedExerciseRepository: ExerciseRepositoryProtocol {

    private var exercises = [Exercise]()
    private let exercisesSubject = CurrentValueSubject<[Exercise], Never>([])

    var entitiesPublisher: AnyPublisher<[Exercise], Never> {
        exercisesSubject.eraseToAnyPublisher()
    }

    func loadData() async throws {
        exercisesSubject.send(exercises)
    }

    func save(entity: Exercise) async throws {
        exercises.append(entity)
        exercisesSubject.send(exercises)
    }
}

extension Exercise: SwiftDataConvertible {

    var dto: ExerciseDTO {
        ExerciseDTO(id: id, name: name, numberOfSets: numberOfSets, setData: setData, restBetweenSets: restBetweenSets)
    }
}
