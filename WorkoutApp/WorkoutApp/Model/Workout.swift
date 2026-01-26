//
//  Workout.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.05.2023.
//

import Foundation

struct Workout: Identifiable, Codable, Hashable {
    
    let id: UUID
    let name: String
    let exercises: [Exercise]
}

extension Workout {
    
    static let mockedWorkoutTemplate = Workout(
        id: .init(),
        name: "My strength workout",
        exercises: [.mockedBBSquats, .mockedBBBenchPress]
    )
    
    static func mockedWorkoutTemplate2() -> Workout {
        return Workout(
            id: .init(),
            name: "My strength workout",
            exercises: [.mockedBBSquats, .mockedBBBenchPress]
        )
    }
}

