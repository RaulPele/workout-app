//
//  MockedWorkoutService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation

class MockedWorkoutSessionService: WorkoutSessionService {
    
    func getAll() -> [WorkoutSession] {
        return WorkoutSession.mockedSet
    }
}
