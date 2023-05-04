//
//  MockedWorkoutService.swift
//  WorkoutApp
//
//  Created by Raul Pele on 03.05.2023.
//

import Foundation

class MockedWorkoutService: WorkoutService {
    
    func getAll() -> [Workout] {
        return Workout.mockedSet
    }
}
