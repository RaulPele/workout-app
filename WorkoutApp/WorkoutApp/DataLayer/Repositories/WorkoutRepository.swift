//
//  WorkoutTemplateRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation
import Combine

// MARK: - Protocol
protocol WorkoutRepository: Repository where T == Workout {

    /// Deletes a template and republishes the list (which also resyncs the watch).
    func delete(entity: Workout) async throws

    /// Replaces the embedded copy of `definition` in every template that uses it,
    /// so renames and edits in the exercise library show up in existing workouts.
    func updateExerciseDefinition(_ definition: ExerciseDefinition) async throws
}

// MARK: - WorkoutLocalRepository
class WorkoutLocalRepository: WorkoutRepository {

    private let localDataSource = SwiftDataDataSource<Workout>()
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
            try await localDataSource.save(entity: entity)
            logger.info("Successfully saved workout: \(entity.name) (ID: \(entity.id))")
        } catch {
            logger.error("Failed to save workout: \(entity.name) (ID: \(entity.id)), error: \(error.localizedDescription)")
            throw error
        }
        try await loadData()
    }

    func delete(entity: Workout) async throws {
        logger.debug("Deleting workout: \(entity.name) (ID: \(entity.id))")
        try await localDataSource.delete(entity: entity)
        logger.info("Successfully deleted workout: \(entity.name) (ID: \(entity.id))")
        try await loadData()
    }

    func updateExerciseDefinition(_ definition: ExerciseDefinition) async throws {
        let workouts = try await localDataSource.fetchAll()
        let updated = workouts.compactMap { $0.replacingDefinition(definition) }
        guard !updated.isEmpty else { return }

        for workout in updated {
            try await localDataSource.save(entity: workout)
        }
        logger.info("Updated exercise \(definition.name) in \(updated.count) workouts")
        try await loadData()
    }

    func loadData() async throws {
        logger.info("Loading workouts")
        let workouts = try await localDataSource.fetchAll()
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        workoutsSubject.send(workouts)
    }
}

// MARK: - SwiftDataConvertible
extension Workout: SwiftDataConvertible {

    var dto: WorkoutDTO {
        WorkoutDTO(from: self)
    }

    func update(_ existingDTO: WorkoutDTO) {
        existingDTO.name = name
        existingDTO.exercises = exercises
    }
}

// MARK: - Definition Replacement
private extension Workout {

    /// A copy of this workout with `definition` swapped in, or `nil` if no exercise uses it.
    func replacingDefinition(_ definition: ExerciseDefinition) -> Workout? {
        guard exercises.contains(where: { $0.definition.id == definition.id }) else { return nil }

        let updatedExercises = exercises.map { exercise in
            guard exercise.definition.id == definition.id else { return exercise }
            return Exercise(
                id: exercise.id,
                definition: definition,
                numberOfSets: exercise.numberOfSets,
                setData: exercise.setData,
                restBetweenSets: exercise.restBetweenSets
            )
        }
        return Workout(id: id, name: name, exercises: updatedExercises)
    }
}

// MARK: - MockedWorkoutRepository
class MockedWorkoutRepository: WorkoutRepository {

    private var templates: [Workout]
    private let workoutsSubject = CurrentValueSubject<[Workout], Never>([])

    var entitiesPublisher: AnyPublisher<[Workout], Never> {
        workoutsSubject.eraseToAnyPublisher()
    }

    init(templates: [Workout] = [.mockedWorkoutTemplate, .mockedWorkoutTemplate2()]) {
        self.templates = templates
    }

    func loadData() async throws {
        workoutsSubject.send(templates)
    }

    func save(entity: Workout) async throws {
        if let index = templates.firstIndex(where: { $0.id == entity.id }) {
            templates[index] = entity
        } else {
            templates.append(entity)
        }
        workoutsSubject.send(templates)
    }

    func delete(entity: Workout) async throws {
        templates.removeAll { $0.id == entity.id }
        workoutsSubject.send(templates)
    }

    func updateExerciseDefinition(_ definition: ExerciseDefinition) async throws {
        templates = templates.map { $0.replacingDefinition(definition) ?? $0 }
        workoutsSubject.send(templates)
    }
}
