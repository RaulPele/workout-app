//
//  ExerciseLibraryRowButton.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - ExerciseLibraryRowButton
/// A tappable library card with Edit and Delete in its context menu and accessibility actions.
struct ExerciseLibraryRowButton: View {

    // MARK: - Properties
    let definition: ExerciseDefinition
    let onEdit: () -> Void
    let onDelete: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: onEdit) {
            ExerciseLibraryCardView(definition: definition)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: onEdit)
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
        .accessibilityAction(named: "Delete", onDelete)
    }
}
