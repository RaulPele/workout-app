//
//  ExerciseDraft.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import Foundation

// MARK: - ExerciseDraft
/// An editable copy of a template exercise. `Exercise` is immutable and shared with the watch,
/// so the editor works on drafts and converts back when saving.
struct ExerciseDraft: Identifiable, Equatable {

    // MARK: - Defaults
    static let defaultSets = 3
    static let defaultReps = 10
    static let defaultRestSeconds = 90

    // MARK: - Properties
    let id: UUID
    let setId: UUID
    var definition: ExerciseDefinition
    var sets: Int
    var reps: Int
    var restSeconds: Int

    // MARK: - Initializers
    init(exercise: Exercise) {
        self.id = exercise.id
        self.setId = exercise.setData.id
        self.definition = exercise.definition
        self.sets = exercise.numberOfSets
        self.reps = exercise.setData.reps
        self.restSeconds = Int(exercise.restBetweenSets)
    }

    init(definition: ExerciseDefinition) {
        self.id = UUID()
        self.setId = UUID()
        self.definition = definition
        self.sets = Self.defaultSets
        self.reps = Self.defaultReps
        self.restSeconds = Self.defaultRestSeconds
    }

    // MARK: - Conversion
    var exercise: Exercise {
        Exercise(
            id: id,
            definition: definition,
            numberOfSets: sets,
            setData: ExerciseSet(id: setId, reps: reps),
            restBetweenSets: TimeInterval(restSeconds)
        )
    }
}
