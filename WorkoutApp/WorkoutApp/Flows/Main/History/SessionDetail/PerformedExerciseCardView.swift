//
//  PerformedExerciseCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - PerformedExerciseCardView
/// One exercise from a session, always expanded, with its set table.
struct PerformedExerciseCardView: View {

    // MARK: - Properties
    let performedExercise: PerformedExercise

    private var setsSummary: String {
        "\(performedExercise.sets.count) of \(performedExercise.exercise.numberOfSets) sets"
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(performedExercise.exercise.name)
                    .font(.headline)
                    .foregroundStyle(Color.onSurface)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(setsSummary)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            if performedExercise.sets.isEmpty {
                Text("No sets logged.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                SetTableView(sets: performedExercise.sets)
            }
        }
        .cardStyle()
    }
}
