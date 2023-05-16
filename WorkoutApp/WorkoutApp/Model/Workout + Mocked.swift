//
//  Workout + Mocked.swift
//  WorkoutApp
//
//  Created by Raul Pele on 02.05.2023.
//

import Foundation

extension Workout {
    
    static let mocked1: Workout = .init(id: .init(),
                                        title: "Day 3 Week 4",
                                        workoutTemplate: .mockedWorkoutTemplate,
                                        performedExercises: [.mockedBBBenchPress, .mockedBBSquats],
                                        averageHeartRate: 155,
                                        duration: 5450,
                                        startDate: .now,
                                        endDate: Date(timeInterval: 3600, since: .now),
                                        totalCalories: 900,
                                        activeCalories: 780
    )
    
    static let mocked2: Workout = .init(id: .init(),
                                        title: "Morning session",
                                        workoutTemplate: .mockedWorkoutTemplate,
                                        performedExercises: [.mockedBBBenchPress, .mockedBBSquats],
                                        averageHeartRate: 155,
                                        duration: 5450,
                                        startDate: .now,
                                        endDate: Date(timeInterval: 3600, since: .now),
                                        totalCalories: 900,
                                        activeCalories: 780)
    
    static let mocked3: Workout = .init(id: .init(),
                                        title: "After work session",
                                        workoutTemplate: .mockedWorkoutTemplate,
                                        performedExercises: [.mockedBBBenchPress, .mockedBBSquats],
                                        averageHeartRate: 155,
                                        duration: 5450,
                                        startDate: .now,
                                        endDate: Date(timeInterval: 3600, since: .now),
                                        totalCalories: 900,
                                        activeCalories: 780)
    
    static let mocked4: Workout = .init(id: .init(),
                                        title: "TSW Day 3 Week 4",
                                        workoutTemplate: .mockedWorkoutTemplate,
                                        performedExercises: [.mockedBBBenchPress, .mockedBBSquats],
                                        averageHeartRate: 155,
                                        duration: 5450,
                                        startDate: .now,
                                        endDate: Date(timeInterval: 3600, since: .now),
                                        totalCalories: 900,
                                        activeCalories: 780
    )
    
    static let mockedSet = [Workout.mocked1, .mocked2, .mocked3, .mocked4]
}

