//
//  FeatureFlags.swift
//  WorkoutApp
//
//  Created by Raul Pele on 19.05.2026.
//

import Foundation

enum FeatureFlags {

    /// Re-enables the remote exercise catalog (`AddExerciseView` + `ExerciseDefinitionRepository`).
    /// Kept `false` for V1 — local user-built library only. Flip to `true` to restore the catalog flow.
    static let useRemoteExerciseCatalog = false
}
