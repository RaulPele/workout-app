//
//  WorkoutDTO.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.01.2026.
//

import Foundation
import SwiftData

@Model
class WorkoutDTO: DomainConvertible {
    @Attribute(.unique) var id: UUID
    var name: String
    var exercises: [Exercise]

    init(id: UUID, name: String, exercises: [Exercise]) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }

    convenience init(from workout: Workout) {
        self.init(id: workout.id, name: workout.name, exercises: workout.exercises)
    }

    func toDomain() -> Workout {
        Workout(id: id, name: name, exercises: exercises)
    }
}
