//
//  WorkoutTemplateEditorSheet.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - WorkoutTemplateEditorSheet
/// Resolves dependencies from the environment and presents the workout editor.
struct WorkoutTemplateEditorSheet: View {

    // MARK: - Properties
    @Environment(\.dependencyContainer) private var dependencyContainer

    var workout: Workout?
    var onSaved: () -> Void = {}

    // MARK: - Body
    var body: some View {
        WorkoutTemplateEditorView(
            viewModel: WorkoutTemplateEditorViewModel(
                workoutRepository: dependencyContainer.workoutTemplateRepository,
                workout: workout
            ),
            onSaved: onSaved
        )
    }
}
