//
//  ExerciseEditorSheet.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ExerciseEditorSheet
/// Resolves dependencies from the environment and presents the exercise editor.
struct ExerciseEditorSheet: View {

    // MARK: - Properties
    @Environment(\.dependencyContainer) private var dependencyContainer

    var definition: ExerciseDefinition?
    var onSaved: (ExerciseDefinition) -> Void = { _ in }

    // MARK: - Body
    var body: some View {
        ExerciseEditorView(
            viewModel: ExerciseEditorViewModel(
                libraryRepository: dependencyContainer.userExerciseLibraryRepository,
                workoutRepository: dependencyContainer.workoutTemplateRepository,
                definition: definition
            ),
            onSaved: onSaved
        )
    }
}
