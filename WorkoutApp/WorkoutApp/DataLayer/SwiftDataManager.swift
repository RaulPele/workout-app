//
//  SwiftDataManager.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.01.2026.
//

import Foundation
import SwiftData
import Playgrounds
import FoundationModels

// MARK: - Conversion Protocols

protocol DomainConvertible {
    associatedtype DomainType
    func toDomain() -> DomainType
}

protocol SwiftDataConvertible {
    associatedtype DTO: DomainConvertible & PersistentModel
    var dto: DTO { get }
    func update(_ existingDTO: DTO)
}

// MARK: - SwiftDataManager

actor SwiftDataManager {
    
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "SwiftDataManager"
    )
    
    static let shared: SwiftDataManager = {
        let schema = Schema([
            WorkoutDTO.self,
            WorkoutSessionDTO.self,
            ExerciseDefinitionDTO.self,
            UserExerciseDefinitionDTO.self,
        ])
        
        
        do {
            let container = try ModelContainer(for: schema)
            return SwiftDataManager(modelContainer: container)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    private let modelContainer: ModelContainer
    
    private init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        logger.info("SwiftDataManager initialized")
    }
    
    @MainActor private var mainContext: ModelContext {
        return modelContainer.mainContext
    }
    
    // MARK: - Generic DTO CRUD Operations
    
    @MainActor
    func fetchAll<T: PersistentModel>() async throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        let results = try mainContext.fetch(descriptor)
        return results
    }
    
    @MainActor
    func fetch<T: PersistentModel>(predicate: Predicate<T>?) async throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let results = try mainContext.fetch(descriptor)
        return results
    }
    
    @MainActor
    func save<T: PersistentModel>(_ entity: T) async throws {
        mainContext.insert(entity)
        
        do {
            try mainContext.save()
        } catch {
            let entityType = String(describing: T.self)
            logger.error("Failed to save entity of type: \(entityType), error: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func saveAll<T: PersistentModel>(_ entities: [T]) async throws {
        for entity in entities {
            mainContext.insert(entity)
        }
        
        do {
            try mainContext.save()
        } catch {
            let entityType = String(describing: T.self)
            logger.error("Failed to save \(entities.count) entities of type: \(entityType), error: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func saveContext() async throws {
        do {
            try mainContext.save()
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
            throw error
        }
    }

    @MainActor
    func delete<T: PersistentModel>(_ entity: T) async throws {
        mainContext.delete(entity)
        
        do {
            try mainContext.save()
        } catch {
            let entityType = String(describing: T.self)
            logger.error("Failed to delete entity of type: \(entityType), error: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func deleteAll<T: PersistentModel>(_ entities: [T]) async throws {
        for entity in entities {
            mainContext.delete(entity)
        }
        
        do {
            try mainContext.save()
        } catch {
            let entityType = String(describing: T.self)
            logger.error("Failed to delete \(entities.count) entities of type: \(entityType), error: \(error.localizedDescription)")
            throw error
        }
    }
    
}

class SwiftDataDataSource<T: SwiftDataConvertible> where T: Identifiable, T.DTO.DomainType == T {

    private let manager = SwiftDataManager.shared
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "SwiftDataDataSource"
    )

    func save(entity: T) async throws {
        do {
            let allDTOs: [T.DTO] = try await manager.fetchAll()
            let existingDTO = allDTOs.first { $0.toDomain().id == entity.id }

            if let existing = existingDTO {
                entity.update(existing)
                try await manager.saveContext()
            } else {
                try await manager.save(entity.dto)
            }
        } catch {
            let entityType = String(describing: T.self)
            logger.error("Failed to save domain entity of type: \(entityType), error: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchAll() async throws -> [T] {
        let list: [T.DTO] = try await manager.fetchAll()
        return list.map { $0.toDomain() }
    }

    func delete(entity: T) async throws {
        let entityId = entity.id

        do {
            let allDTOs: [T.DTO] = try await manager.fetchAll()

            guard let dtoToDelete = allDTOs.first(where: { $0.toDomain().id == entityId }) else {
                let entityType = String(describing: T.self)
                logger.debug("No DTO found to delete for entity of type: \(entityType), id: \(entityId)")
                return
            }

            try await manager.delete(dtoToDelete)
            logger.info("Successfully deleted entity of type: \(String(describing: T.self)), id: \(entityId)")
        } catch {
            let entityType = String(describing: T.self)
            logger.error("Failed to delete domain entity of type: \(entityType), id: \(entityId), error: \(error.localizedDescription)")
            throw error
        }
    }
}
