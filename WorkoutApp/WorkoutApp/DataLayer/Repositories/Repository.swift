//
//  Repository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation

protocol Repository {
    
    associatedtype T: Identifiable
    
    func getAll() async throws -> [T]
    @discardableResult func save(entity: T) async throws -> T
}
