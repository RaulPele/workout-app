//
//  Exercise.swift
//  WorkoutApp
//
//  Created by Raul Pele on 13.05.2023.
//

import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    
    let id: UUID
    let name: String
    let numberOfSets: Int
    let setData: ExerciseSet
    
    let restBetweenSets: TimeInterval
}

extension Exercise {
    
    static let mockedBBBenchPress = Exercise(
        id: .init(),
        name: "BB Bench Press",
        numberOfSets: 3,
        setData: .mockedBBBenchPress,
        restBetweenSets: 150
    )
    
    static let mockedBBSquats = Exercise(
        id: .init(),
        name: "BB Squats",
        numberOfSets: 4,
        setData: .mockedBBSquats,
        restBetweenSets: 150

    )
}
