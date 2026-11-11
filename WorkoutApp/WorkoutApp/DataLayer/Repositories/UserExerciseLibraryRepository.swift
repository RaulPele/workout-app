//
//  UserExerciseLibraryRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.05.2026.
//

import Combine
import Foundation

// MARK: - Protocol
protocol UserExerciseLibraryRepositoryProtocol: Repository where T == ExerciseDefinition {
    func delete(entity: ExerciseDefinition) async throws
}

// MARK: - Live Implementation
class UserExerciseLibraryRepository: UserExerciseLibraryRepositoryProtocol {

    // MARK: - Properties
    private let localDataSource = SwiftDataDataSource<ExerciseDefinition>()
    private let definitionsSubject = CurrentValueSubject<[ExerciseDefinition], Never>([])
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "UserExerciseLibraryRepository"
    )

    var entitiesPublisher: AnyPublisher<[ExerciseDefinition], Never> {
        definitionsSubject.eraseToAnyPublisher()
    }

    // MARK: - Repository
    func loadData() async throws {
        let definitions = try await localDataSource.fetchAll()
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        definitionsSubject.send(definitions)
    }

    func save(entity: ExerciseDefinition) async throws {
        logger.debug("Saving user exercise definition: \(entity.name) (\(entity.id))")
        try await localDataSource.save(entity: entity)
        logger.info("Saved user exercise definition: \(entity.name) (\(entity.id))")
        try await loadData()
    }

    func delete(entity: ExerciseDefinition) async throws {
        logger.debug("Deleting user exercise definition: \(entity.name) (\(entity.id))")
        try await localDataSource.delete(entity: entity)
        try await loadData()
    }
}

// MARK: - SwiftDataConvertible
extension ExerciseDefinition: SwiftDataConvertible {

    var dto: UserExerciseDefinitionDTO {
        UserExerciseDefinitionDTO(from: self)
    }

    func update(_ existingDTO: UserExerciseDefinitionDTO) {
        existingDTO.apply(self)
    }
}

// MARK: - Mocked Implementation
class MockedUserExerciseLibraryRepository: UserExerciseLibraryRepositoryProtocol {

    private var definitions: [ExerciseDefinition]
    private let definitionsSubject = CurrentValueSubject<[ExerciseDefinition], Never>([])

    var entitiesPublisher: AnyPublisher<[ExerciseDefinition], Never> {
        definitionsSubject.eraseToAnyPublisher()
    }

    init(seed: [ExerciseDefinition] = []) {
        self.definitions = seed
        definitionsSubject.send(seed)
    }

    func loadData() async throws {
        definitionsSubject.send(definitions)
    }

    func save(entity: ExerciseDefinition) async throws {
        if let index = definitions.firstIndex(where: { $0.id == entity.id }) {
            definitions[index] = entity
        } else {
            definitions.append(entity)
        }
        definitions.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        definitionsSubject.send(definitions)
    }

    func delete(entity: ExerciseDefinition) async throws {
        definitions.removeAll { $0.id == entity.id }
        definitionsSubject.send(definitions)
    }
}
