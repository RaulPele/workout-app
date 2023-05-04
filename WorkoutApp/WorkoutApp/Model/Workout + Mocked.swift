//
//  Workout + Mocked.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2023.
//

import Foundation

extension Workout {
    
    static let mocked1: Workout = .init(id: 0,
                                 title: "Day 3 Week 4",
                                 averageHeartRate: 155,
                                 duration: 5450,
                                 totalCalories: 900,
                                 activeCalories: 780,
                                 date: .init())
    
    static let mocked2: Workout = .init(id: 1,
                                 title: "Morning session",
                                 averageHeartRate: 155,
                                 duration: 5450,
                                 totalCalories: 900,
                                 activeCalories: 780,
                                 date: .init())
    
    static let mocked3: Workout = .init(id: 2,
                                 title: "After work session",
                                 averageHeartRate: 155,
                                 duration: 5450,
                                 totalCalories: 900,
                                 activeCalories: 780,
                                 date: .init())
    
    static let mocked4: Workout = .init(id: 3,
                                 title: "TSW Day 3 Week 4",
                                 averageHeartRate: 155,
                                 duration: 5450,
                                 totalCalories: 900,
                                 activeCalories: 780,
                                 date: .init())
    
    static let mockedSet = [Workout.mocked1, .mocked2, .mocked3, .mocked4]
}

