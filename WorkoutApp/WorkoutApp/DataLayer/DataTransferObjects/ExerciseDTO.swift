//
//  ExerciseDTO.swift
//  WorkoutApp
//
//  Created by Raul Pele on 21.01.2026.
//

import Foundation
import SwiftData

@Model
class ExerciseDTO: DomainConvertible {
    @Attribute(.unique) var id: UUID
    var definition: ExerciseDefinition
    var numberOfSets: Int
    var setData: ExerciseSet
    var restBetweenSets: TimeInterval
    @Relationship(inverse: \WorkoutDTO.exercises) var workouts: [WorkoutDTO]?

    init(id: UUID, definition: ExerciseDefinition, numberOfSets: Int, setData: ExerciseSet, restBetweenSets: TimeInterval) {
        self.id = id
        self.definition = definition
        self.numberOfSets = numberOfSets
        self.setData = setData
        self.restBetweenSets = restBetweenSets
    }

    convenience init(from exercise: Exercise) {
        self.init(
            id: exercise.id,
            definition: exercise.definition,
            numberOfSets: exercise.numberOfSets,
            setData: exercise.setData,
            restBetweenSets: exercise.restBetweenSets
        )
    }

    func toDomain() -> Exercise {
        Exercise(
            id: id,
            definition: definition,
            numberOfSets: numberOfSets,
            setData: setData,
            restBetweenSets: restBetweenSets
        )
    }
}
