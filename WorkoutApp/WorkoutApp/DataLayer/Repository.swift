//
//  Repository.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation

protocol Repository {
    
    associatedtype T
    
    func getAll() async throws -> [T] 
}
