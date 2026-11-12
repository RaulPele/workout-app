//
//  Workout+Copy.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

extension Workout {

    /// A copy with fresh identifiers and a unique name, e.g. "Push Day Copy" or "Push Day Copy 2".
    func duplicate(existingNames: [String]) -> Workout {
        let taken = Set(existingNames.map { $0.lowercased() })
        let baseName = "\(name) Copy"
        var candidate = baseName
        var counter = 2
        while taken.contains(candidate.lowercased()) {
            candidate = "\(baseName) \(counter)"
            counter += 1
        }

        let copiedExercises = exercises.map { exercise in
            Exercise(
                id: UUID(),
                definition: exercise.definition,
                numberOfSets: exercise.numberOfSets,
                setData: ExerciseSet(id: UUID(), reps: exercise.setData.reps),
                restBetweenSets: exercise.restBetweenSets
            )
        }
        return Workout(id: UUID(), name: candidate, exercises: copiedExercises)
    }
}
