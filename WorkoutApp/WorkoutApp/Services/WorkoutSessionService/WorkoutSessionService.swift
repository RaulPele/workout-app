//
//  WorkoutService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation

protocol WorkoutSessionService {
    
    func getAll() async throws -> [WorkoutSession]
}

class WorkoutSessionAPIService: WorkoutSessionService {
    
    func getAll() async throws -> [WorkoutSession] {
        return .init()
    }
}
