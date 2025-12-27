//
//  PerformedSet.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation

struct PerformedSet: Identifiable, Codable, Hashable {
    
    let id: UUID
    let set: ExerciseSet
    let reps: Int
    let weight: Double
    var restTime: TimeInterval
}

extension PerformedSet {
    
    static let mockedBBBenchPress = PerformedSet(
        id: .init(),
        set: .mockedBBBenchPress,
        reps: 20,
        weight: 50,
        restTime: 150
    )
    
    static let mockedBBSquats = PerformedSet(
        id: .init(),
        set: .mockedBBSquats,
        reps: 5,
        weight: 70,
        restTime: 200
    )
}
