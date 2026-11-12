//
//  WorkoutTemplateCardView.swift
//  WorkoutApp
//
//  Created by Raul Pele on 30.05.2023.
//

import SwiftUI

// MARK: - WorkoutTemplateCardView
/// A workout template as a card: name, the muscles it trains, counts and an exercise preview.
struct WorkoutTemplateCardView: View {

    // MARK: - Properties
    let workout: Workout

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(workout.name)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.onSurface)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.footnote.bold())
                    .foregroundStyle(.tertiary)
            }

            let muscles = workout.topMuscles()
            if !muscles.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(muscles, id: \.self) { muscle in
                        PillView(text: muscle.displayName, style: .accent, isMonospaced: false)
                    }
                }
            }

            Text(workout.countsSummary)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)

            if !workout.exercises.isEmpty {
                Text(workout.exercisePreview())
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews
#Preview {
    VStack(spacing: 12) {
        WorkoutTemplateCardView(workout: .mockedWorkoutTemplate)
        WorkoutTemplateCardView(workout: .mockedWorkoutTemplate2())
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
