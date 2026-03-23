//
//  ExerciseDefinitionRepository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.03.2026.
//

import Combine
import Foundation
import SwiftData

// MARK: - Protocol
protocol ExerciseDefinitionRepositoryProtocol {
    var definitionsPublisher: AnyPublisher<[ExerciseDefinition], Never> { get }
    func loadDefinitions(muscle: MuscleGroup?, equipment: Equipment?,
                         category: ExerciseCategory?, page: Int) async throws
    func search(query: String) async throws -> [ExerciseDefinition]
    func getDefinition(id: String) async throws -> ExerciseDefinition?
}

// MARK: - Live Implementation
class ExerciseDefinitionRepository: ExerciseDefinitionRepositoryProtocol {

    // MARK: - Properties
    private let apiClient: any APIClientProtocol
    private let swiftDataManager: SwiftDataManager
    private let definitionsSubject = CurrentValueSubject<[ExerciseDefinition], Never>([])
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "ExerciseDefinitionRepository"
    )

    var definitionsPublisher: AnyPublisher<[ExerciseDefinition], Never> {
        definitionsSubject.eraseToAnyPublisher()
    }

    // MARK: - Initializers
    init(apiClient: any APIClientProtocol, swiftDataManager: SwiftDataManager = .shared) {
        self.apiClient = apiClient
        self.swiftDataManager = swiftDataManager
    }

    // MARK: - Public Methods
    func loadDefinitions(muscle: MuscleGroup? = nil, equipment: Equipment? = nil,
                         category: ExerciseCategory? = nil, page: Int = 0) async throws {
        // Emit cached data first
        let cached: [ExerciseDefinitionDTO] = try await swiftDataManager.fetchAll()
        if !cached.isEmpty {
            definitionsSubject.send(cached.map { $0.toDomain() })
        }

        // Fetch from API
        let endpoint = Endpoint.exercises(muscle: muscle, equipment: equipment, category: category, page: page)
        let response: PaginatedResponse<ExerciseDefinition> = try await apiClient.request(endpoint)
        logger.info("Fetched \(response.content.count) definitions from API (page \(page)/\(response.totalPages))")

        // Cache results
        for definition in response.content {
            let dto = ExerciseDefinitionDTO(from: definition)
            try await swiftDataManager.save(dto)
        }

        // Re-emit with fresh data
        let updated: [ExerciseDefinitionDTO] = try await swiftDataManager.fetchAll()
        definitionsSubject.send(updated.map { $0.toDomain() })
    }

    func search(query: String) async throws -> [ExerciseDefinition] {
        let endpoint = Endpoint.searchExercises(query: query)
        let response: PaginatedResponse<ExerciseDefinition> = try await apiClient.request(endpoint)
        logger.info("Search '\(query)' returned \(response.content.count) results")
        return response.content
    }

    func getDefinition(id: String) async throws -> ExerciseDefinition? {
        let endpoint = Endpoint.exercise(id: id)
        let definition: ExerciseDefinition = try await apiClient.request(endpoint)
        return definition
    }
}

// MARK: - Mocked Implementation
class MockedExerciseDefinitionRepository: ExerciseDefinitionRepositoryProtocol {

    // MARK: - Properties
    private let definitionsSubject = CurrentValueSubject<[ExerciseDefinition], Never>([])

    var definitionsPublisher: AnyPublisher<[ExerciseDefinition], Never> {
        definitionsSubject.eraseToAnyPublisher()
    }

    private let mockDefinitions: [ExerciseDefinition] = [
        .mockedBBBenchPress,
        .mockedBBSquats,
        .mockedPullUp,
    ]

    // MARK: - Public Methods
    func loadDefinitions(muscle: MuscleGroup? = nil, equipment: Equipment? = nil,
                         category: ExerciseCategory? = nil, page: Int = 0) async throws {
        var filtered = mockDefinitions

        if let muscle {
            filtered = filtered.filter { $0.primaryMuscles.contains(muscle) }
        }
        if let equipment {
            filtered = filtered.filter { $0.equipment == equipment }
        }
        if let category {
            filtered = filtered.filter { $0.category == category }
        }

        definitionsSubject.send(filtered)
    }

    func search(query: String) async throws -> [ExerciseDefinition] {
        mockDefinitions.filter { $0.name.localizedStandardContains(query) }
    }

    func getDefinition(id: String) async throws -> ExerciseDefinition? {
        mockDefinitions.first { $0.id == id }
    }
}
