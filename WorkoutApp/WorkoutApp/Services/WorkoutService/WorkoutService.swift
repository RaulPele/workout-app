//
//  WorkoutService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation

protocol WorkoutService {
    
    func getAll() async throws -> [Workout]
}

class WorkoutAPIService: WorkoutService {
    
    func getAll() async throws -> [Workout] {
        return .init()
    }
}
