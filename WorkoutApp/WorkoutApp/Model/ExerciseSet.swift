//
//  ExerciseSet.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation

struct ExerciseSet: Identifiable, Codable, Hashable {
    
    let id: UUID
    let reps: Int
//    let restTime: TimeInterval
}

extension ExerciseSet {
    static let mockedBBBenchPress = ExerciseSet(id: .init(), reps: 20)
    static let mockedBBSquats = ExerciseSet(id: .init(), reps: 5)
}
