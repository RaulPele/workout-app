//
//  TemplateExerciseCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 11.11.2026.
//

import SwiftUI

// MARK: - TemplateExerciseCardView
/// A numbered exercise in the workout detail screen with its targets.
struct TemplateExerciseCardView: View {

    // MARK: - Properties
    let position: Int
    let exercise: Exercise

    // MARK: - Body
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(position)")
                .font(.title2.monospaced())
                .bold()
                .foregroundStyle(Color.primaryColor)
                .frame(minWidth: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(Color.onSurface)

                    if let summary = exercise.definition.detailSummary {
                        Text(summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                FlowLayout(spacing: 6) {
                    PillView(text: exercise.targetSummary)
                    PillView(text: exercise.restSummary, systemImage: "timer")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Exercise \(position): \(exercise.name), \(exercise.targetSummary), \(exercise.restSummary)")
    }
}
