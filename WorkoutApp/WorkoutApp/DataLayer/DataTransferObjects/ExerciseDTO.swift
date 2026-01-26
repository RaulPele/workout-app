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
    var name: String
    var numberOfSets: Int
    var setData: ExerciseSet
    var restBetweenSets: TimeInterval
    @Relationship(inverse: \WorkoutDTO.exercises) var workouts: [WorkoutDTO]?
//    var performedExercises: [PerformedExerciseDTO]?
    
    init(id: UUID, name: String, numberOfSets: Int, setData: ExerciseSet, restBetweenSets: TimeInterval) {
        self.id = id
        self.name = name
        self.numberOfSets = numberOfSets
        self.setData = setData
        self.restBetweenSets = restBetweenSets
    }
    
    convenience init(from exercise: Exercise) {
        self.init(
            id: exercise.id,
            name: exercise.name,
            numberOfSets: exercise.numberOfSets,
            setData: exercise.setData,
            restBetweenSets: exercise.restBetweenSets
        )
    }
    
    func toDomain() -> Exercise {
        // Only convert owned properties, NOT inverse relationships (workouts, performedExercises)
        Exercise(
            id: id,
            name: name,
            numberOfSets: numberOfSets,
            setData: setData,
            restBetweenSets: restBetweenSets
        )
    }
}
