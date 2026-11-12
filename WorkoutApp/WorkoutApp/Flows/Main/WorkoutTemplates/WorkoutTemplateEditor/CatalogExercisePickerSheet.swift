//
//  CatalogExercisePickerSheet.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - CatalogExercisePickerSheet
/// The remote exercise catalog picker, only used when `FeatureFlags.useRemoteExerciseCatalog` is on.
struct CatalogExercisePickerSheet: View {

    // MARK: - Properties
    @Environment(\.dependencyContainer) private var dependencyContainer

    let onExerciseSelected: (Exercise) -> Void

    // MARK: - Body
    var body: some View {
        AddExerciseView(
            exerciseDefinitionRepository: dependencyContainer.exerciseDefinitionRepository,
            exerciseRepository: dependencyContainer.exerciseRepository,
            onExerciseSelected: onExerciseSelected
        )
    }
}
