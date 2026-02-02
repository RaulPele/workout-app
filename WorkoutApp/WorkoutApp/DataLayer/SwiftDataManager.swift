//
//  SwiftDataManager.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.01.2026.
//

import Foundation
import SwiftData

// MARK: - Conversion Protocols

protocol DomainConvertible {
    associatedtype DomainType
    func toDomain() -> DomainType
}

protocol SwiftDataConvertible {
    associatedtype DTO: DomainConvertible & PersistentModel
    var dto: DTO { get }
}

// MARK: - SwiftDataManager

@MainActor
class SwiftDataManager {
    
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "SwiftDataManager"
    )
    
    static let shared: SwiftDataManager = {
        let schema = Schema([
            WorkoutDTO.self,
            ExerciseDTO.self,
//            ExerciseSetDTO.self,
//            WorkoutSessionDTO.self,
//            PerformedExerciseDTO.self,
//            PerformedSetDTO.self
        ])
        
        
        do {
            let container = try ModelContainer(for: schema)
            return SwiftDataManager(modelContainer: container)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    private let modelContainer: ModelContainer
    
    var mainContext: ModelContext {
        modelContainer.mainContext
    }
    
    private init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        logger.info("SwiftDataManager initialized")
    }
    
    // MARK: - Generic DTO CRUD Operations
    
    func fetchAll<T: PersistentModel>() async throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        let results = try mainContext.fetch(descriptor)
        return results
    }
    
    func fetch<T: PersistentModel>(predicate: Predicate<T>?) async throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let results = try mainContext.fetch(descriptor)
        return results
    }
    
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

@MainActor
class SwiftDataDataSource<T: SwiftDataConvertible> where T: Identifiable, T.ID == UUID {
    
    private let manager = SwiftDataManager.shared
    private let logger = CustomLogger(
        subsystem: Bundle.main.bundleIdentifier ?? "WorkoutApp",
        category: "SwiftDataDataSource"
    )
    
    func save(entity: T) async throws {
        let dto = entity.dto
        
        do {
            try await manager.save(dto)
        } catch {
            let entityType = String(describing: T.self)
            logger.error("Failed to save domain entity of type: \(entityType), error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchAll() async throws -> [T.DTO.DomainType] {
        let list: [T.DTO] = try await manager.fetchAll()
        let domainEntities = list.map { $0.toDomain() }
        return domainEntities
    }
    
    func delete(entity: T) async throws {
        let entityId = entity.id
        
        do {
            // Fetch all DTOs and find the matching one
            let allDTOs: [T.DTO] = try await manager.fetchAll()
            
            // Find the DTO with matching ID
            guard let dtoToDelete = allDTOs.first(where: { dto in
                let domainEntity = dto.toDomain()
                if let identifiable = domainEntity as? any Identifiable {
                    return (identifiable.id as? UUID) == entityId
                }
                return false
            }) else {
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
