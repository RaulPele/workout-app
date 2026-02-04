//
//  Repository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation
import Combine

protocol Repository {
    
    associatedtype T: Identifiable
    
    /// Reactive publisher that emits all entities whenever they change
    var entitiesPublisher: AnyPublisher<[T], Never> { get }
    
    /// Reactive publisher that emits errors when operations fail
//    var errorPublisher: AnyPublisher<Error, Never> { get }
    
    /// Saves an entity and triggers an update to entitiesPublisher
    func save(entity: T) async throws
    
    /// Deletes an entity and triggers an update to entitiesPublisher
//    func delete(entity: T) async throws
    
    /// Manually triggers a refresh of the entities
    func loadData() async throws
}
