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
    var exercises: [ExerciseDTO]
    
    init(id: UUID, name: String, exercises: [ExerciseDTO]) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }
    
    convenience init (from workout: Workout) {
        self.init(id: workout.id, name: workout.name, exercises: workout.exercises.map(\.dto))
    }
    
    func toDomain() -> Workout {
        Workout(
            id: id,
            name: name,
            exercises: exercises.map { $0.toDomain() }
        )
    }
}
