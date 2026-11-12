//
//  ExercisePickerSheet.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ExercisePickerSheet
/// Resolves dependencies from the environment and presents the exercise picker.
struct ExercisePickerSheet: View {

    // MARK: - Properties
    @Environment(\.dependencyContainer) private var dependencyContainer

    let definitionIdsInWorkout: Set<String>
    let onAdd: ([ExerciseDefinition]) -> Void

    // MARK: - Body
    var body: some View {
        ExercisePickerView(
            viewModel: ExercisePickerViewModel(
                libraryRepository: dependencyContainer.userExerciseLibraryRepository,
                definitionIdsInWorkout: definitionIdsInWorkout
            ),
            onAdd: onAdd
        )
    }
}
