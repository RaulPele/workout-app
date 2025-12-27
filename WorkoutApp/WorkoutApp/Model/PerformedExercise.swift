//
//  PerformedExercise.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation

struct PerformedExercise: Identifiable, Codable, Hashable {
    
    let id: UUID
    let exercise: Exercise
//    let numberOfSets: Int
    var sets: [PerformedSet] // TODO: change to an array of performed sets
    //TODO: add data health metrics
}

extension PerformedExercise {
    static let mockedBBBenchPress = PerformedExercise(
        id: .init(),
        exercise: .mockedBBBenchPress,
//        numberOfSets: 3,
        sets: [.mockedBBBenchPress, .mockedBBBenchPress, .mockedBBBenchPress]
    )
    
    static let mockedBBSquats = PerformedExercise(
        id: .init(),
        exercise: .mockedBBSquats,
//        numberOfSets: 3,
        sets: [.mockedBBSquats, .mockedBBSquats]
    )
    
}
